;HOME
M118 Starting hex_outliine.  Make sure your are HOME'd and extruder temp is correct
M107 ; part fan off
G90

;SET_PATTERN_SCALE SCALE=70

G92 E0 ; set current extruder position to 0
M83 ; relative position extrusion mode
G92 E0 ; set current extruder position to 0
G1 E6
G4 P3000 ; time to remove excess, if desired.

G0 X0 Y0 Z10 F2000
SCALED_G1 X=1.03 Y=0 E=0
G0 Z0.1 F6000 ; wipe
SCALED_G1 X=1 Y=0 E=0 ; wipe
G0 Z0.2 F3000
;SCALED_G1 X=1 Y=0 E=.01
SCALED_G1 X=.5  Y=.866  E=0.075
SCALED_G1 X=-.5 Y=.866  E=0.075
SCALED_G1 X=-1  Y=0     E=0.075
SCALED_G1 X=-.5 Y=-.866 E=0.075
SCALED_G1 X=.5  Y=-.866 E=0.075
SCALED_G1 X=1   Y=0     E=0.075
SCALED_G1 X=.5  Y=.866  E=0.05  ; re-draw first segment, often no plastic flow when starting

SET_PATTERN_SCALE ADD=0.3
SCALED_G1 X=.5  Y=.866  E=0 ; hop out for next pass
SCALED_G1 X=-.5 Y=.866  E=0.075
SCALED_G1 X=-1  Y=0     E=0.075
SCALED_G1 X=-.5 Y=-.866 E=0.075
SCALED_G1 X=.5  Y=-.866 E=0.075
SCALED_G1 X=1   Y=0     E=0.075
SCALED_G1 X=.5  Y=.866  E=0.075
SCALED_G1 X=-.5 Y=.866  E=0 ; repeat first segment, but no extrusion

HEATERS_OFF
G0 Z10 E-2 F6000
G4 P800 ; let filament harden a bit
G0 Z50 X0 Y0 F8000
HOMEPOS
MOTORS_OFF
