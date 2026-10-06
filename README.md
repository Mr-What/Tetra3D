# Tetra3D
#### [Development Notes](https://github.com/Mr-What/Tetra3D/blob/master/doc/Notes/NOTES.md "Tetra development notes")

Tetrahedral 3D printer

Ideal model has all base legs the same length, where the virtual "axis of action" of the three
towers meet at a single apex point.
Ideal model would have only 3 parameters, base length, arm length, and apex height.

### klipper changes

This model is maintained as branch [tilted-delta-kinematic-dev](https://github.com/Mr-What/klipper/tree/tilted-delta-kinematics-dev "fork of klipper") off of the master klipper project.
See:
   * https://github.com/Mr-What/klipper/blob/tilted-delta-kinematics-dev/klippy/kinematics/tilted_delta.py
   * https://github.com/Mr-What/klipper/blob/tilted-delta-kinematics-dev/klippy/chelper/kin_tilted_delta.c
   * https://github.com/Mr-What/klipper/blob/tilted-delta-kinematics-dev/klippy/chelper/__init__.py

### Contents of Tetra3D

Other code for a delta printer with tilted towers, usually to form a tetrahedron, are in this, Tetra3D project.

One of the goals of this project is to minimize changes
to the klipper project.
Must calibration and analysis are done by reviewing klipper logs.
Typical work flow is to command a ```FIRMWARE_RESTART``` to get a fresh
log, do your calibration work, then bring the logfile to your host or desktop for analysis.
Results can be placed into ```.cfg``` files.

  * Analysis utilities are in the ```tools``` folder.
  * Sample configuration files are in the ```doc/KlipperCfg``` folder.

There is a significant amount of work in the form of macros,
which are in the ```doc/KlipperCfg``` folder.

### kinematics overview

The current model as implemented, can have a real dimensionality of 18.  Base positions (6), tower angles (6), arm lengths(3), and endstop positions(3).

Generally, you optimize simple parameters first, from a bed probe.
A typical sequence is:
   1. Guess tower base distance from center, measure arm lengths and endstop distance from bed.
   2. Set all parameter triplets the same as each other, according to design.
   3. probe bed
   4. calibrate base radius and endstops.
   5. starting with above params, calabrate arm lengths and endstops
   5. probe bed
   6. at this point, we hope the bed is sufficiently well calibrated to print.
   7. print and measure cal print, and/or probe calibration plate.
   8. re-probe bed
   9. at this point, calibration should be good enough to calibrate all 18 parameters simultaneous.

## Older notes

The following needs to be reviewed.
It was written before most of the work was done,
and may not be sufficiently complete or accurate.

Kinematics are solved using direction unit vectors for the towers, [Ahat;Bhat;Chat],
which need not meet the constraint that they meet at an Apex.
So, we have the option of treating this as a 15 parameter model, where
instead of an Apex/Tower-length definition (3 parameters) we can define
the directions of Ahat, Bhat, Chat with their X and Y coordinates (solve for Z=sqrt(X*X+Y*Y)).
Replacing the 3 parameter Apex definition with X and Y direction components for each of the 3
towers yields (6) parameters.
This provides a convenient, computationally efficient 15 parameter model.
The challenge will be to develop a calibration procedure which will converge on
a stable solution for 15 parameters.

Intended usage is to start by using a physical measurement for base length, rod length, and tower height.
Assert that all base legs, tower legs, and rods are the same length.  (Apex at (0,0,Z))
This is three physical measurements.
Then place the tower carriages at the home position and measure the distance to the endstop
at this level.  Three more measurements for this offset.
This is using an asserted carriage distance from the base plane, which is also measured by measuring tape.
Six more measuring tape measurements.
Set the end-stop offset parameters for this measured offset.

Do a bed-probe, then solve for best fit home offsets.
Then do more bed-probes, solving simultaneously for endstop offsets, and base  length.
Then do more bed-probes, solving simultaneously for endstop offsets, and tower length.
Then do more bed-probes, solving simultaneously for endstop offsets, and rod   length.
repeat.

When these seem stable, solve simultaneously for endstop offset, base length, tower length, and rod length.
When this seems stable, try solving simultaneously floating for 3 different base lenfgths.
Then perhaps floating both base lengths and tower lengths.
Then base length, tower length, and rod length.
Then perhaps X-Y components on Ahat, Bhat, Chat in addition to these.
May need to solve a few parameters at a time.  Lock them.  Then search others for convergence.

