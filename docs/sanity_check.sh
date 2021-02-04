echo "## date made"
echo
ls -l  openlane/designs/ws2812/runs/03-02_10-14/results/magic/*gds
ls -l  openlane/designs/vga_clock/runs/04-02_10-59/results/magic/*gds
ls -l  openlane/designs/seven_segment_seconds/runs/03-02_10-29/results/magic/*gds
ls -l  openlane/designs/spinet5/runs/03-02_10-30/results/magic/*gds
ls -l  openlane/designs/asic_freq/runs/03-02_10-31/results/magic/*gds
ls -l  openlane/designs/watch_hhmm/runs/03-02_10-51/results/magic/*gds
ls -l  openlane/designs/challenge/runs/03-02_10-32/results/magic/*gds
ls -l  openlane/designs/MM2hdmi/runs/03-02_10-34/results/magic/*gds
ls -l  openlane/designs/multi_project_harness/runs/04-02_10-09/results/magic/*gds

echo
echo "## openlane md5sum of gds"
echo
md5sum openlane/designs/ws2812/runs/03-02_10-14/results/magic/*gds
md5sum openlane/designs/vga_clock/runs/04-02_10-59/results/magic/*gds
md5sum openlane/designs/seven_segment_seconds/runs/03-02_10-29/results/magic/*gds
md5sum openlane/designs/spinet5/runs/03-02_10-30/results/magic/*gds
md5sum openlane/designs/asic_freq/runs/03-02_10-31/results/magic/*gds
md5sum openlane/designs/watch_hhmm/runs/03-02_10-51/results/magic/*gds
md5sum openlane/designs/challenge/runs/03-02_10-32/results/magic/*gds
md5sum openlane/designs/MM2hdmi/runs/03-02_10-34/results/magic/*gds
md5sum openlane/designs/multi_project_harness/runs/04-02_10-09/results/magic/*gds

echo
echo "## user_project_wrapper/macros md5sum of gds"
echo

for i in ws2812 vga_clock seven_segment_seconds spinet5 asic_freq watch_hhmm challenge MM2hdmi multi_project_harness ; do
    md5sum caravel-release/openlane/user_project_wrapper/macros/gds/$i.gds
done

echo
echo "md5sum of user_project_wrapper.gds in mpw-one-a"
echo

md5sum caravel-release/openlane/user_project_wrapper/runs/user_project_wrapper/results/magic/*gds
ls -l caravel-release/openlane/user_project_wrapper/runs/user_project_wrapper/results/magic/*gds

echo
echo "md5sum of user_project_wrapper.gds in mpw-one-b"
echo

md5sum caravel-mpw-one-b/gds/user_project_wrapper.gds
ls -l caravel-mpw-one-b/gds/user_project_wrapper.gds
