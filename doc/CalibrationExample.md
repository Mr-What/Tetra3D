# Notes on re-calibration after maintenance

Assume klipper runs under user ```klipper```.
We are keeping local configuration in ```~klipper```.
No good reason.
The *klipper* fork with support for the *tilted_delta* printer type, branch
```tilted-delta-kinematics-dev``` of
```git@github.com:Mr-What/klipper.git```
is checked out to ```~klipper/klipper```.
The head of ```git@github.com:Mr-What/klipper.git``` is intended to track the head of the main klipper project.

At this time, we are running the analysis on our desktop,
which mounts the Raspberry Pi (RPi) filesystem using
```sshfs```.
This code, ```git@github.com:Mr-What/Tetra3D.git```
could be run on a slightly more equipped RPi, but
we are not doing this during initial development and testing.

### Calibrate probe
  1) make sure your ```[probe]
  z_offset``` is set to 0.
  1) Put a thin piece of paper, or something thinner, like celophane, below your nozzle.
  1) Issue the ```PROBE`` command.  Note the Z ordinate where it triggered.
  2) Move the nozzle up, or down, until the nozzle barely holds the thin paper.
  1) Note the Z ordinate where this happens.
  2) The difference between the ```PROBE``` report and your reading of bed level is your ```[probe] z_offset```.  Negative for hot-end sensors like mine that need to push a fraction of a mm below the bed before the hot end moves enough to trigger the probe.
  3) Repeat this experiment.  The Z ordinate reported by the ```PROBE``` should be very close to the Z ordinate when the nozzle barely releases your paper.

### Retrieve log after bed probe
Print ```Tetra3D/tools/test/bedProbe.gcode``` or similar.
Capture the log with the command:
```
> ~klipper/bin/tail_klippy_log.py /tmp/klippy.log | grep -v Stats > probe.log
```
This command will extract the printer configuration and bed probe results of the last session in the log.

### Update endstops and Delta radius

#### Calibration Groups
Calibration on all parameters simultaneously should only be done when starting with a fairly good calibration.
It is advised, with new builds, to calibrate in smaller groups
before a final calibration, which would require probes of a calibration plate or measurements of a test print.
It can be quite cumbersome to use the full names, so here is a table of abbreviations:

| code | parameters |
| ----- | ------------- |
| A | Lengths for the delta effector arms|
| R | Delta radius, close to the distance from the arm-axis on the effector to the base of each tower|
| P | Angle to each tower base.  Can leave these at ideal.  It is only needed when you need to control the exact location of the origin. |
| Z | Radial tilt, towards origin |
| T | Tangential tilt, sideways reletive to origin |
| E | Endstop location, mm along tower up from base|

#### Calibration Sequence

For a calibration on a new printer, it is recommended to start with the simpelest calibration.
This procedure will update the estimate for the average delta radius and endstop positions.
These are the most critical parameters for rough calibration.
```
octave> gp = calRE('probe.log');
```
This should create a file ```updateRE.cfg``` which
contains recommended updates to parameters in your ```printer.cfg```.
These can be merged into your active configuration with the command:
```
> ~klipper/bin/update_klipper_cfg.py printer.cfg updateRE.cfg
```

If there were significant changes, you may want to run a new probe with these updated parameters.  Although the model is very detailed, it is not complete.
Some detailed aspects of the kinematics are not modeled, hence repeating a probe after a significant change is recommended.
One set of probe data may not tell the whole story.

For smaller changes to many parameters, one may run several refinements from the same probe and/or test-print data.

### Other refinements

This is a work in progress.  There is no good answer here.
After a probe with fairly good parameters, probes within about 0.2mm of zero, I tried a sequence of refinements, touching all typical parameters.  I fed the updated parameter from one
refinement to the next.
```
> gpRE  = calRE( 'probe18.log');  % not much change, continue
> gpAE  = calAE( 'probe18.log', gpRE.p);  % refine guesses, arm-length
> gpRPE = calRPE('probe18.log', gpAE.p);  % tower positions, 6-DoF
> gpZTE = calZTE('probe18.log', gpRPE.p); % tilt
```
Note that every refinement checks endstops.  They seem to be dependant on most of the other parameters.
```gpZTE.p``` was transcribed back into ```printer.cfg```
