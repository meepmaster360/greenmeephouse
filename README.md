# greenmeephouse

Automating a greenhouse can involve various aspects such as controlling temperature, humidity, lighting, and irrigation systems. Below is an example of a Bash script that can be used to automate some basic greenhouse management tasks using a Raspberry Pi or similar device with sensors and actuators connected.

Prerequisites
Hardware:

Raspberry Pi or similar device
Temperature and humidity sensor (e.g., DHT22)
Relay module for controlling devices (e.g., fans, lights, pumps)
Optional: soil moisture sensor, light sensor
Software:

Raspbian or similar Linux-based OS
Python for interacting with sensors and actuators
Bash for scripting automation tasks
Python Scripts for Sensor Data
Reading Temperature and Humidity
Create a Python script to read data from a DHT22 sensor:

python
Copy code
# dht22_sensor.py
import Adafruit_DHT

# Sensor should be set to Adafruit_DHT.DHT22
sensor = Adafruit_DHT.DHT22
pin = 4  # GPIO pin where the sensor is connected

humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)

if humidity is not None and temperature is not None:
    print(f'Temperature={temperature:0.1f}C Humidity={humidity:0.1f}%')
else:
    print('Failed to get reading. Try again!')
Controlling Relays
Create a Python script to control a relay module:

python
Copy code
# relay_control.py
import RPi.GPIO as GPIO
import sys

relay_pin = int(sys.argv[1])
state = sys.argv[2]

GPIO.setmode(GPIO.BCM)
GPIO.setup(relay_pin, GPIO.OUT)

if state == 'on':
    GPIO.output(relay_pin, GPIO.LOW)  # Assuming LOW turns the relay on
elif state == 'off':
    GPIO.output(relay_pin, GPIO.HIGH)  # Assuming HIGH turns the relay off

GPIO.cleanup()
Bash Script for Automation
Now, combine the Python scripts into a Bash script to automate tasks based on sensor data.

bash
Copy code
#!/bin/bash

# Define GPIO pins for relays
FAN_RELAY=17
LIGHT_RELAY=27
PUMP_RELAY=22

# Temperature and humidity thresholds
TEMP_THRESHOLD=30  # Celsius
HUMIDITY_THRESHOLD=70  # Percent

# Read sensor data
read_sensor_data() {
    data=$(python3 /path/to/dht22_sensor.py)
    temperature=$(echo "$data" | grep -oP 'Temperature=\K[0-9.]+')
    humidity=$(echo "$data" | grep -oP 'Humidity=\K[0-9.]+')
    echo "Temperature: $temperature°C, Humidity: $humidity%"
}

# Control relay
control_relay() {
    relay_pin=$1
    state=$2
    python3 /path/to/relay_control.py $relay_pin $state
}

# Automation logic
read_sensor_data

# Control fan based on temperature
if (( $(echo "$temperature > $TEMP_THRESHOLD" | bc -l) )); then
    control_relay $FAN_RELAY "on"
else
    control_relay $FAN_RELAY "off"
fi

# Control lights (example: turn on during the day and off at night)
hour=$(date +%H)
if (( hour >= 6 && hour <= 18 )); then
    control_relay $LIGHT_RELAY "on"
else
    control_relay $LIGHT_RELAY "off"
fi

# Control pump based on humidity (example logic)
if (( $(echo "$humidity < $HUMIDITY_THRESHOLD" | bc -l) )); then
    control_relay $PUMP_RELAY "on"
else
    control_relay $PUMP_RELAY "off"
fi
Scheduling the Script
Use cron to schedule the Bash script to run at regular intervals (e.g., every 5 minutes).

Open the crontab file:

bash
Copy code
crontab -e
Add the following line to schedule the script:

bash
Copy code
*/5 * * * * /path/to/your_script.sh
This setup provides a basic framework for automating a greenhouse. You can expand it by adding more sensors and control logic as needed. Always ensure the hardware and software are securely set up to prevent any malfunction that could harm your plants or equipment.

otions in bash script
ChatGPT
In a Bash script, you can use command-line options to control the behavior of the script. This is commonly done using the getopts command, which provides a way to parse positional parameters and flags. Here is a basic example of a Bash script that uses options to control greenhouse automation tasks.

