#!/usr/bin/env python3
import argparse
import os
import glob
import csv
import sys
from shutil import copyfile

openlane_designs = os.path.join(os.environ['OPENLANE_ROOT'], 'designs')
gds_dir = "../../gds/mph/"
lef_dir = "../../lef/mph/"

designs = ["ws2812", "vga_clock", "seven_segment_seconds", "spinet5", "asic_freq", "watch_hhmm", "challenge"]

def report(designs):
    for design in designs:
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

      
        # what drc is broken?
        print()
        drc_file = os.path.join(latest_run, 'logs', 'magic', 'magic.drc')
        with open(drc_file) as drc:
            for line in drc.readlines():
                if '(' in line:
                    print("* " + line)

        # copy files
        if args.copy_files:
            gds_file = os.path.join(latest_run, 'results', 'magic', design + ".gds")
            lef_file = os.path.join(latest_run, 'results', 'magic', design + ".lef")
            copyfile(gds_file, os.path.join(gds_dir, design + ".gds"))
            copyfile(lef_file, os.path.join(lef_dir, design + ".lef"))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="View Events")
    parser.add_argument('--copy-files', help="copy the gds and lef files", action='store_const', const=True)
    parser.add_argument('--design', help="only run checks on specific design", action='store')
    args = parser.parse_args()
    
    if args.design is not None:
        report([args.design])
    else:
        report(designs)
