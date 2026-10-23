#/usr/bin/sh -x
rsync -ave ssh ~/Tetrahedral3Dprinter/Tetra3D/KlipperCfg/printer.cfg ~/Tetrahedral3Dprinter/Tetra3D/KlipperCfg/macro*cfg ~/Tetrahedral3Dprinter/Tetra3D/KlipperCfg/probe*.cfg tetrapi:../pi/printer_data/config'
