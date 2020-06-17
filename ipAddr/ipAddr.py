import socket
import paho.mqtt.client as mqtt
import time
import os
import configparser

# directory of folder

dir = os.path.dirname(os.path.realpath(__file__))

# Variable

hostMqtt = ""
portMqtt = 0
topicMqtt = ""

if __name__ == "__main__":
    myConfig = configparser.ConfigParser()
    myConfig.read(dir+"/Setting.ini")
    hostMqtt = myConfig.get('AutoIP','serverIP')
    portMqtt = myConfig.get('AutoIP','serverPort')
    topicMqtt = myConfig.get('AutoIP','nameTopic')
    
    host = str(hostMqtt)
    port = int(portMqtt)
    client = mqtt.Client()
    client.connect(host)

    f = os.popen('ifconfig wlan0 | grep "inet 191" | cut -c 14-26')
    myip=f.read()
    print(myip)

    while True:
        client.loop_start()
        client.publish(str(topicMqtt), str(myip))
        time.sleep(60)
        client.loop_stop()


