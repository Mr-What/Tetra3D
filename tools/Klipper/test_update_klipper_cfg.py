#!/usr/bin/env python3
"""
Tests for update_printer_cfg.py
Run with: python3 test_update_printer_cfg.py
"""

import os
import sys
import glob
import tempfile
import textwrap
import unittest

# We need to import the module under test
sys.path.insert(0, os.path.dirname(__file__))
from update_printer_cfg import parse_update_cfg, merge

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def run_merge(printer_text, update_text):
    """Run parse + merge on raw strings and return the merged text."""
    printer_lines = (textwrap.dedent(printer_text)).splitlines(keepends=True)
    update_lines  = (textwrap.dedent(update_text)).splitlines(keepends=True)
    update_sections, section_order = parse_update_cfg(update_lines)
    merged_lines = merge(printer_lines, update_sections, section_order)
    return ''.join(merged_lines)


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestBasicReplacement(unittest.TestCase):

    def test_simple_value_replacement(self):
        printer = """\
            [stepper_x]
            step_pin: PA1
            dir_pin: PA2
            microsteps: 16
        """
        update = """\
            [stepper_x]
            microsteps: 32
        """
        out = run_merge(printer, update)
        self.assertIn('microsteps: 32', out)
        self.assertNotIn('microsteps: 16', out)
        # Other keys untouched
        self.assertIn('step_pin: PA1', out)
        self.assertIn('dir_pin: PA2', out)

    def test_equals_separator(self):
        """update.cfg may use = instead of :"""
        printer = """\
            [extruder]
            nozzle_diameter: 0.400
        """
        update = """\
            [extruder]
            nozzle_diameter = 0.600
        """
        out = run_merge(printer, update)
        self.assertIn('nozzle_diameter = 0.600', out)
        self.assertNotIn('nozzle_diameter: 0.400', out)

    def test_comments_preserved(self):
        printer = """\
            # This is a header comment
            [stepper_x]
            # step pin comment
            step_pin: PA1
            microsteps: 16  # inline comment
        """
        update = """\
            [stepper_x]
            step_pin: PB1
        """
        out = run_merge(printer, update)
        self.assertIn('# This is a header comment', out)
        self.assertIn('# step pin comment', out)
        self.assertIn('step_pin: PB1', out)
        # inline comment on unchanged line survives
        self.assertIn('microsteps: 16  # inline comment', out)

    def test_blank_lines_preserved(self):
        printer = """\
            [stepper_x]
            step_pin: PA1

            dir_pin: PA2
        """
        update = """\
            [stepper_x]
            step_pin: PB1
        """
        out = run_merge(printer, update)
        lines = out.splitlines()
        # There should still be an empty line between the replaced key and dir_pin
        self.assertIn('', lines)

    def test_multiple_sections(self):
        printer = """\
            [stepper_x]
            microsteps: 16

            [extruder]
            nozzle_diameter: 0.4
        """
        update = """\
            [stepper_x]
            microsteps: 32

            [extruder]
            nozzle_diameter: 0.6
        """
        out = run_merge(printer, update)
        self.assertIn('microsteps: 32', out)
        self.assertIn('nozzle_diameter: 0.6', out)
        self.assertNotIn('microsteps: 16', out)
        self.assertNotIn('nozzle_diameter: 0.4', out)


class TestMultilineValues(unittest.TestCase):

    def test_multiline_replaced(self):
        printer = """\
            [bed_screws]
            screw1: 30,30
            screw2: 270,30
            gantry_corners:
             -60,-10
             360,370
        """
        update = """\
            [bed_screws]
            gantry_corners:
             0,0
             300,300
        """
        out = run_merge(printer, update)
        self.assertIn('0,0', out)
        self.assertIn('300,300', out)
        # Old continuation lines gone
        self.assertNotIn('-60,-10', out)
        self.assertNotIn('360,370', out)

    def test_single_line_replacing_multiline(self):
        printer = """\
            [resonance_tester]
            probe_points:
             100,100,20
             200,200,20
        """
        update = """\
            [resonance_tester]
            probe_points: 150,150,20
        """
        out = run_merge(printer, update)
        self.assertIn('probe_points: 150,150,20', out)
        self.assertNotIn('100,100,20', out)
        self.assertNotIn('200,200,20', out)


