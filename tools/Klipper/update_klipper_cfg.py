#!/usr/bin/env python3
"""
update_printer_cfg.py - Merge an update.cfg into a printer.cfg in-place.

Usage:
    python3 update_printer_cfg.py <printer.cfg> <update.cfg>

The original printer.cfg is backed up as printer.cfg.YYMMDDhhmmss before any
changes are written.  The merged result is written back to printer.cfg.

Merge rules
-----------
* Every key=value (or key: value) line inside a matching [section] in
  update.cfg replaces the *first* occurrence of that same key in the same
  section of printer.cfg.  The replacement text is taken verbatim from
  update.cfg (preserving the update file's spacing and inline comments).
* Multiline values (continuation lines that start with whitespace) that
  follow a replaced key are replaced as a unit.
* If a key from update.cfg does not exist in the target section of
  printer.cfg, it is appended at the end of that section.
* If an entire [section] from update.cfg does not exist in printer.cfg,
  the section (header + all its key/value lines) is appended at the end
  of the file.
* All other lines in printer.cfg – including blank lines, comments, and
  the SAVE_CONFIG block – are reproduced exactly.
* Lines inside the #*# SAVE_CONFIG block are never modified.
"""

import sys
import os
import re
import shutil
from datetime import datetime


# ---------------------------------------------------------------------------
# Minimal config tokeniser (no external deps beyond stdlib)
# ---------------------------------------------------------------------------

# Matches a section header such as [stepper_x] or [extruder 0]
SECTION_RE = re.compile(r'^\[([^\]]+)\]\s*$')
# Matches a key line: key: value  OR  key = value
# The key must start at column 0 (not indented).
KEY_RE = re.compile(r'^([A-Za-z0-9_]+)\s*[:=]')
# A continuation line starts with whitespace (multiline value)
CONTINUATION_RE = re.compile(r'^\s+\S')
# Comment or blank line
COMMENT_BLANK_RE = re.compile(r'^\s*(#|;|$)')
# Klipper SAVE_CONFIG sentinel
SAVE_CONFIG_SENTINEL = '#*# <---------------------- SAVE_CONFIG'


def parse_update_cfg(lines):
    """
    Parse update.cfg into an ordered structure:
        { section_name: [ (key, [line, ...]), ... ] }
    where each entry is the key string and the list of raw text lines that
    make up that key's value (first line is the key line itself; subsequent
    lines are continuations).

    Section names and keys are lowercased to match Klipper / configparser
    case-folding, but the raw line text is preserved for substitution.
    """
    sections = {}        # section_name -> list of (key, lines_list)
    section_order = []   # preserve insertion order for appending
    current_section = None
    current_key = None
    current_lines = []

    def flush():
        nonlocal current_key, current_lines
        if current_section is not None and current_key is not None:
            sections[current_section].append((current_key, current_lines))
        current_key = None
        current_lines = []

    for raw in lines:
        line = raw.rstrip('\n')

        # Skip pure comment / blank lines in update.cfg
        if COMMENT_BLANK_RE.match(line):
            flush()
            continue

        m = SECTION_RE.match(line)
        if m:
            flush()
            sec = m.group(1).strip().lower()
            current_section = sec
            if sec not in sections:
                sections[sec] = []
                section_order.append(sec)
            continue

        # Continuation line (must belong to current key)
        if CONTINUATION_RE.match(line):
            if current_key is not None:
                current_lines.append(line)
            continue

        # Key line
        km = KEY_RE.match(line)
        if km:
            flush()
            key = km.group(1).lower()
            current_key = key
            current_lines = [line]
            continue

    flush()
    return sections, section_order


def is_in_save_config(line):
    """Return True if line is part of or introduces the SAVE_CONFIG block."""
    return line.startswith('#*#') or line.startswith(SAVE_CONFIG_SENTINEL)


