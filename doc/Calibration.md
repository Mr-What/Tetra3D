# Tetra3D printer calibration

## New printer

### Guess initial parameters

arm_lengths are usually pretty close to measurement,
on pivot centers.

tilt_radial is usually pretty close to measured, or designed.

tilt_tangential = [0,0,0]

delta_angles = [210,330,90]

delta_radius should start close to where center of carriage arm pivot would hit the bed, if it could go that far, to center
of effector arm pivot when touching the bed.

this should be good enough to collect a bed probe.

### Initial refinements

start with 'R1' to get in the ballpark.
Make sure that your configuration, ```tetraInit.m```,
has settings for your network.
The data load commands will retrieve parts of
```klippy.log```.
```
     cd myDataDir
     td = tetraLoadCalData('myProbeFile.log');
     gp = tetraCal('R1',td,[],1);
```

Next, refine your average arm length.
```
     gp = tetraCal('A1',td,gp,1);
```     
Go back, and get independant delta radius:
```
     gp = tetraCal('R',td,gp,1);
```
Next, do independant arms,
```
gp = tetraCal('R', td, gp,1);
```
Update your ```printer.cfg``` to reflect
the settings in `gp`.
At this point, hopefully, you are calibrated enough
to do a sloppy print.
If not, do a bed mesh and use it.

### Calibration plate probe

Run macro ```HEX_OUTLINE T=230 R=86```
Replace 230 with an appropriate extruder temperature for your filament, and 86 with something slightly larger to a center to corner estimate of your of your hexagonal plate.

Glue your plate to the bed with the mark going toward tower C, the +Y direction.

Run the plate probe gcode for your plate.

### Calibration refinements

At this time, I am recommending to avoid trying to optimize
delta radius, 'R', and arm lengths, 'A' at the same time.
They are closely related, and you tend to get **overfits**.
This is where you get non-physical parameters,
that might optimize your error,
but tend to be bad interpolatns/extrapolents for parts
of the print envelope that were not directly measured.

At first, I would also leave the delta angles as designed.
When you optimize these, especially along with delta radius,
you tend to get solutions where the print center
is not close to the center of the print bed.
This leads to overfit.
I can choose a point, near the center of the envelope,
which will have towers at the designed tower angles.
Optimization of tower radius should converge near this point.

```
cp = tetraLoadPlateProbeFromLog('probe139.log'); % load cal plate probe
td = tetraLoadCalData('probe136.log',cp); % combine with bed probe
gp = tetraCal('RZT', td, [],2); % radius and tower tilt

% copy in case one of the refinements seems outlandish, and you want to re-try
igp = tetraExtractCfgParams(gp);

gp = tetraCal('AZT', td, igp,2); %   arms and tower tilt
```
Repeat the last two steps, feeding gp back into tetraCal(),
until the changes are negligible.

Update your ```printer.cfg```, repeat your plate and bed probes,
then repeat the above procedure until changes are negligible.

If they oscillate, We should add a flag to tetraCal to
start every tetraRefine with the best guess so far,
and, only then, do a RPAZT.
If it is not near the average of AZT and RZT results,
be cautious of an overfit.

