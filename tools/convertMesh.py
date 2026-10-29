#!/opt/pymeshlab/bin/python3
"""convertMesh.py - convert a mesh file (e.g. OBJ) to a different format,
   (e.g. STL) using pymeshlab.

usage: convertMesh.py input.obj output.stl
"""

import sys

import pymeshlab as pml

def main():
    # sys.argv is the list of command-line words:
    #   [ "convertMesh.py", "input.obj", "output.stl" ]
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} input.obj output.stl")

    infile, outfile = sys.argv[1], sys.argv[2]

    try:
        ms = pml.MeshSet()
        ms.load_new_mesh(infile)
        ms.save_current_mesh(outfile)
    except Exception as e:
        sys.exit(f"convertMesh: error: {e}")

    m = ms.current_mesh()
    print(f"converted {infile} -> {outfile} "
          f"({m.vertex_number()} vertices, {m.face_number()} faces)")

if __name__ == "__main__":
    main()
