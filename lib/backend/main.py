import airsim
import time

def main():
    # Connect to the AirSim simulator
    client = airsim.MultirotorClient()
    client.confirmConnection()
    
    # Enable API control
    client.enableApiControl(True)
    print("API control enabled.")
    
    # Arm the drone
    client.armDisarm(True)
    print("Drone armed.")
    
    # Takeoff
    takeoff_result = client.takeoffAsync().join()
    print("Takeoff completed.")
    
    # Hover for a few seconds
    time.sleep(5)
    
    # Land the drone
    land_result = client.landAsync().join()
    print("Landing completed.")
    
    # Disarm and release API control
    client.armDisarm(False)
    client.enableApiControl(False)
    print("API control released.")

if __name__ == "__main__":
    main()
