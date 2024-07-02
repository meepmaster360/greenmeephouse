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
