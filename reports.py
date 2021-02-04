#!/usr/bin/env python3
import argparse
import os
import math
import glob
import csv
import sys
from shutil import copyfile

openlane_designs = os.path.join(os.environ['OPENLANE_ROOT'], 'designs')
gds_dir = "macros/gds/"
lef_dir = "macros/lef/"

designs = ["ws2812", "vga_clock", "seven_segment_seconds", "spinet5", "asic_freq", "watch_hhmm", "challenge", "MM2hdmi", "multi_project_harness"]

def report(designs):
    for design in designs:
        if args.skip_design is not None:
            if design in args.skip_design:
                continue
        run_dir = os.path.join(openlane_designs, design, 'runs/*')
        list_of_files = glob.glob(run_dir)
        latest_run = max(list_of_files, key=os.path.getctime)
        date = os.path.basename(latest_run)
        print("## %s : DESIGN=%s RUN_DATE=%s" % (design, design, date))
        print()

        summary_file = os.path.join(latest_run, 'reports', 'final_summary_report.csv')

        # print pertinent summary - only interested in errors atm
        with open(summary_file) as fh:
            summary = csv.DictReader(fh)
            for row in summary:
                for key, value in row.items():
                    if "violation" in key or "error" in key:
                        print("%30s : %20s" % (key, value))
                    if "AREA" in key:
                        area = float(value)
        
        print()
        print("width x height %d um" % (1000 * math.sqrt(area)))
      
        # what drc is broken?
        print()
        drc_file = os.path.join(latest_run, 'logs', 'magic', 'magic.drc')
        last_drc = None
        drc_count = 0
        with open(drc_file) as drc:
            for line in drc.readlines():
                drc_count += 1
                if '(' in line:
                    if last_drc is not None:
                        print("* %s (%d)" % (last_drc, drc_count/4))
                    last_drc = line.strip()
                    drc_count = 0

        # copy files
        if args.copy_files:
            gds_file = os.path.join(latest_run, 'results', 'magic', design + ".gds")
            lef_file = os.path.join(latest_run, 'results', 'magic', design + ".lef")
            copyfile(gds_file, os.path.join(gds_dir, design + ".gds"))
            copyfile(lef_file, os.path.join(lef_dir, design + ".lef"))
        if args.copy_mag:
            mag_file = os.path.join(latest_run, 'results', 'magic', design + ".mag")
            copyfile(mag_file, design + ".mag")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="View Events")
    parser.add_argument('--copy-files', help="copy the gds and lef files", action='store_const', const=True)
    parser.add_argument('--copy-mag', help="copy the mag files", action='store_const', const=True)
    parser.add_argument('--design', help="only run checks on specific design", action='store')
    parser.add_argument('--skip-design', help="skip this design", action='store')
    args = parser.parse_args()
    
    if args.design is not None:
        report([args.design])
    else:
        report(designs)
