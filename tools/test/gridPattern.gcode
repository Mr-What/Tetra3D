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
; hence,  5mm/100mm at .2 ;     7.5mm/100   at .3
; for y=0:10:70, x=sqrt(70*70-y*y); display([x,y,5*2*x/100,15*x/100]); end
;   70      0    7      10.5
;   69.3   10    6.9    10.4
;   67.1   20    6.7    10.1
;   63.2   30    6.3     9.5
;   57.4   40    5.7     8.6
;   49     50    4.9     7.4
;   36     60    3.6     5.4


G0 X0 Y70 Z3 F3000
G1 Z.1 E5 F1000 ; purge a little
G0 X36 Y60 Z0.2 ; wipe

G1 X-36 E3.6        F3000
G0 X-49  Y50        F6000
G1  X49       E4.9  F3000
G0  X57  Y40        F6000
G1 X-57       E5.8  F3000
G0 X-63  Y30        F6000
G1  X63       E6.4  F3000
G0  X67  Y20        F6000
G1 X-67       E6.7  F3000
G0 X-69  Y10        F6000
G1  X69       E7    F3000
G0  X70   Y0        F6000
G1 X-70       E7    F3000
G0 X-69 Y-10        F6000
G1  X69       E7    F3000
G0  X67 Y-20        F6000
G1 X-67       E6.7  F3000
G0 X-63 Y-30        F6000
G1  X63       E6.4  F3000
G0  X57 Y-40        F6000
G1 X-57       E5.8  F3000
G0 X-49 Y-50        F6000
G1 X49        E5    F3000
G0 X36  Y-60        F6000
G1 X-36       E3.6  F3000

G0 Z3 F8000
G0 X-60 Y-36
G0 Z.3 F3000 ; higher for vert lines
G1  Y36      E5.4  F3000
G0  Y49 X-50       F6000
G1 Y-49      E7.4  F3000
G0 Y-57 X-40       F6000
G1  Y57      E8.6  F3000
G0  Y63 X-30       F6000
G1 Y-63      E9.5  F3000
G0 Y-67 X-20       F6000
G1  Y67      E10   F3000
G0  Y69 X-10       F6000
G1 Y-69      E10.4 F3000
G0 Y-70   X0       F6000
G1  Y70      E10.5 F3000
G0  Y69  X10       F6000
G1 Y-69      E10.4 F3000
G0 Y-67  X20       F6000
G1  Y67      E10.1 F3000
G0  Y63  X30       F6000
G1 Y-63      E9.5  F3000
G0 Y-57  X40       F6000
G1  Y57      E8.6  F3000
G0  Y49  X50       F6000
G1 Y-49      E7.4  F3000
G0 Y-36  X60       F6000
G1  Y36      E5.4  F3000

G0 X40 Y0 Z50 F9000
PRINT_DONE


