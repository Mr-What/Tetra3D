; probe all dimples initial 3D printed calibration plate
;   omit dimples marked with ; for reduced dimple count set
;SET_GCODE_VARIABLE MACRO=_CROSS_PROBE_STATE VARIABLE=stop VALUE=0.3
;SET_GCODE_VARIABLE MACRO=_CROSS_PROBE_STATE VARIABLE=initial_step VALUE=2
; minimize travel between probes.  z offset more likely to stay above plate
HOME
TLOG PREFIX="DIMPLE" MSG="starting probe for plate A"
G0 Z12 F3000
DIMPLE_PROBE X0=0   Y0=0
DIMPLE_PROBE X0=0   Y0=20     ; prune for less probes
DIMPLE_PROBE X0=-20 Y0=20
DIMPLE_PROBE X0=-20 Y0=0     ; prune for less probes
DIMPLE_PROBE X0=-20 Y0=-20
DIMPLE_PROBE X0=0   Y0=-20     ; prune for less probes
DIMPLE_PROBE X0=20  Y0=-20
DIMPLE_PROBE X0=20  Y0=0     ; prune for less probes
DIMPLE_PROBE X0=20  Y0=20
DIMPLE_PROBE X0=40  Y0=20     ; prune for less probes
DIMPLE_PROBE X0=40  Y0=40
DIMPLE_PROBE X0=20  Y0=40     ; prune for less probes
DIMPLE_PROBE X0=20  Y0=60
DIMPLE_PROBE X0=0   Y0=60     ; prune for less probes
DIMPLE_PROBE X0=0   Y0=40
DIMPLE_PROBE X0=-20 Y0=40     ; prune for less probes
DIMPLE_PROBE X0=-20 Y0=60
DIMPLE_PROBE X0=-40 Y0=40
DIMPLE_PROBE X0=-40 Y0=20     ; prune for less probes
DIMPLE_PROBE X0=-60 Y0=20
DIMPLE_PROBE X0=-60 Y0=0     ; prune for less probes
DIMPLE_PROBE X0=-40 Y0=0
DIMPLE_PROBE X0=-40 Y0=-20     ; prune for less probes
DIMPLE_PROBE X0=-60 Y0=-20
DIMPLE_PROBE X0=-40 Y0=-40
DIMPLE_PROBE X0=-20 Y0=-40     ; prune for less probes
DIMPLE_PROBE X0=-20 Y0=-60
DIMPLE_PROBE X0=0   Y0=-60     ; prune for less probes
DIMPLE_PROBE X0=0   Y0=-40
DIMPLE_PROBE X0=20  Y0=-40     ; prune for less probes
DIMPLE_PROBE X0=20  Y0=-60
DIMPLE_PROBE X0=40  Y0=-40
DIMPLE_PROBE X0=40  Y0=-20
DIMPLE_PROBE X0=60  Y0=-20
DIMPLE_PROBE X0=60  Y0=0     ; prune for less probes
DIMPLE_PROBE X0=60  Y0=20
DIMPLE_PROBE X0=40  Y0=0
G0 Z20 F6000
PRINT_DONE
