M118 Starting hex_outliine.  Make sure your are HOME'd and extruder temp is correct
M107 ; part fan off
G90

;SET_PATTERN_SCALE SCALE=70

G0 X0 Y0 Z10 F2000
SCALED_G1 X=1 Y=0 E=0
G0 Z=0.2 E.3
;SCALED_G1 X=1 Y=0 E=.01
SCALED_G1 X=.866 Y=.5 E=0.075
SCALED_G1 X=-.866 Y=.5 E=0.075
SCALED_G1 X=-1 Y=0 E=0.075
SCALED_G1 X=-.866 Y=-.5 E=0.075
SCALED_G1 X=.866 Y=-.5 E=0.075
SCALED_G1 X=1 Y=0 E=0.075
SCALED_G1 X=.866 Y=.5 E=0.05  ; re-draw first segment, often no plastic flow when starting

SET_PATTERN_SCALE ADD=0.3
SCALED_G1 X=.866 Y=.5 E=0.02  ; hop out for next pass
SCALED_G1 X=-.866 Y=.5 E=0.075
SCALED_G1 X=-1 Y=0 E=0.075
SCALED_G1 X=-.866 Y=-.5 E=0.075
SCALED_G1 X=.866 Y=-.5 E=0.075
SCALED_G1 X=1 Y=0 E=0.075
SCALED_G1 X=.866 Y=.5 E=0.075
SCALED_G1 X=-.866 Y=.5 E=0  ; re-draw first segment, often no plastic flow when starting

HEATERS_OFF
G0 Z10 E-2 F6000
G4 P800 ; let filament harden a bit
G0 Z50 X0 Y0
MOTORS_OFF
