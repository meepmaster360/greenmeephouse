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
