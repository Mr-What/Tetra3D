#!/usr/bin/env python3
"""
extract_bed_probe.py

Parse a klippy.log file and emit an Octave script that defines a set of
variables in the current workspace – inspired by FORTRAN namelists.

The printer configuration is read from the config block that Klipper writes
at the top of every log session (delimited by '===== Config file =====' and
'======================='), so no separate printer.cfg argument is needed.

Usage:
    python3 extract_bed_probe.py <klippy.log> <output.m>

Dependencies: only the Python standard library (already present in any
Klipper installation).
"""

import argparse
import re
import sys


# ---------------------------------------------------------------------------
# printer.cfg parser  (operates on a list of text lines)
# ---------------------------------------------------------------------------

def parse_cfg_from_lines(lines):
    """
    Minimal Klipper-style INI parser.  Accepts both '=' and ':' as
    key/value separators.  Handles indented continuation lines.

    Returns { section_name_lower: { key_lower: value_string } }.
    """
    sections = {}
    current_section = None
    current_key = None

    for raw in lines:
        line = raw.rstrip('\n')
        stripped = line.strip()

        # Blank or comment line – resets continuation
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

        if current_section is None:
            continue

        # Continuation line – raw line starts with whitespace
        if line and line[0] in (' ', '\t') and current_key is not None:
            sections[current_section][current_key] += ' ' + stripped
            continue

        # key = value  OR  key: value  (split on first = or :)
        m = re.match(r'^([^=:]+)[=:](.*)', stripped)
        if m:
            key   = m.group(1).strip().lower()
            value = m.group(2).strip()
            # Strip inline comments
            value = re.sub(r'\s*[#;].*$', '', value).strip()
            current_key = key
            sections[current_section][current_key] = value
            continue

        current_key = None

    return sections


def extract_cfg_block_from_log(log_lines):
    """
    Klipper writes the full printer.cfg into the log at every startup,
    surrounded by:
        ===== Config file =====
        ...
        =======================

    There may be multiple sessions in one log file (Klipper restarts).
    Return the lines of the LAST such block, excluding the delimiter lines.
    """
    START = '===== Config file ====='
    END   = '======================='

    last_block_lines = []
    in_block = False
    current_block = []

    for line in log_lines:
        s = line.strip()
        if s == START:
            in_block = True
            current_block = []
            continue
        if s == END and in_block:
            in_block = False
            last_block_lines = current_block[:]
            continue
        if in_block:
            current_block.append(line)

    return last_block_lines


def parse_float_list(s):
    """Parse a comma- or whitespace-separated string into a list of floats."""
    if s is None:
        return []
    result = []
    for t in re.split(r'[\s,]+', s.strip()):
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
    return f"{name} = {value!r};"

def oct_row_vec(name, values):
    inner = ', '.join(repr(float(v)) for v in values)
    return f"{name} = [{inner}];"

def oct_matrix(name, rows):
    if not rows:
        return f"{name} = [];"
    row_strs = [', '.join(repr(float(v)) for v in row) for row in rows]
    inner = ';\n        '.join(row_strs)
    return f"{name} = [{inner}];"


# ---------------------------------------------------------------------------
# klippy.log runtime data parser
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


