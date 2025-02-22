import airsim # type: ignore
import json
import time
import math

# Connect to AirSim
client = airsim.MultirotorClient()
client.confirmConnection()

# Enable API control and take off
client.enableApiControl(True)
client.armDisarm(True)
client.takeoffAsync().join()

json_file_path = "airsim_data.json"

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

        # Write JSON file
        with open(json_file_path, "w") as f:
            json.dump(data, f, indent=2)

        time.sleep(0.1)  # Update at 10Hz

except KeyboardInterrupt:
    print("\nStopping the simulation...")
    client.armDisarm(False)
    client.enableApiControl(False)
