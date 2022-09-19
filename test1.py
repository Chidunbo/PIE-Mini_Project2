import serial
import csv
with open('data.csv','w') as writeobj:
    write = csv.writer(writeobj)
    write.writerow(rows)
    
arduinoComPort = "COM4"
baudRate = 9600
serialPort = serial.Serial(arduinoComPort,baudRate,timeout=0)

while True:
    lineofData = serialPort.readline().decode()
    if len(lineofData) > 0:
    
    