#!/usr/bin/env python3
"""
extract_bed_probe.py

Parse a Klipper printer.cfg and klippy.log, and emit an Octave script that
defines a set of variables in the current workspace.

Usage:
    python3 klipper_to_octave.py <printer.cfg> <klippy.log> <probeResults.m>

Dependencies: only the Python standard library (all of which are already
present in any Klipper installation).
"""

import argparse
import re
import sys
import os
from datetime import datetime

# ---------------------------------------------------------------------------
# printer.cfg parser
# ---------------------------------------------------------------------------

def parse_cfg(path):
    """
    Minimal INI-style parser that handles Klipper's multi-value config keys
    (values that continue on indented lines).  Returns a dict of
    { section_name: { key: value_string } }.
    """
    sections = {}
    current_section = None
    current_key = None

    with open(path, 'r') as fh:
        for raw in fh:
            line = raw.rstrip('\n')

            # Blank line or comment resets continuation
            stripped = line.strip()
            if not stripped or stripped.startswith('#') or stripped.startswith(';'):
                current_key = None
                continue

            # Section header  [name]
            m = re.match(r'^\[([^\]]+)\]', stripped)
            if m:
                current_section = m.group(1).strip().lower()
                sections.setdefault(current_section, {})
                current_key = None
                continue

            # Continuation line (starts with whitespace and current_key set)
            if line[0] in (' ', '\t') and current_section is not None and current_key is not None:
                sections[current_section][current_key] += ' ' + stripped
                continue

            # key = value
            if '=' in stripped and current_section is not None:
                key, _, value = stripped.partition('=')
                current_key = key.strip().lower()
                sections[current_section][current_key] = value.strip()
                continue

            current_key = None

    return sections


def cfg_get(sections, section, key, default=None):
    return sections.get(section, {}).get(key, default)


def parse_float_list(s):
    """Parse a comma- or whitespace-separated string into a list of floats."""
    if s is None:
        return []
    tokens = re.split(r'[\s,]+', s.strip())
    result = []
    for t in tokens:
        t = t.strip()
        if t:
            try:
                result.append(float(t))
            except ValueError:
                pass
    return result


# ---------------------------------------------------------------------------
# Octave formatting helpers
# ---------------------------------------------------------------------------

def oct_scalar(name, value):
    """name = value;"""
    return f"{name} = {value!r};"


def oct_row_vec(name, values):
    """name = [v1, v2, ...];"""
    inner = ', '.join(repr(float(v)) for v in values)
    return f"{name} = [{inner}];"


def oct_matrix(name, rows):
    """
    name = [r0c0, r0c1, r0c2;
            r1c0, r1c1, r1c2;
            ...];
    """
    if not rows:
        return f"{name} = [];"
    row_strs = []
    for row in rows:
        row_strs.append(', '.join(repr(float(v)) for v in row))
    inner = ';\n        '.join(row_strs)
    return f"{name} = [{inner}];"


# ---------------------------------------------------------------------------
# klippy.log parser
# ---------------------------------------------------------------------------

RE_G28      = re.compile(r'Recv:\s+G28')
RE_Z_OFFSET = re.compile(r'echo:\s+Z_OFFSET:\s*([+-]?[0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)')
RE_CMD_XY   = re.compile(
    r'PROBELOG\s+cmd_x=([+-]?[0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)'
    r'\s+cmd_y=([+-]?[0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)'
)
RE_TRIG_Z   = re.compile(
    r'PROBELOG\s+trigger_z=([+-]?[0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)'
)


