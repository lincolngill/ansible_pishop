#!/usr/bin/env python3
#
# Return Pi model: 0,1,2,3 or 4
import sys

with open('/proc/device-tree/model') as f:
    model_text = f.read()

model = None
if 'Raspberry Pi Zero' in model_text:
    model = '0'
elif 'Raspberry Pi Model' in model_text:
    model = '1'
elif 'Raspberry Pi 2 Model' in model_text:
    model = '2'
elif 'Reaspberry Pi 3 Model' in model_text:
    model = '3'
elif 'Raspberry Pi 4 Model' in model_text:
    model = '4'

if model is None:
    print("ERROR: Cannot determine Pi model", file=sys.stderr)
    exit(1)

print(model)