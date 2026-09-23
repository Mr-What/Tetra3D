# Tetra3D Delta Variant Printer User's Guide

## Installation

Clone Mr-What's
[tilted-delta-kinematics-dev](https://github.com/Mr-What/klipper/tree/tilted-delta-kinematics-dev "tilted-delta-kinematics-dev branch of klipper") 
branch of klipper and build according to the
usual klipper procedures.
This branch has the two files containing the Tetra3D tilted
delta variant kinematics, and the hook to make them available
in klipper as the
```kinematics: tilted_delta``` option to the
```[printer]``` section in ```printer.cfg```.

### Configure parameters

talk about new, unique ```[printer]``` parameters:
```
   delta_angles: 210, 330, 90
   delta_radius: 167, 167 , 167
   arm_lengths: 286, 286 , 286
   tilt_radial:    13, 13, 13
   tilt_tangential: 0,  0,  0
```

and the endstop settings for each tower:
```
 [stepper_a]
   position_endstop: 479.4899
 [stepper_b]
   position_endstop: 475.4355
 [stepper_c]
   position_endstop: 474.9276
```

## Calibration

### get parameters close enough to bed probe

measure arms

guess radius

measure and guess endstops

load calibration data
```
   octave> tc = tetraLoadCalData(n);  % tetra calibration data
```
The calibration integer id, n, will default to zero if not
provided.
This sequence number is used for derived calibration data files.
The path to and/or name if these klipper log files is set
in ```tetra.logFileFmt```emacs 




### get parameters close enough to print

Usually just ```tetraCalRE```

test with targetPattern.gcode and/or gridPattern.gcode.
edit gcode as necessary for your setup.

### print and measure calibration pattern

someday, probe plate?

sequence of reduced parameter refinements.

update.  run calibration again, including print.
You should be close enough to do full, all-parameter, calibration.

Print test patterns without bed mesh.
They should be good.

re-probe to check.

