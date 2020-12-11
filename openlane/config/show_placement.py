#!/usr/bin/env python3
from PIL import Image, ImageFont, ImageDraw
import re

im = Image.new('RGB', (2920, 3520), (255,255,255))
draw = ImageDraw.Draw(im)

with open("macro_placement.cfg") as macros:
    for line in macros.readlines():
        m = re.match("^(\w+)\s+(\d+)\s+(\d+)\s+N\s+#\s+(\w+)\s(\d+)x(\d+)", line)
        if m is None:
            exit("error on line %s" % line) 
        else:
            project = m.group(1)
            x1 = int(m.group(2))
            y1 = int(m.group(3))
            name = m.group(4)
            width = int(m.group(5))
            height = int(m.group(6))
            
        print(project, x1, y1, name, width, height)
        draw.rectangle(((x1, y1), (x1+width, y1+height)), fill="black")

im.save("macros.jpg")