Example Script with Options
The script will support options for:

Reading sensor data (-r or --read).
Controlling the relay for a specific device (-c or --control).
Setting thresholds for temperature and humidity (-t or --temp-threshold, -h or --humidity-threshold).
Script: greenhouse_control.sh
bash
Copy code
#!/bin/bash

# Default values
TEMP_THRESHOLD=30  # Celsius
HUMIDITY_THRESHOLD=70  # Percent

# Define GPIO pins for relays
FAN_RELAY=17
LIGHT_RELAY=27
PUMP_RELAY=22

# Function to read sensor data
read_sensor_data() {
    data=$(python3 /path/to/dht22_sensor.py)
    temperature=$(echo "$data" | grep -oP 'Temperature=\K[0-9.]+')
    humidity=$(echo "$data" | grep -oP 'Humidity=\K[0-9.]+')
    echo "Temperature: $temperature°C, Humidity: $humidity%"
}

# Function to control relay
control_relay() {
    relay_pin=$1
    state=$2
    python3 /path/to/relay_control.py $relay_pin $state
}

# Function to display usage
usage() {
    echo "Usage: $0 [-r | --read] [-c | --control DEVICE STATE] [-t | --temp-threshold TEMP] [-h | --humidity-threshold HUMIDITY]"
    echo "  -r, --read                  Read sensor data"
    echo "  -c, --control DEVICE STATE  Control relay (DEVICE: fan, light, pump; STATE: on, off)"
    echo "  -t, --temp-threshold TEMP   Set temperature threshold"
    echo "  -h, --humidity-threshold HUMIDITY  Set humidity threshold"
    exit 1
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--read)
            read_sensor_data
            exit 0
            ;;
        -c|--control)
            DEVICE=$2
            STATE=$3
            shift 2
            case $DEVICE in
                fan)
                    control_relay $FAN_RELAY $STATE
                    ;;
                light)
                    control_relay $LIGHT_RELAY $STATE
                    ;;
                pump)
                    control_relay $PUMP_RELAY $STATE
                    ;;
                *)
                    echo "Invalid device. Use fan, light, or pump."
                    exit 1
                    ;;
            esac
            exit 0
            ;;
        -t|--temp-threshold)
            TEMP_THRESHOLD=$2
            shift
            ;;
        -h|--humidity-threshold)
            HUMIDITY_THRESHOLD=$2
            shift
            ;;
        *)
            usage
            ;;
    esac
    shift
done

# Automation logic (this part runs only if no options are given)
read_sensor_data

# Control fan based on temperature
if (( $(echo "$temperature > $TEMP_THRESHOLD" | bc -l) )); then
    control_relay $FAN_RELAY "on"
else
    control_relay $FAN_RELAY "off"
fi

# Control lights (example: turn on during the day and off at night)
hour=$(date +%H)
if (( hour >= 6 && hour <= 18 )); then
    control_relay $LIGHT_RELAY "on"
else
    control_relay $LIGHT_RELAY "off"
fi

# Control pump based on humidity
if (( $(echo "$humidity < $HUMIDITY_THRESHOLD" | bc -l) )); then
    control_relay $PUMP_RELAY "on"
else
    control_relay $PUMP_RELAY "off"
fi
How to Use This Script
Read Sensor Data:

bash
Copy code
./greenhouse_control.sh --read
Control Relays:

Turn the fan on:
bash
Copy code
./greenhouse_control.sh --control fan on
Turn the light off:
bash
Copy code
./greenhouse_control.sh --control light off
Set Thresholds:

Set temperature threshold to 28°C:
bash
Copy code
./greenhouse_control.sh --temp-threshold 28
Set humidity threshold to 65%:
bash
Copy code
./greenhouse_control.sh --humidity-threshold 65
Scheduling the Script
Use cron to schedule the script to run at regular intervals (e.g., every 5 minutes) without options, letting it control the environment based on the thresholds set.

Open the crontab file:

bash
Copy code
crontab -e
Add the following line to schedule the script:

bash
Copy code
*/5 * * * * /path/to/greenhouse_control.sh
This setup allows you to automate greenhouse management tasks and adjust settings easily through command-line options.
