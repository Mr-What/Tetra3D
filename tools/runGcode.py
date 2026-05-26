#!/usr/bin/env python3
import requests
import websocket
import json
import time
import sys

if len(sys.argv) < 3:
    print("Usage: runGcode.py myGcodeFile.gcode  myLogFile.txt")
    sys.exit(1)
    
# Configuration
GCODE_FILE = sys.argv[1] #'probeAccuracy.gcode'
OUTPUT_FILE = sys.argv[2] # 'accuracyLog.txt'
#MOONRAKER_URL = 'http://localhost:7125'
#MOONRAKER_WS = 'ws://localhost:7125/websocket'
MOONRAKER_URL = 'http://tetrapi:7125'
MOONRAKER_WS = 'ws://tetrapi:7125/websocket'

# Read gcode file
with open(GCODE_FILE, 'r') as f:
    commands = []
    for line in f:
        line = line.split(';')[0].strip()  # Remove comments
        if line:
            commands.append(line)

output_log = open(OUTPUT_FILE, 'w')
console_output = []

def on_message(ws, message):
    """Capture console output from Klipper"""
    try:
        data = json.loads(message)
        if 'method' in data and data['method'] == 'notify_gcode_response':
            if 'params' in data and isinstance(data['params'], list):
                for msg in data['params']:
                    print(msg)
                    output_log.write(msg + '\n')
                    output_log.flush()
    except Exception as e:
        pass

def on_error(ws, error):
    print(f"WebSocket Error: {error}")

def on_open(ws):
    """Subscribe to gcode output when connection opens"""
    subscribe_msg = {
        "jsonrpc": "2.0",
        "method": "printer.gcode.subscribe_output",
        "params": {"response_template": {"method": "notify_gcode_response"}},
        "id": 1
    }
    ws.send(json.dumps(subscribe_msg))
    print("Subscribed to console output")

# Connect to Moonraker WebSocket
print(f"Connecting to {MOONRAKER_WS}...")
ws = websocket.WebSocketApp(
    MOONRAKER_WS,
    on_message=on_message,
    on_error=on_error,
    on_open=on_open
)

# Start WebSocket in a thread
import threading
ws_thread = threading.Thread(target=ws.run_forever)
ws_thread.daemon = True
ws_thread.start()

time.sleep(2)  # Wait for connection

# Send each gcode command
for cmd in commands:
    print(f"\n>>> Sending: {cmd}")
    output_log.write(f"\n>>> {cmd}\n")
    output_log.flush()
    
    try:
        response = requests.post(
            f'{MOONRAKER_URL}/printer/gcode/script',
            params={'script': cmd},
            timeout=30
        )
        time.sleep(.3)  # Wait for command to complete and output to arrive
    except Exception as e:
        print(f"Error sending command: {e}")
        output_log.write(f"ERROR: {e}\n")

time.sleep(.5)  # Wait for final output
output_log.close()
ws.close()
print(f"\nDone! Results saved to {OUTPUT_FILE}")

