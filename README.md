# Tetra3D
Tetrahedral 3D printer

Initial model was based off of definition of length of base edges, and tower arm lengths.
From this information, the location of an Apex point could be solved.
However, It seemed more natural for me to simply use the Apex location as an independent variable.
With the assertion that the coordinate origin would be at the y-centroid, all other parameters
are trivial to solve for.
Either way, we have a 12 parameter initial kinematic model:
    (3) base lengths
    (3) tower lengths XOR Apex position definition
    (3) rod lengths
    (3) endstop offsets for tower servos (implied)

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

