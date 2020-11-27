#!/usr/bin/env python3
import os
import glob
import csv
import sys

openlane_designs = os.path.join(os.environ['OPENLANE_ROOT'], 'designs')
print(openlane_designs)
designs = ["ws2812", "vga_clock", "seven_segment_seconds", "spinet5", "asic_freq", "watch_hhmm"]

for design in designs:
    run_dir = os.path.join(openlane_designs, design, 'runs/*')
    list_of_files = glob.glob(run_dir)
    latest_run = max(list_of_files, key=os.path.getctime)
    print(latest_run)

    summary_file = os.path.join(latest_run, 'reports', 'final_summary_report.csv')

    with open(summary_file) as fh:
        summary = csv.DictReader(fh)
        for row in summary:
            for key, value in row.items():
                if "violation" in key or "error" in key:
                    print("%30s : %20s" % (key, value))
