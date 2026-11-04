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

talk about new, unique ```[printer]``` parameters:\
   ~~delta_angles: 210, 330, 90~~ # do not refine
```
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

load tetra calibration data, td:
<!--  discuss this after initial cal: 
 octave> tp = tetraLoadPlateProbe('plateProbe141.log',...
         >      17*hexGrid(3), 101.2/102); % optional params -->
```
    octave> td = tetraLoadCalData('bedProbe142.log');
```

### get parameters close enough to print

Usually just 
```
    octave> gp = tetraCal('R1',td);
```

test with targetPattern.gcode and/or gridPattern.gcode.
edit gcode as necessary for your setup.

### print and measure calibration pattern

Run a bed mesh if necessary so that you can do some
basic printing.

Print a hex outline to help you place the calibration
plate near the desired location and orientation.
You will usually want a radius 1-3 mm wider than
your calibration plate to leave room for calibration
errors in a not fully calibrated printer.\
Klipper Console:
```
    SET_PATTERN_SCALE SCALE=70 ; radius(to corner) of desired hex
```
Then run ```hex_outline.gcode```

#### Run plate probe script:

Glue or clamp your calibration plate to the print bed,
as centered as possible within the hex outline.

Edit your plate probe script, like ```probePlateC.gcode```
for the spacing on your calibration plate.
find the line :
```
     DIMPLE_PROBE_SET SCALE=20
```
and change it to match the spacing between dimples on
your 37 dimples in hex pattern plate.\
...or...  remove that line and enter the above by
and at the klipper/mainsail console before running
a plate probe script that does **not** set the spacing,
like you did for the hex outline, but with the 
```DIMPLE_PROBE_SET SCALE=17``` command.

#### load full calibration data

You may want to re-run a bed probe with the same
parameters used for the plate probe, if they have changed.

Load all calibration data:
```
    octave> tp = tetraLoadPlateProbe('plateProbe141.log',...
          >      17*hexGrid(3), 101.2/102); % optional params

    octave> td = tetraLoadCalData('bedProbe142.log',tp);
```

### Full calibration

You may want to do some basic refinements to your
parameters before attempting a full calibration.\
Recommended octave procedure:
```
    > gp = tetraCal('R1',td); % best scalar radius
    
    % seed with previous fit, but find best scalar arm length
    > gp = tetraCal('A1',td,gp);
    
    % refine independent radii, and tower tilt
    > gp = tetraCal('RZT',td,gp);
    
    % refine independent arm length, and tower tilt
    > gp = tetraCal('AZT',td,gp);
```
You may want to repeat the last two refinements until
they converge.

You are likely to find a closer fit to measurements
by running a ```RAZT``` full calibration.
I often get an overfit from this full calibration,
which may give me lower fit error, but it yields
a non-physical parameter set which may not be 
a good interpolant/extrapolant over the whole
print envelope.

#### check your calibration

Run another bed probe.
If many probes are more than 0.1mm from zero,
you may want to repeat the above calibration procedure,
but start with your current, refined, parameter set.
