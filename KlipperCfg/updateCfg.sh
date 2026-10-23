#!/usr/bin/sh -x
# update config on printer from git clone folder
LOCAL_CFG="/home/aaron/Tetrahedral3Dprinter/Tetra3D/KlipperCfg"
cd ${LOCAL_CFG}
rsync -ave ssh printer.cfg macro*cfg probe*.cfg tetrapi:../pi/printer_data/config
