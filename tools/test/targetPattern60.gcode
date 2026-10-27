PRINT_START EXTRUDER_TEMP=230  ; standard heat up, home, wipe nozzle for tetra

;SET_GCODE_VARIABLE MACRO=USER_VARS VARIABLE=target_de VALUE=0.063 ; mm extrusion/mm movement
;SET_GCODE_VARIABLE MACRO=USER_VARS VARIABLE=target_dr VALUE=20

G92 E0 ; set current extruder position to 0
M83 ; relative position extrusion mode
G92 E0 ; set current extruder position to 0

; For max_extrude_cross_section 1.0, max E is roughly 4mm / 10mm of movement.
; To get a .6mm wide line at height 0.25mm needs 6.24 extrusion per 100mm line
; r=60mm quarter arc, 94mm, ~ 5.88
;   40                       ~ 3.92 ...
;   10                       ~ 1.96
; 10 mm line, ~ .624


G0 Y63 Z3 F3000 E4
G1 Z.1 F1000 ; purge a little
G0 Y60 ; wipe

; quadrant II, try .6mm line at .25 height
G0 Z0.25  ; set Z 
G3 X-60 Y0 I0 J-60 E6 ; CCW
G1 X-40 E1
G2 X0 Y40 I40 J0 E4
G1 Y20 E1
G3 X-20 Y0 I0 J-20 E2
G1 X0 E1

G1 Y20 E1 F2000
G2 X20 Y0 I0 J-20 E2
G1 X40 E1
G3 X0 Y40 I-40 J0 E4
G1 X0 Y60 E1
G2 X60 Y0 I0 J-60 E6

G1 Z8 E-2
G1 X-60 Y0 E-1 F6000
G1 Z1 E4
G0 Z.2 F1000

G3 X0 Y-60 I60 J0 F3000 E6
G1 Y-40 E1
G2 X-40 Y0 I0 J40 E4
G1 X-20 E1
G3 X0 Y-20 I20 J0 E2
G1 Y0 E1

G1 X20 F4000 E1
G2 X0 Y-20 I-20 J0 E2
G1 X0 Y-40 E1
G3 X40 Y0 I0 J40 E4
G1 X60 E1
G2 X0 Y-60 I-60 J0 E6

PRINT_DONE
