import serial
import time
import signal
import sys

def signal_handler(signal, frame):
        ser.close()
        sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

port_name = # insert serial port name here (string format)

ser = serial.Serial(port_name, 57600, timeout=1)

time.sleep(.1)

print("Connection Successful")

filename = input("Filename?: ")

filename1 = filename + ".csv"

text_file1 = open(filename1, 'w')


while True:
	if ser.inWaiting():
		line = ser.readline().decode('utf-8')
		print(line.strip())
		if line.strip() == 'start':
			ser.write(b'start')
			break
		else:
			pass

while True:
	if ser.inWaiting():
		line = ser.readline().decode('utf-8')
		if line.strip() == 'stop':
			ser.write(b'stop')
			break
		print(line.strip())
		text_file1.write(line)

		
text_file1.close()

ser.close()
