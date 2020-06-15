import socket
import paho.mqtt.client as mqtt
import time
import os


if __name__ == "__main__":
    host = "MTL-700-NOA55"
    port = 1883
    client = mqtt.Client()
    client.connect(host)

    f = os.popen('ifconfig wlan0 | grep "inet 191" | cut -c 14-26')
    myip=f.read()
    print(myip)

    while True:
        client.loop_start()
        client.publish("ipAddr/Rasp/NMPSC/NMPSC-409", str(myip))
        time.sleep(60)
        client.loop_stop()


