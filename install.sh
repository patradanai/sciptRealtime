#!/bin/bash
echo '
##########################################################################
###                                                                    ###
###         Welcome to Platform Maintanance                            ###             
###                                                                    ###
###         Project : Realtime Record (ENET,RS232)                     ###
###                                                                    ###
###         Please Following instruction                               ###
###                                                                    ###     
##########################################################################
'

echo '1/20 STEP : Determine Machine Name ? : '
read -p nameMachine

echo "2/20 STEP : Setting IP Machine"
read ipMachine

echo '3/20 STEP : Choose option protocol : 1. ENET(1E FRAME FX3UENET, QSERIES) 2. ENET(3E FRAME QSERIES, FX5U 3. RS232 FX3U2DB'
read typeProcol

case $typeProcol in 
                    1) echo "ENET(1E FRAME FX3UENET, QSERIES)"
                    choose = 1 ;;
                    2) echo "ENET(3E FRAME QSERIES, FX5U"
                    choose = 2 ;;
                    3) echo "RS232 FX3U2DB"
                    choose = 3 ;;
                    *) echo "Access Denied"
esac

echo '4/20 STEP : Setting IP PLC? : '
read ipPlc

echo '5/20 STEP : Setting Port PLC? : '
read portPlc

echo '6/20 STEP : MQTT server ip for AutoIP : default port : 1883'
read mqttIpServer


set -x 

# Setting Wifi

sudo sh -c 'cat > /etc/dhcpcd.conf << EOP
interface wlan0
metric 100

interface eth0
metric 300
static ip_address=192.168.250.200/24
static routers=192.168.250.254
static domain_name_servers=192.168.250.254
EOP'

sudo sh -c 'cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOF
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    scan_ssid=1
    ssid="ssid-th1900"
    psk="nextgen2019"
    key_mgmt=WPA-PSK }
EOF'

# Setting Proxy
echo "Setting Proxy"
export http_proxy="http://163.50.57.130:8080"
export https_proxy="http://163.50.57.130:8080"
export no_proxy="localhost, 127.0.0.1"

# Install Python Package
echo "Setting Package"
sudo pip install -r requirement.txt

echo "Setting Domain"

sudo sh -c 'echo "search_domains=co.murata.local" >> /etc/resolvconf.conf'
sudo sh -c 'echo "name_servers=163.50.57.10" >> /etc/resolvconf.conf'
sudo sh -c 'echo "name_servers=163.50.57.9" >> /etc/resolvconf.conf'

sudo resolvconf -u

# Install LCD Bright

sudo sh -c 'cat > /etc/xdg/lxsession/LXDE-pi/autostart << EOF 
    @xset s noblank
    @xset s off
    @xset -dpms
EOF'

sudo sh -c 'cat > /boot/config.txt << EOF
    hdmi_force_hotplug=1
    max_usb_current=1
    hdmi_group=2
    hdmi_mode=87
    hdmi_cvt 1280 800 60 6 0 0 0
    hdmi_drive=1
EOF'

# Install Pyodbc 

sudo apt-get update
sudo apt-get install -y tdsodbc unixodbc-dev unixodbc freetds-dev  freetds-bin tdsodbc
sudo apt install unixodbc-bin -y

sudo sh -c 'cat > /etc/odbcinst.ini << EOF 
[FreeTDS]
Description = FreeTDS unixODBC Driver
Driver = /usr/lib/arm-linux-gnueabihf/odbc/libtdsodbc.so
Setup = /usr/lib/arm-linux-gnueabihf/odbc/libtdsS.so
EOF'

sudo sh -c 'cat > /etc/freetds/freetds.conf << EOF
#MT740SVR
[MT740SVR]
        host = mtl-700-noa55
        port = 1433
        tds version = 7.0

#MT700SVR
[MT700SVR]
        host = mt700svr
        port = 1433
        tds version = 7.0
EOF'

sudo sh -c 'cat > /etc/odbc.ini << EOF
[SQLMT700SVR]
Driver = FreeTDS
Description = ODBC connection via FreeTDS
Trace = No
Servername = MT700SVR

[SQLMT740SVR]
Driver = FreeTDS
Description = ODBC connection via FreeTDS
Trace = No
Servername = MT740SVR
EOF'

sudo pip install pyodbc

# Install NTP

sudo apt-get install ntp

echo "163.50.57.10 iburst" >> /etc/ntp.conf

sudo service ntp restart 

sudo systemctl enable ntp

# Moving Files

sudo cp LossCode.desktop /home/pi/Desktop/
sudo cp MyIcon.png /home/pi
sudo cp start.sh /home/pi

sudo chmod +x /home/pi/start.sh

set +x