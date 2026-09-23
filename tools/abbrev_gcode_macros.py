#!/usr/bin/env python3
"""
abbrev_gcode_macros.py

Reads a printer config/log dump from stdin. Before the "======================="
separator line, any [gcode_macro NAME] section is collapsed down to a single
line: "[gcode_macro NAME]...".  Everything from the separator line onward
(the separator line itself, and all lines after it) is passed through
unchanged. Meant to be used as one filter in a shell pipe chain.
"""

import re
import sys

MACRO_HEADER_RE = re.compile(r'^\[gcode_macro\s+(\S+)\]\s*$')
SEPARATOR_RE = re.compile(r'^=+$')


def main():
    in_macro_section = False
    # True right after we've printed an abbreviation line; used to swallow
    # any blank/whitespace-only lines that immediately follow it.
    skip_blank_after_abbrev = False

    for line in sys.stdin:
        # Strip only the trailing newline for matching/printing purposes;
        # print() will add it back.
        stripped = line.rstrip('\n')

        if SEPARATOR_RE.match(stripped):
            # Hit the separator: emit it, then everything after verbatim.
            print(stripped)
            for rest in sys.stdin:
                sys.stdout.write(rest)
            return

        # Swallow blank/whitespace-only lines directly following an
        # abbreviation line (e.g. "[gcode_macro FOO]...").
        if skip_blank_after_abbrev:
            if stripped.strip() == '':
                continue
            skip_blank_after_abbrev = False

        macro_match = MACRO_HEADER_RE.match(stripped)
        if macro_match:
            name = macro_match.group(1)
            print(f'[gcode_macro {name}]...')
            in_macro_section = True
            skip_blank_after_abbrev = True
            continue

        if in_macro_section:
            # Are we still inside the macro's body?
            # A new section header of any kind ("[something]") or a blank
            # line followed eventually by another header signals we should
            # stop suppressing. Simplest robust rule: stop suppressing as
            # soon as we see a line that is itself a section header
            # (starts with '[' and ends with ']'), since that means the
            # macro section has ended and a new section has begun.
            if stripped.startswith('[') and stripped.endswith(']'):
                in_macro_section = False
                # Fall through to normal handling of this new header line
                # (it may itself be another gcode_macro header, but we
                # already checked that above and it didn't match, so it's
                # some other section header - print normally).
                print(stripped)
            # else: still inside the macro body, suppress the line
            continue

        # Normal passthrough line
        print(stripped)


if __name__ == '__main__':
    main()
