import serial
import time
import signal
import sys

def signal_handler(signal, frame):
        ser.close()
        ser2.close()
        sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)


ser = serial.Serial('/dev/cu.AdafruitEZ-Linka7b1-SPP', 57600, timeout=1)
time.sleep(.1)

print "Connection Successful"

filename = raw_input("Filename?: ")

filename1 = filename + ".csv"

text_file1 = open(filename1, 'w')

while True:
	if ser.inWaiting():
		line = ser.readline()
		print line.strip()
		if line.strip() == 'start':
			ser.write('start')
			break
		else:
			pass

while True:
	if ser.inWaiting():
		line = ser.readline()
		if line.strip() == 'stop':
			ser.write('stop')
			break
		print line.strip()
		text_file1.write(line)

		
text_file1.close()

ser.close()
