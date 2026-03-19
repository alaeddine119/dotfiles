import os

fpath = os.path.expanduser('~/.local/share/AirStatus/main.py')
with open(fpath, 'r') as f:
    txt = f.read()

# 1. Ask bleak to return the Advertisement Data payload
txt = txt.replace('devices = await BleakScanner.discover()', 'devices = await BleakScanner.discover(return_adv=True)')

# 2. Unpack both the device (d) and the payload (adv)
txt = txt.replace('for d in devices:', 'for d, adv in devices.values():')

# 3. Read the RSSI and metadata from the payload, not the device
txt = txt.replace('d.rssi', 'adv.rssi')
txt = txt.replace("d.metadata['manufacturer_data']", "adv.manufacturer_data")
txt = txt.replace('d.metadata["manufacturer_data"]', "adv.manufacturer_data")

with open(fpath, 'w') as f:
    f.write(txt)

print("Script perfectly patched for modern Bleak!")
