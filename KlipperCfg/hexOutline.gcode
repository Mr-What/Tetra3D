
[gcode_macro HEX_OUTLINE]
description: Draw a hex outline, good for placing calibration plates
  R -- radius
  T -- 230 temp of extruder
gcode:
    {% set r  = params.R|default(86)|float %}
    {% set t  = params.T|default(230)|float %}
    {% set c60 = 0.5 %}
    {% set s60 = 0.866 %}
    G90 ; absolute positions
    G21 ; mm
    G92 E0 ; set current extruder position to 0
    M83 ; relative position extrusion mode
    G92 E0 ; set current extruder position to 0
    M84 ; motor off
    M107 ; part fan off
    M118 Heating...
    M118 Make sure effector is over center of bed!!!
    M109 S{t} ; set extruder temp, and wait
    HOME
    G90
    M118 HEX_OUTLINE 2610130735
    G0 E8 F1000
    G4 P5000  ; give some time for user to wipe noze if desired
    G0 X{r + 4} Y0 Z20 F3000
    G0 Z.1
    G4 P100
    ; for a .6 wide line, .3 high, that is .18mm^3 filament/mm
    ; 1.75mm diameter filament is 2.4 mm^3 / mm length
    ; so, extrude .18/2.4= 0.075 mm filament per mm travel
    {% set e = r * 0.075 %}
    {% set dx = c60 * r %}
    {% set dy = s60 * r %}
    G1 X{r} Y0 E2 Z.3
    G1 X{dx} Y{dy}  E{e} F1000
    G1 X{ -dx} E{e}
    G1 X{ -r} Y0 E{e}
    G1 X{ -dx} Y{ -dy} E{e}
    G1 X{dx}  Y{ -dy} E{e}
    G1 X{r} Y0 E{e}
    ; do it again, a little larger
    {% set r = r + 0.3 %}
    {% set dx = c60 * r %}
    {% set dy = s60 * r %}
    G0 X{r} 
    G1 X{dx} Y{dy}  E{e} F1000
    G1 X{ -dx} E{e}
    G1 X{ -r} Y0 E{e}
    G1 X{ -dx} Y{ -dy} E{e}
    G1 X{dx}   E{e}
    G1 X{r} Y0 E{e}
    G1 Z15 X{r+3} E-2 F3000
    G4 P1000
    G0 X0 Y0
    PRINT_DONE
