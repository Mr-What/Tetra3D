<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# I am waiting for connectors to arrive from aliexpress.  Are there some simpler tests I could do.  Can I report ensdtop and probe switch status?  Is there a command to move a given stepper a given amount, even though steppers have yet to be homed?

Yes, there are several useful things you can test before wiring heaters or doing full homing:

### 1. Query endstop and probe state

You can read the logical state of your endstop and probe inputs with G‑code:

- Endstops (all at once):

```gcode
QUERY_ENDSTOPS
```

This prints something like `x:open y:open z:TRIGGERED` in the console.[^1][^2]
- Probe input specifically:

```gcode
QUERY_PROBE
```

That reports whether the probe switch is currently triggered.[^3]

You can send these either via your Moonraker console or via `curl`:

```bash
curl "http://localhost:7125/printer/gcode/script?script=QUERY_ENDSTOPS"
curl "http://localhost:7125/printer/gcode/script?script=QUERY_PROBE"
```

That lets you confirm the MCU pin mapping and logic (inverted/not) as soon as you start wiring switches, even before motors move.[^4][^1]

### 2. Move steppers without homing

Klipper has two tools for moving steppers “unsafely” (without homing):

- `MANUAL_STEPPER`: for steppers defined in `[manual_stepper]` sections.
- `FORCE_MOVE`: to move a *cartesian axis* without homing (less useful for your custom kinematics, more for Z‑down‑a‑bit hacks).[^5][^6]

For direct per‑motor testing, define extra sections:

```ini
[manual_stepper test_a]
step_pin: PB13
dir_pin: !PB12
enable_pin: !PB14
microsteps: 16
rotation_distance: 40
```

Then you can move that motor regardless of homing state:

```gcode
MANUAL_STEPPER STEPPER=test_a SET_POSITION=0
MANUAL_STEPPER STEPPER=test_a MOVE=10 SPEED=20
```

No kinematics are involved, no boundary checks are performed—great for bring‑up on a bare bench.[^7][^5]

Because your `tilted_delta` steppers are already used by kinematics (`[stepper_a/b/c]`), you probably don’t want to reuse the same pins in `[manual_stepper]`. For bench‑only tests, it can be simpler to temporarily comment out `kinematics: tilted_delta`, define one `[manual_stepper]` on a known good axis, and confirm direction/motion, then restore the kinematics config once you’re confident in the wiring.

Once you actually wire your switches and steppers, do you want a concrete mini‑plan (exact config and commands) for first‑power‑on tests with endstops and a single tower motor?
<span style="display:none">[^10][^11][^12][^13][^14][^15][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://www.klipper3d.org/Config_checks.html

[^2]: https://mmone.github.io/klipper/G-Codes.html

[^3]: https://www.klipper3d.org/BLTouch.html

[^4]: https://klipper.discourse.group/t/probe-status-in-module/17865

[^5]: https://www.klipper3d.org/G-Codes.html

[^6]: https://klipper.discourse.group/t/moving-z-before-homing-or-other/1037

[^7]: https://klipper.discourse.group/t/manual-stepper-problems/412

[^8]: https://sean-dearing.gitbook.io/klipper-installation-for-anycubic-vyper/configuration-checks/verify-endstops

[^9]: https://www.reddit.com/r/klippers/comments/18ekb84/y_endstop_is_always_triggered/

[^10]: https://www.klipper3d.org/Endstop_Phase.html

[^11]: https://klipper.discourse.group/t/query-endstops-doesnt-save-status/21962

[^12]: https://github.com/Klipper3d/klipper/issues/710

[^13]: https://github.com/TypQxQ/Query-Endstop-Continuesly-in-Klipper

[^14]: https://www.reddit.com/r/klippers/comments/1l0dt2h/how_do_you_call_printerquery_endstopslast_queryz/

[^15]: https://www.klipper3d.org/Status_Reference.html

