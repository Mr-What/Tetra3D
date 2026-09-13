PRINT_START EXTRUDER_TEMP=230  ; standard heat up, home, wipe nozzle for tetra

G92 E0 ; set current extruder position to 0
M83 ; relative position extrusion mode
G92 E0 ; set current extruder position to 0

; For max_extrude_cross_section 1.0, max E is roughly 4mm / 10mm of movement.
; To get a .6mm wide line at height 0.25mm needs 6.24 extrusion per 100mm line
; r=80mm quarter arc, 126mm, ~ 8
;   60                       ~ 6 ...
;   10                       ~ 1
; 10 mm line, ~ .6
; 20 mm line, ~ 1.3 ...

;G0 X0 Y100
;G0 Z0.25 F2000
;G2 X100 Y0 I0 J-100 E9 F3000  ;1 CW, arc center(0,100-100) end at 100,0 start current pos
;G1 X80 E2
G0 X83 Y0 Z3 F3000
G1 Z.1 E3 F1000 ; purge a little
G0 X80 Y0 ; wipe

; quadrant I, try .6mm line at .25 height
G0 Z0.25  ; set Z 
G3 X0 Y80 I-80 J0 E8 ; CCW, R=80 80,0 to 0,80
G1 Y60 E1.3
G2 X60 Y0 I0 J-60 E6
G1 X40 E1.3
G3 X0 Y40 I-40 J0 E4
G1 Y30 E.7
G2 X30 Y0 I0 J-30 E3
G1 X20 E.7
G3 X0 Y20 I-20 J0 E2
G1 Y10 E.7
G2 X10 Y0 I0 J-10 E1
G1 X0 Y0 E.7
; end of quadrant I

; quadrant IV, fat?
G1 Y-10 E2
G3 X10 Y0 I0 J10 E2
G1 X20 E1
G2 X0 Y-20 I-20 J0 E3
G1 Y-30 E1
G3 X30 Y0 I0 J30 E4
G1 X40 E1
G2 X0 Y-40 I-40 J0 E5
G1 Y-60 E2
G3 X60 Y0 I0 J60 E8
G1 X80 E2
G2 X0 Y-80 I-80 J0 E11
;G1 Y-100 E2
;G3 X100 Y0 I0 J100 E9  ; end of right half-plane

G0 Z2 E-5 F6000
G0 X0 Y0
G0 Z0.25 E5
G1 Y10 E1 F3000
G3 X-10 Y0 I0 J-10 E2
G1 X-20 E1
G2 X0 Y20 I20 J0 E3
G1 Y30 E1
G3 X-30 Y0 I0 J-30 E4
G1 X-40 E1
G2 X0 Y40 I40 J0 E5
G1 Y60 E2
G3 X-60 Y0 I0 J-60 E8
G1 X-80 E1
G2 X0 Y80 I80 J0 E11

;G1 Y100 E1
;G3 X-100 Y0 I0 J-100 E9 ; end of Q II
;G1 X-80 E2

G0 Z3 E-3 F8000  ; extra purge here, tended to leave a line
G0 X-80 Y0 E-5
G0 Z0.25 E9
G3 X0 Y-80 I80 J0 E12
G1 Y-60 E2
G2 X-60 Y0 I0 J60 E10
G1 X-40 E2
G3 X0 Y-40 I40 J0 E8
G1 Y-30 E1
G2 X-30 Y0 I0 J30 E6
G1 X-20 E1
G3 X0 Y-20 I20 J0 E5
G1 Y-10 E1
G2 X-10 Y0 I0 J10 E2 
G1 X0 E1
G0 Z2 F3000 E-3

PRINT_DONE


