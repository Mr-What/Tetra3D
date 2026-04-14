# Tilted Delta Model
The tilted delta model has more free variables than the traditional linear delta implementatuion.  The most notable is that a tilt can be defined for each tower.  If you wish to use this model with a classic linear delta, such as the Rostock or Kossel 3D printers, simply set the tilts to zero.

These tilts can be set as part of a calibration process to compensate for imperfect printer hardware alignment.  However, these tilt parameters also allow for novel delta printer frames.  The most likely one is where the towers all tip towards a common point over the middle of the print bed, forming a tetrahedron frame as opposed to the traditional prism shape.  This constuction can be stiffer and more robust that a traditional parallel tower delta, at the expense of a smaller print envelope for the size of the printer.

## Model Parameters

The simpelest parallel tower delta model can be defined with these parameters :

1) `arm_length`
1) `delta_radius`
1) `endstop_positions` [3]

For most builds care is taken that all towers are placed at the same distance from the center of the print bed, at angles 210, 330, and 90 degrees polar, and the towers are perpendicular to the printbed.
Some more detailed models will allow for each tower to have it's own angle and radius, and perhaps a slightly different length for each effector arm.

For the tilted delta model, we allow as many parameters to be set as possable as long as they do not complicate the model, or take longer to compute.

The tilted delta model is characterized by the following parameters:

1) `arm_length` [3]
2) `delta_radius` [3]
3) `delta_angle` [3]
4) `radial_tilt` [3]
5) `tangential_tilt` [3]
6) `endstop_positions` [3]

This is a total of 18 configurable parameters.  Most users will choose to assert that some of these parameters will have a single value for that parameter group.  The most common would be the `arm_ length` parameters.  The delta arms are usually constructed with machine precision.  Setting these to a measured constant is highly recommended unless you can measure discrepency.  The general scale of a delta print is most influenced by the `arm_length` and `delta_radius` parameters.  The problem is that similar bed tram results can be derived by a ratio of these parameters.  You can get good bed probes from wrong numbers as long as they cancel each other out.  For that reason, it is recommended to to initial calibrations with a measured constant `arm_length`.  These values can be refined later if deemed beneficial in detailed calibration measurements.

These parameter names can be burdensome when using mathematical procedures.  We use the following abbreviations for these parameters in some math and procedure names.
```
	A	arm length
	R	delta radius
	P	delta angle
	Z	radial tilt, towards 0,0
	T	tangential tilt
	E	endstop positions
```
## Calibration Procedure

Measure `arm length`, `delta_radiuis` and `endstop position` to the best of your ability.  Remember that `delta radius` is measured from where the center of the carriage fulcrum would meet the print bed, if it could do so, to the center of the arm pivot when the effector is on bed center.  The current model does not include the effector offset.

Do a bed probe, and run the parameter refinement for a shared `delta_radius` and all three endstop positions.
```
	deltaParams = deltaRefineRE(dataStruct)
```
The data struct will hold all of the tilted delta parameters used when making the bed probe, and the [m,3] bed probe results, for probes at given X,Y locations [m,1:2], and the Z level result in [m,3].

I would recommend repeating the bed probe using ```deltaParamsRefined``` to check that the robot is fairly close to a workable calibration.

Repeat refinements until you get a parameter set good enough to do a print.  Print the test pattern, and make measurements. Add these measurements and a bed probe to the input data, and you can refine more parameters using routines like:
```
	deltaRefineRPE   -- refine all 3 tower positions
	deltaRefineARPE
	deltaRefine...
```
	
	