def parse_log(path):
    """
    Returns (z_offset, probe_rows) where:
      z_offset   – float or None
      probe_rows – list of [x, y, z] collected after the last 'Recv: G28'
    """
    with open(path, 'r') as fh:
        lines = fh.readlines()

    # Find index of the LAST 'Recv: G28' line
    last_g28 = None
    for i, line in enumerate(lines):
        if RE_G28.search(line):
            last_g28 = i

    # Scan entire file for the most-recent Z_OFFSET echo
    z_offset = None
    for line in lines:
        m = RE_Z_OFFSET.search(line)
        if m:
            z_offset = float(m.group(1))

    # Collect probe triplets from last G28 to end of file
    probe_rows = []
    if last_g28 is not None:
        search_lines = lines[last_g28:]
    else:
        search_lines = []

    pending_xy = None
    for line in search_lines:
        m_xy = RE_CMD_XY.search(line)
        if m_xy:
            pending_xy = (float(m_xy.group(1)), float(m_xy.group(2)))
            continue

        m_z = RE_TRIG_Z.search(line)
        if m_z and pending_xy is not None:
            probe_rows.append([pending_xy[0], pending_xy[1], float(m_z.group(1))])
            pending_xy = None

    return z_offset, probe_rows


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description='Convert Klipper printer.cfg + klippy.log to an Octave variable script.'
    )
    ap.add_argument('cfg',    help='Path to printer.cfg')
    ap.add_argument('log',    help='Path to klippy.log')
    ap.add_argument('output', help='Path to output .m file')
    args = ap.parse_args()

    # --- parse printer.cfg --------------------------------------------------
    sections = parse_cfg(args.cfg)

    printer = sections.get('printer', {})

    delta_radius      = parse_float_list(printer.get('delta_radius'))
    delta_angles      = parse_float_list(printer.get('delta_angles') or printer.get('delta_angle'))
    arm_lengths       = parse_float_list(printer.get('arm_lengths') or printer.get('arm_length'))
    tilt_radial       = parse_float_list(printer.get('tilt_radial'))
    tilt_tangential   = parse_float_list(printer.get('tilt_tangential'))

    # Scalar values that may be single-element lists
    def maybe_scalar(lst):
        if len(lst) == 1:
            return lst[0]
        return lst

    pos_endstops = []
    rot_dists    = []
    for s in ('stepper_a', 'stepper_b', 'stepper_c'):
        sec = sections.get(s, {})
        pe  = sec.get('position_endstop')
        rd  = sec.get('rotation_distance')
        pos_endstops.append(float(pe) if pe is not None else float('nan'))
        rot_dists.append(float(rd) if rd is not None else float('nan'))

    probe_sec = sections.get('probe', {})
    probe_x   = float(probe_sec.get('x_offset', 0.0))
    probe_y   = float(probe_sec.get('y_offset', 0.0))
    probe_z   = float(probe_sec.get('z_offset', 0.0))

    # --- parse klippy.log ---------------------------------------------------
    z_offset, probe_rows = parse_log(args.log)

    # --- emit Octave script -------------------------------------------------
    lines_out = []
    lines_out.append('% Auto-generated by extract_bed_probe.py')
    lines_out.append('% Source cfg : ' + args.cfg)
    lines_out.append('% Source log : ' + args.log)
    lines_out.append('% ' + datetime.now().strftime('%y/%m/%d %H:%M') + '   ' + os.getcwd())
    lines_out.append('')
    lines_out.append('% --- printer.cfg variables ---')

    def emit_vec_or_scalar(name, lst):
        if not lst:
            lines_out.append(f'% WARNING: {name} not found in printer.cfg')
        elif len(lst) == 1:
            lines_out.append(oct_scalar(name, lst[0]))
        else:
            lines_out.append(oct_row_vec(name, lst))

    emit_vec_or_scalar('delta_radius',    delta_radius)
    emit_vec_or_scalar('delta_angles',    delta_angles)
    emit_vec_or_scalar('arm_lengths',     arm_lengths)
    emit_vec_or_scalar('tilt_radial',     tilt_radial)
    emit_vec_or_scalar('tilt_tangential', tilt_tangential)

    lines_out.append('')
    lines_out.append(oct_row_vec('position_endstops', pos_endstops))
    lines_out.append(oct_row_vec('rotation_distances', rot_dists))

    lines_out.append('')
    lines_out.append('% probe offset vector [x, y, z]')
    lines_out.append(oct_row_vec('probe_offset', [probe_x, probe_y, probe_z]))

    lines_out.append('')
    lines_out.append('% --- klippy.log variables ---')

    if z_offset is not None:
        lines_out.append(oct_scalar('Z_OFFSET', z_offset))
    else:
        lines_out.append('% WARNING: Z_OFFSET not found in log')

    lines_out.append('')
    lines_out.append('% Bed probe matrix: each row is [cmd_x, cmd_y, trigger_z]')
    if probe_rows:
        lines_out.append(oct_matrix('probe', probe_rows))
    else:
        lines_out.append('% WARNING: no probe data found after last G28 (home)')
        lines_out.append('probe = [];')

    lines_out.append('')

    output = '\n'.join(lines_out) + '\n'

    with open(args.output, 'w') as fh:
        fh.write(output)

    print(f'Wrote {len(probe_rows)} probe point(s) to {args.output}')
    if z_offset is not None:
        print(f'Z_OFFSET = {z_offset}')
    else:
        print('Z_OFFSET not found in log – variable omitted')


if __name__ == '__main__':
    main()
