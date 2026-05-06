#!/usr/bin/env python3
"""
tail_klippy_log.py

Print the tail of a klippy.log file, starting from the last
'===== Config file =====' line to the end of file.

Stats-line compression:
  Consecutive 'Stats' lines are collapsed to show only the first and last,
  with a single '...' line between them.  A lone Stats line is printed as-is.

Usage:
    python3 tail_klippy_log.py <klippy.log>

No dependencies beyond the Python standard library.
"""

import sys


def flush_stats(buf, out):
    """Emit a buffered run of Stats lines: first, '...', last (or just first)."""
    if not buf:
        return
    if len(buf) == 1:
        out.append(buf[0])
    else:
        out.append(buf[0])
        out.append('...')
        out.append(buf[-1])
    buf.clear()


def is_stats_line(line):
    """
    Klipper Stats lines look like:
        Stats 123.4: mcu: ...
    Match any line whose first non-whitespace token is 'Stats'.
    """
    return line.lstrip().startswith('Stats ')


def process(log_path):
    with open(log_path, 'r', errors='replace') as fh:
        all_lines = fh.readlines()

    # Find the last '===== Config file =====' line
    start_index = None
    for i, line in enumerate(all_lines):
        if line.strip() == '===== Config file =====':
            start_index = i

    if start_index is None:
        print('WARNING: no "===== Config file =====" found in log', file=sys.stderr)
        tail = all_lines
    else:
        tail = all_lines[start_index:]

    # Compress consecutive Stats lines
    out = []
    stats_buf = []

    for raw in tail:
        line = raw.rstrip('\n')
        if is_stats_line(line):
            stats_buf.append(line)
        else:
            flush_stats(stats_buf, out)
            out.append(line)

    flush_stats(stats_buf, out)  # in case file ends on a Stats line

    print('\n'.join(out))


def main():
    if len(sys.argv) != 2:
        print(f'Usage: {sys.argv[0]} <klippy.log>', file=sys.stderr)
        sys.exit(1)
    process(sys.argv[1])


if __name__ == '__main__':
    main()
