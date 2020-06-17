#!/bin/bash
echo '
##########################################################################
###                                                                    ###
###                 Welcome to Platform Maintanance                    ###             
###                                                                    ###
###                 Project : Realtime Record (ENET,RS232)             ###
###                                                                    ###
###                 Please Following instruction                       ###
###                                                                    ###     
##########################################################################
'

dir="$(dirname "$(readlink -f "$0")")"

echo "Current dir : $dir"

PS3 = "Please Enter your choose : "
options = ("Option 1" "Option 2" "Exit")
select opt in "${options[@]}";
do 
    case $opt in 
        "Option 1") ;;

        "Option 2") ;;

        "Exit") 
            break
        ;;
        *) echo "Invalid Choose";;
    esac
done

echo 'Choose option protocol : 1. ENET(1E FRAME FX3UENET, QSERIES) 2. ENET(3E FRAME QSERIES, FX5U 3. RS232 FX3U2DB'
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

echo "Your choose is : $choose" 

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

while true;
do 
if ping -q -c 1 -W 1 163.50.57.10 > /dev/null; then
    break
else
    echo "Can not Connect Wifi"
fi
done

wait

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

# Generate File
sudo sh -c "cat > /home/pi/Desktop/LossCode.desktop << EOF
    [Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Type=Application
    Terminal=false
    Exec=lxterminal -e $dir/start.sh
    StartupNotify=false
    Name=LossCode
    Icon=$dir/MyIcon.png
EOF"

wait

sudo sh -c "cat > $dir/start.sh << EOF
    #!/bin/bash
    cd /home/pi/Pyside_Andon_GUI/
    /usr/bin/sudo /usr/bin/python3 MainLoop.py
EOF"

wait

sudo chmod +x $dir/start.sh

# Lib # Package
case $choose in
    1)
        sudo cp -R $dir/data/lib/0011000101000011/Mc_protocol.so $dir/data/Pyside_Andon_GUI/
        sudo cp -R $dir/data/package/0011000101000011/PLCThreading.py  $dir/data/Pyside_Andon_GUI/
    ;;
    2) 
        sudo cp -R $dir/data/lib/0011000101000101 /Mc_protocol.so $dir/data/Pyside_Andon_GUI/
        sudo cp -R $dir/data/package/0011000101000101 /PLCThreading.py  $dir/data/Pyside_Andon_GUI/
    ;; 
    3) 
        sudo cp -R $dir/data/lib/0011001101000101 /Mc_protocol.so $dir/data/Pyside_Andon_GUI/
        sudo cp -R $dir/data/package/0011001101000101 /PLCThreading.py  $dir/data/Pyside_Andon_GUI/
    ;;
    *)
esac

# Install AutoIP

sudo systemctl enable $dir/ipAddr/ipAddr.service
wait 
sudo systemctl start ipAddr

# Setting AutoIP

sudo nano $dir/ipAddr/Setting.ini

wait

# Setting Text

sudo nano $dir/data/Pyside_Andon_GUI/Setting/Parameter.ini

wait

sudo nano $dir/data/Pyside_Andon_GUI/Setting/LossCode.ini

wait


# Echo Result

set +x