def parse_log_runtime(log_lines):
    """
    Scan the log for:
      - most recent 'echo: Z_OFFSET: <val>'
      - probe triplets [cmd_x, cmd_y, trigger_z] after the last 'Recv: G28'

    Returns (z_offset_or_None, [[x,y,z], ...])
    """
    # Last Z_OFFSET echo in the whole file
    z_offset = None
    for line in log_lines:
        m = RE_Z_OFFSET.search(line)
        if m:
            z_offset = float(m.group(1))

    # Index of last G28
    last_g28 = None
    for i, line in enumerate(log_lines):
        if RE_G28.search(line):
            last_g28 = i

    probe_rows = []
    if last_g28 is not None:
        pending_xy = None
        for line in log_lines[last_g28:]:
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
        description='Extract Klipper bed-probe data from klippy.log and write an Octave script.'
    )
    ap.add_argument('log',    help='Path to klippy.log')
    ap.add_argument('output', help='Path to output .m file')
    args = ap.parse_args()

    with open(args.log, 'r') as fh:
        log_lines = fh.readlines()

    # --- extract and parse the embedded config block ------------------------
    cfg_lines = extract_cfg_block_from_log(log_lines)
    if not cfg_lines:
        print('WARNING: no config block found in log – printer.cfg variables will be missing',
              file=sys.stderr)

    sections = parse_cfg_from_lines(cfg_lines)

    printer = sections.get('printer', {})
    delta_radius    = parse_float_list(printer.get('delta_radius'))
    delta_angles    = parse_float_list(printer.get('delta_angles') or printer.get('delta_angle'))
    arm_lengths     = parse_float_list(printer.get('arm_lengths')  or printer.get('arm_length'))
    tilt_radial     = parse_float_list(printer.get('tilt_radial'))
    tilt_tangential = parse_float_list(printer.get('tilt_tangential'))

    pos_endstops = []
    rot_dists    = []
    for s in ('stepper_a', 'stepper_b', 'stepper_c'):
        sec = sections.get(s, {})
        pe  = sec.get('position_endstop')
        rd  = sec.get('rotation_distance')
        pos_endstops.append(float(pe) if pe is not None else float('nan'))
        rot_dists.append(float(rd)    if rd is not None else float('nan'))

    probe_sec = sections.get('probe', {})
    probe_x   = float(probe_sec.get('x_offset', 0.0))
    probe_y   = float(probe_sec.get('y_offset', 0.0))
    probe_z   = float(probe_sec.get('z_offset', 0.0))

    # --- parse runtime log data ---------------------------------------------
    z_offset, probe_rows = parse_log_runtime(log_lines)

    # --- emit Octave script -------------------------------------------------
    out = []
    out.append('% Auto-generated by extract_bed_probe.py')
    out.append('% Source log : ' + args.log)
    out.append('')
    out.append('% --- printer.cfg variables (from embedded config block) ---')

    def emit(name, lst):
        if not lst:
            out.append(f'% WARNING: {name} not found in config')
        elif len(lst) == 1:
            out.append(oct_scalar(name, lst[0]))
        else:
            out.append(oct_row_vec(name, lst))

    emit('delta_radius',    delta_radius)
    emit('delta_angles',    delta_angles)
    emit('arm_lengths',     arm_lengths)
    emit('tilt_radial',     tilt_radial)
    emit('tilt_tangential', tilt_tangential)

    out.append('')
    out.append(oct_row_vec('position_endstops',  pos_endstops))
    out.append(oct_row_vec('rotation_distances', rot_dists))

    out.append('')
    out.append('% probe offset vector [x_offset, y_offset, z_offset]')
    out.append(oct_row_vec('probe_offset', [probe_x, probe_y, probe_z]))

    out.append('')
    out.append('% --- runtime log variables ---')

    if z_offset is not None:
        out.append(oct_scalar('Z_OFFSET', z_offset))
    else:
        out.append('% WARNING: Z_OFFSET not found in log')

    out.append('')
    out.append('% Bed probe matrix: each row is [cmd_x, cmd_y, trigger_z]')
    if probe_rows:
        out.append(oct_matrix('probe', probe_rows))
    else:
        out.append('% WARNING: no probe data found after last G28')
        out.append('probe = [];')

    out.append('')

    with open(args.output, 'w') as fh:
        fh.write('\n'.join(out) + '\n')

    print(f'Wrote {len(probe_rows)} probe point(s) to {args.output}')
    if z_offset is not None:
        print(f'Z_OFFSET = {z_offset}')
    else:
        print('Z_OFFSET not found in log – variable omitted')


if __name__ == '__main__':
    main()
