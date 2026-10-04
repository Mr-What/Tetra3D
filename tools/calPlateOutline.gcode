; Draw an outline to make it easier to place calibration plate.
; This one is for the one where centers are at radius < 70
; Hex "radius" is 81.  This plot radius is 83
;
; for(a=0:60:355),disp(83*[cosd(a),sind(a)]);end
;   83      0      slightly smaller :  82.5 0
;   41.5   71.9                    ;  -41.3 71.5
;  -83      0
;  -41.5  -71.9
;   41.5  -71.9
G90 ; absolute positions
G21 ; mm
G92 E0 ; set current extruder position to 0
M83 ; relative position extrusion mode
G92 E0 ; set current extruder position to 0
M84 ; motor off
M105 ; part fan off
M118 Make sure effector is over center of bed!!!
M118 Heating...
M109 S230 ; set extruder temp, and wait
HOME
G0 E8 F1000
G4 P5000  ; give some time for user to wipe noze if desired
G0 X85 Y0 Z20 F3000
G0 Z.1
G4 P100
; for a .6 wide line, .3 high, that is .18mm^3 filament/mm
; 1.75mm diameter filament is 2.4 mm^3 / mm length
; so, extrude .18/2.4= 0.075 mm filament per mm travel
; sides are 87mm (same as radius), 6.4 mm filament for each side
G1 X87    Y0     E2 Z.3
G1 X43.5  Y75.3  E6.5 F1000
G1 X-43.5        E6.5
G1 X-87   Y0     E6.5
G1 X-43.5 Y-75.3 E6.5
G1 X43.5         E6.5
G1 X87    Y0     E6.5
; do it again, a little smaller
G1 X86.6   Y0 
G1 X43.3  Y73.2  E6.5
G1 X-43.3        E6.5
G1 X-86.6  Y0     E6.5
G1 X-43.3 Y-73.2 E6.5
G1 X43.3  E6.5
G1 X86.6   Y0     E6.5
G1 Z5 E-2 F3000
G4 P1000
PRINT_DONE
; *** TOO CLOSE FOR POORLY CALIBRATED PRINTER
;G1 X83    Y0     Z.3
;G1 X41.5  Y71.9  E6.3 F1000
;G1 X-41.5        E6.3 F1000
;G1 X-83   Y0     E6.3
;G1 X-41.5 Y-71.9 E6.3
;G1 X41.5         E6.3
;G1 X83    Y0     E6.3
; do it again, a little smaller
;G1 X82.5   Y0     Z.3
;G1 X41.25  Y71.4  E6.3
;G1 X-41.25        E6.3
;G1 X-82.5  Y0     E6.3
;G1 X-42.5 Y-71.4 E6.3
;G1 X41.25  E6.3
;G1 X82.5   Y0     E6.3
; sides are 85mm (same as radius), 6.4 mm filament for each side
;G1 X85    Y0     E2 Z.3
;G1 X42.5  Y73.6  E6.4 F1000
;G1 X-42.5        E6.4 F1000
;G1 X-85   Y0     E6.4
;G1 X-42.5 Y-73.6 E6.4
;G1 X42.5         E6.4
;G1 X83    Y0     E6.4
; do it again, a little smaller
;G1 X84.5   Y0     Z.3
;G1 X42.25  Y73.2  E6.3
;G1 X-42.25        E6.3
;G1 X-84.5  Y0     E6.3
;G1 X-42.25 Y-73.2 E6.3
;G1 X42.25  E6.3
;G1 X84.5   Y0     E6.3