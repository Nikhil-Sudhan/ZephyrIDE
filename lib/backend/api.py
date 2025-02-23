import airsim  # type: ignore
import json
import time
import math
from pathlib import Path

# Connect to AirSim
client = airsim.MultirotorClient()
client.confirmConnection()

# Enable API control and take off
client.enableApiControl(True)
client.armDisarm(True)
client.takeoffAsync().join()

# Use absolute path and ensure directory exists
json_file_path = Path("F:/ZephyrIDE updated/lib/backend/airsim_data.json")
json_file_path.parent.mkdir(parents=True, exist_ok=True)

def write_json_data(file_path, data):
    try:
        with open(file_path, "w", buffering=1) as f:  # Line buffering
            json.dump(data, f, indent=2)
            f.flush()  # Force write to disk
    except Exception as e:
        print(f"Error writing JSON: {e}")

try:
    while True:
        # Get drone state
        state = client.getMultirotorState()
        position = state.kinematics_estimated.position
        velocity = state.kinematics_estimated.linear_velocity
        orientation = state.kinematics_estimated.orientation

        # Store data in dictionary
        data = {
            "timestamp": time.time(),
            "position": {
                "x": position.x_val,
                "y": position.y_val,
                "z": position.z_val
            },
            "velocity": {
                "x": velocity.x_val,
                "y": velocity.y_val,
                "z": velocity.z_val
            },
            "orientation": {
                "w": orientation.w_val,
                "x": orientation.x_val,
                "y": orientation.y_val,
                "z": orientation.z_val
            },
            "battery": 75,  # Add actual battery monitoring if available
            "armed": client.isApiControlEnabled()
        }

        # Write JSON file with error handling
        write_json_data(json_file_path, data)

        # Add a small delay to prevent excessive CPU usage
        time.sleep(0.1)  # Update at 10Hz

except KeyboardInterrupt:
    print("\nStopping the simulation...")
    client.armDisarm(False)
    client.enableApiControl(False)
except Exception as e:
    print(f"An error occurred: {e}")
    client.armDisarm(False)
    client.enableApiControl(False)