def merge(printer_lines, update_sections, section_order):
    """
    Perform the line-level merge.

    Returns a list of output lines (with \\n endings).
    Also returns a dict of which keys were actually applied so we know what
    still needs to be appended.
    """
    output = []
    # Track which updates have been applied:
    # applied[section][key] = True
    applied = {sec: set() for sec in update_sections}

    current_section = None   # lowercased section name currently being scanned
    in_save_config = False
    i = 0
    n = len(printer_lines)

    while i < n:
        raw = printer_lines[i]
        line = raw.rstrip('\n')

        # ---- Detect SAVE_CONFIG block: stop modifying from here on ----
        if not in_save_config and line.startswith(SAVE_CONFIG_SENTINEL):
            in_save_config = True

        if in_save_config:
            output.append(raw)
            i += 1
            continue

        # ---- Section header ----
        m = SECTION_RE.match(line)
        if m:
            current_section = m.group(1).strip().lower()
            output.append(raw)
            i += 1
            continue

        # ---- Comment / blank line: pass through unchanged ----
        if COMMENT_BLANK_RE.match(line):
            output.append(raw)
            i += 1
            continue

        # ---- Continuation line not preceded by a key we're replacing:
        #      pass through (normal flow; if we replaced a key the
        #      continuation is consumed below) ----
        if CONTINUATION_RE.match(line):
            output.append(raw)
            i += 1
            continue

        # ---- Key line ----
        km = KEY_RE.match(line)
        if km and current_section is not None:
            key = km.group(1).lower()

            # Collect the original key block (key line + continuations)
            orig_block = [raw]
            j = i + 1
            while j < n:
                next_raw = printer_lines[j]
                next_line = next_raw.rstrip('\n')
                if CONTINUATION_RE.match(next_line):
                    orig_block.append(next_raw)
                    j += 1
                else:
                    break

            # Check if this key is targeted by update.cfg for this section
            if (current_section in update_sections
                    and key not in applied[current_section]):
                # Find the update entry for this key
                update_entry = None
                for ukey, ulines in update_sections[current_section]:
                    if ukey == key:
                        update_entry = ulines
                        break

                if update_entry is not None:
                    # Emit the replacement lines
                    for ul in update_entry:
                        output.append(ul + '\n')
                    applied[current_section].add(key)
                    i = j   # skip the original block (key + continuations)
                    continue

            # No replacement: pass original block through unchanged
            output.extend(orig_block)
            i = j
            continue

        # Anything else (shouldn't normally occur): pass through
        output.append(raw)
        i += 1

    # ---- Append keys that were not found in the original file ----
    # Group missing keys by section
    for sec in section_order:
        if sec not in update_sections:
            continue
        missing_keys = []
        for ukey, ulines in update_sections[sec]:
            if ukey not in applied.get(sec, set()):
                missing_keys.append((ukey, ulines))

        if not missing_keys:
            continue

        # Does the section exist at all in the output?
        sec_header_re = re.compile(
            r'^\[' + re.escape(sec) + r'\]\s*$', re.IGNORECASE)
        sec_exists = any(sec_header_re.match(l.rstrip('\n')) for l in output)

        if sec_exists:
            # Find the end of that section in the output and insert there
            # "end of section" = the line before the next section header or EOF
            # We do this by rebuilding output with the insertions in place.
            new_output = []
            in_target = False
            inserted = False
            for idx, ol in enumerate(output):
                stripped = ol.rstrip('\n')
                hm = SECTION_RE.match(stripped)
                if hm:
                    if hm.group(1).strip().lower() == sec:
                        in_target = True
                        new_output.append(ol)
                        continue
                    elif in_target and not inserted:
                        # We are leaving the target section; insert here
                        for _, ulines in missing_keys:
                            for ul in ulines:
                                new_output.append(ul + '\n')
                        inserted = True
                        in_target = False
                if in_target and stripped.startswith(SAVE_CONFIG_SENTINEL):
                    for _, ulines in missing_keys:
                        for ul in ulines:
                            new_output.append(ul + '\n')
                    inserted = True
                    in_target = False
                new_output.append(ol)

            if in_target and not inserted:
                # Target section ran to EOF
                for _, ulines in missing_keys:
                    for ul in ulines:
                        new_output.append(ul + '\n')

            output = new_output
        else:
            # Section doesn't exist at all; append entire section at end
            # Insert before SAVE_CONFIG if present, otherwise at EOF
            save_idx = None
            for idx, ol in enumerate(output):
                if ol.rstrip('\n').startswith(SAVE_CONFIG_SENTINEL):
                    save_idx = idx
                    break

            insert_block = ['\n', '[%s]\n' % sec]
            for _, ulines in missing_keys:
                for ul in ulines:
                    insert_block.append(ul + '\n')

            if save_idx is not None:
                output = output[:save_idx] + insert_block + output[save_idx:]
            else:
                output.extend(insert_block)

    return output


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) != 3:
        print("Usage: %s <printer.cfg> <update.cfg>" % sys.argv[0],
              file=sys.stderr)
        sys.exit(1)

    printer_cfg_path = sys.argv[1]
    update_cfg_path = sys.argv[2]

    # Validate inputs
    if not os.path.isfile(printer_cfg_path):
        print("Error: printer config not found: %s" % printer_cfg_path,
              file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(update_cfg_path):
        print("Error: update config not found: %s" % update_cfg_path,
              file=sys.stderr)
        sys.exit(1)

    # Create timestamped backup
    timestamp = datetime.now().strftime('%y%m%d%H%M%S')
    backup_path = '%s.%s' % (printer_cfg_path, timestamp)
    shutil.copy2(printer_cfg_path, backup_path)
    print("Backup created: %s" % backup_path)

    # Read files
    with open(backup_path, 'r') as f:
        printer_lines = f.readlines()

    with open(update_cfg_path, 'r') as f:
        update_lines = f.readlines()

    # Parse update.cfg
    update_sections, section_order = parse_update_cfg(update_lines)

    if not update_sections:
        print("Warning: update.cfg contains no parseable sections. "
              "Nothing to do.")
        sys.exit(0)

    # Summarise what will be applied
    total_keys = sum(len(v) for v in update_sections.values())
    print("Applying %d key(s) across %d section(s) from %s"
          % (total_keys, len(update_sections), update_cfg_path))

    # Merge
    merged = merge(printer_lines, update_sections, section_order)

    # Write result back to the original path
    with open(printer_cfg_path, 'w') as f:
        f.writelines(merged)

    print("Done. Updated config written to: %s" % printer_cfg_path)


if __name__ == '__main__':
    main()