class TestMissingKeys(unittest.TestCase):

    def test_new_key_appended_to_existing_section(self):
        printer = """\
            [extruder]
            nozzle_diameter: 0.4
        """
        update = """\
            [extruder]
            max_extrude_only_distance: 200
        """
        out = run_merge(printer, update)
        self.assertIn('max_extrude_only_distance: 200', out)
        # Should appear after the section header
        lines = out.splitlines()
        extruder_idx = next(i for i, l in enumerate(lines) if '[extruder]' in l)
        new_key_idx   = next(i for i, l in enumerate(lines)
                             if 'max_extrude_only_distance' in l)
        self.assertGreater(new_key_idx, extruder_idx)

    def test_new_section_appended(self):
        printer = """\
            [stepper_x]
            microsteps: 16
        """
        update = """\
            [extruder]
            nozzle_diameter: 0.6
        """
        out = run_merge(printer, update)
        self.assertIn('[extruder]', out)
        self.assertIn('nozzle_diameter: 0.6', out)

    def test_new_section_before_save_config(self):
        printer = """\
            [stepper_x]
            microsteps: 16

            #*# <---------------------- SAVE_CONFIG ---------------------->
            #*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
            #*#
            #*# [stepper_x]
            #*# microsteps: 16
        """
        update = """\
            [extruder]
            nozzle_diameter: 0.6
        """
        out = run_merge(printer, update)
        save_pos    = out.find('SAVE_CONFIG')
        new_sec_pos = out.find('[extruder]')
        self.assertGreater(save_pos, 0)
        self.assertGreater(new_sec_pos, 0)
        self.assertLess(new_sec_pos, save_pos,
                        "New section should appear before SAVE_CONFIG block")


class TestSaveConfigProtection(unittest.TestCase):

    def test_save_config_block_untouched(self):
        printer = """\
            [stepper_x]
            microsteps: 16

            #*# <---------------------- SAVE_CONFIG ---------------------->
            #*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
            #*#
            #*# [stepper_x]
            #*# microsteps: 16
        """
        update = """\
            [stepper_x]
            microsteps: 32
        """
        out = run_merge(printer, update)
        # The live section should be updated
        lines = out.splitlines()
        save_idx = next(i for i, l in enumerate(lines) if 'SAVE_CONFIG' in l)
        live_lines = '\n'.join(lines[:save_idx])
        saved_lines = '\n'.join(lines[save_idx:])
        self.assertIn('microsteps: 32', live_lines)
        # The SAVE_CONFIG block still has the old value (untouched)
        self.assertIn('microsteps: 16', saved_lines)

    def test_keys_in_save_config_not_modified(self):
        printer = """\
            [extruder]
            pid_Kp: 20.0

            #*# <---------------------- SAVE_CONFIG ---------------------->
            #*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
            #*#
            #*# [extruder]
            #*# pid_Kp: 18.5
        """
        update = """\
            [extruder]
            pid_Kp: 25.0
        """
        out = run_merge(printer, update)
        self.assertIn('pid_Kp: 25.0', out)
        self.assertIn('pid_Kp: 18.5', out)   # SAVE_CONFIG copy unchanged
        self.assertNotIn('pid_Kp: 20.0', out) # original replaced


class TestCLIIntegration(unittest.TestCase):
    """Smoke test through the actual script entry point."""

    def _run_script(self, printer_text, update_text):
        with tempfile.TemporaryDirectory() as td:
            pcfg = os.path.join(td, 'printer.cfg')
            ucfg = os.path.join(td, 'update.cfg')
            with open(pcfg, 'w') as f:
                f.write(textwrap.dedent(printer_text))
            with open(ucfg, 'w') as f:
                f.write(textwrap.dedent(update_text))

            # Run main() via subprocess-style argv injection
            old_argv = sys.argv[:]
            sys.argv = ['update_printer_cfg.py', pcfg, ucfg]
            try:
                import update_printer_cfg
                update_printer_cfg.main()
            except SystemExit as e:
                if e.code != 0:
                    raise
            finally:
                sys.argv = old_argv

            with open(pcfg, 'r') as f:
                result = f.read()

            # Verify backup exists
            backups = glob.glob(pcfg + '.*')
            self.assertEqual(len(backups), 1,
                             "Expected exactly one backup file")

            return result

    def test_cli_creates_backup_and_merges(self):
        out = self._run_script(
            printer_text="""\
                [stepper_x]
                microsteps: 16
            """,
            update_text="""\
                [stepper_x]
                microsteps: 32
            """,
        )
        self.assertIn('microsteps: 32', out)


if __name__ == '__main__':
    unittest.main(verbosity=2)
