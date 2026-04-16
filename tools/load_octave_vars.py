"""
load_octave_vars.py

Parse an Octave script that defines variables as assignment statements and
return a SimpleNamespace whose attributes mirror those variables.
    *** This is the python version of loadAsStruct.m ***

Supported RHS types:
  - Scalars:          x = 3.14;
  - Row vectors:      v = [1, 2, 3];   or  v = [1 2 3];
  - Matrices:         M = [1, 2; 3, 4];
  - Strings:          s = 'hello';
  - Multiple assigns on one line:  x = 1.0;  y = 2.0;

Usage:
    from octave_vars import load_octave_vars
    ns = load_octave_vars('mydata.m')
    print(ns.delta_radius)
    print(ns.probe)          # list of lists for a matrix
"""

import ast
import re
import warnings
from types import SimpleNamespace


# Match a single assignment:  name = <rhs up to next ; or end>
# RHS may itself contain brackets with semicolons (matrix row separators),
# so we do a bracket-aware split rather than a plain split on ';'.

def _split_statements(line):
    """
    Split a line into individual 'name = value' strings, respecting
    bracket nesting so that semicolons inside [...] are not treated as
    statement separators.
    """
    statements = []
    depth = 0
    current = []
    for ch in line:
        if ch in '([{':
            depth += 1
            current.append(ch)
        elif ch in ')]}':
            depth -= 1
            current.append(ch)
        elif ch == ';' and depth == 0:
            stmt = ''.join(current).strip()
            if stmt:
                statements.append(stmt)
            current = []
        else:
            current.append(ch)
    stmt = ''.join(current).strip()
    if stmt:
        statements.append(stmt)
    return statements


def _parse_value(raw):
    """
    Convert an Octave RHS string to a Python value.
    Returns a float/int, list (vector), list-of-lists (matrix), or str.
    """
    s = raw.strip()

    # Quoted string  'text'  or  "text"
    if (s.startswith("'") and s.endswith("'")) or \
       (s.startswith('"') and s.endswith('"')):
        return s[1:-1]

    # Matrix / vector  [ ... ]
    if s.startswith('[') and s.endswith(']'):
        inner = s[1:-1].strip()
        if not inner:
            return []

        # Split into rows on semicolons (already outside brackets at this level)
        row_strs = [r.strip() for r in inner.split(';')]
        rows = []
        for row_str in row_strs:
            if not row_str:
                continue
            # Elements separated by commas and/or whitespace
            tokens = re.split(r'[\s,]+', row_str.strip())
            elements = [ast.literal_eval(t) for t in tokens if t]
            rows.append(elements)

        if len(rows) == 1:
            # Row vector – return flat list
            return rows[0]
        return rows  # Matrix – list of lists

    # Scalar (int or float, possibly with unary sign)
    return ast.literal_eval(s)


def load_octave_vars(path):
    """
    Parse an Octave variable-definition script and return a SimpleNamespace.
    Each variable becomes an attribute.  Matrices become list-of-lists;
    vectors become flat lists; scalars become int/float; strings become str.
    """
    ns = {}

    with open(path, 'r') as fh:
        for raw_line in fh:
            # Strip inline comments (% or #)
            line = re.sub(r'[%#].*', '', raw_line).strip()
            if not line:
                continue

            # A line may contain multiple semicolon-separated statements
            for stmt in _split_statements(line):
                stmt = stmt.strip()
                if not stmt:
                    continue

                m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$', stmt, re.DOTALL)
                if not m:
                    continue

                name, rhs = m.group(1), m.group(2).strip()
                try:
                    ns[name] = _parse_value(rhs)
                except Exception as e:
                    warnings.warn(f"Could not parse variable '{name}' = {rhs!r}: {e}")

    return SimpleNamespace(**ns)


def octave_vars_to_dict(path):
    """Same as load_octave_vars but returns a plain dict."""
    return vars(load_octave_vars(path))


if __name__ == '__main__':
    import sys, pprint
    if len(sys.argv) != 2:
        print(f'Usage: {sys.argv[0]} <file.m>')
        sys.exit(1)
    ns = load_octave_vars(sys.argv[1])
    pprint.pprint(vars(ns))

"""
initial version produced by perplexity.ai prompt:
Would it be possible to write a python parser that takes one of these octave scripts that defines variables, create a python structure containing fields whose name are the same as the octave variables, containing the same values? This would give me the same capability to store data as octave commands, and parse that data in python instead of octave.
"""
