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
