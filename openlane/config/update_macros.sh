for macro in ws2812 vga_clock seven_segment_seconds spinet6 asic_freq; do 
	gds=$(\ls ../${macro}/runs/*/results/*/*gds --sort=time | head -1;)
	lef=$(\ls ../${macro}/runs/*/results/*/*lef --sort=time | head -1;)
    cp $gds macros/gds/
    cp $lef macros/lef/
done
    
