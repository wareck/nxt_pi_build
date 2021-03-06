#!/bin/bash
Version=0.1b
Release=01/01/2018
#NXT Node Server for RPI

NXT_v=1.11.12
Java_v=1.8.0_161
JAVA_CHK=0

daemon_work=0

set -e

################
##Configuration#
################

#Bootstrap (speedup first start, but requier 2GB free space on sdcard)
Bootstrap=YES # YES or NO
#Optimiser Raspberry (give watchdog function and autostart nxt)
Raspi_optimize=YES
#Message of the day
Motd=YES

echo -e "\n\e[97mNXT Node Server Installer v$Version :\e[0m"
echo -e "wareck@gmail.com $Release"
echo -e "\n\e[97mConfiguration\e[0m"
echo -e "-------------"
echo -e "Download Bootstrap.dat      : $Bootstrap"
echo -e "Raspberry Optimisation      : $Raspi_optimize"
echo -e "Message of the day          : $Motd"
echo -e ""
echo -e "\e[97mSoftware version :\e[0m"
echo -e "------------------"
echo -e "NXT                         : $NXT_v"
echo -e "JAVA                        : $Java_v"
echo -e ""
sleep 3

if  ps -ef | grep -v grep | grep java >/dev/null
then
echo -e "\e[38;5;166mNXT daemon is working => shutdown and restart during install...\e[0m"
daemon_work=1
fi
sleep 1

function prereq_ {
update_me=0
echo -e -n "Check NTP already installed     : "
if ! [ -x "$(command -v ntpd)" ];then echo -e "[\e[91m NO \e[0m]" && update_me=1;else echo -e "[\e[92m OK \e[0m]";fi
echo -e -n "Check ZIP already installed     : "
if ! [ -x "$(command -v zip)" ];then echo -e "[\e[91m NO \e[0m]" && update_me=1;else echo -e "[\e[92m OK \e[0m]";fi
echo -e -n "Check SCREEN already installed  : "
if ! [ -x "$(command -v screen)" ];then echo -e "[\e[91m NO \e[0m]" && update_me=1;else echo -e "[\e[92m OK \e[0m]";fi
echo -e ""
if [ $update_me = 1 ]
then
echo -e "\e[97mRaspberry update :\e[0m"
sudo apt-get update
sudo apt install unzip zip libbz2-dev liblzma-dev libzip-dev zlib1g-dev ntp htop screen -y
sudo sed -i -e "s/# set const/set const/g" /etc/nanorc
fi

echo -e "\e[95mInstall java ARM32 Hard Float ABI :\e[0m"

cd /home/$USER/
JAVA_CHK=$(java -version 2>&1 >/dev/null | grep 'java version' | awk '{print $3}'|cut -d'"' -f2)
if ! [ -x "$(command -v java)" ]; then JAVA_CHK=0 ;fi
if ! [ $JAVA_CHK = $Java_v ]
then
echo -e "\e[97mDownload JDK ...\e[0m"

#wget -c -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-arm32-vfp-hflt.tar.gz
#wget -c -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"  http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-arm32-vfp-hflt.tar.gz
wget -c -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-arm32-vfp-hflt.tar.gz

echo -e "\e[97mExpand JDK ...\e[0m"
tar xvfz jdk-8u161-linux-arm32-vfp-hflt.tar.gz
if [ -d /usr/local/java/jdk1.8.0_161/ ]; then sudo rm -r /usr/local/java/jdk1.8.0_161; fi
if [ -d /usr/local/java/ ]; then sudo rm -r /usr/local/java ; fi

echo -e "\e[97mMove JDK ...\e[0m"
sudo bash -c 'mv jdk1.8.0_161/ /usr/local/java'

echo -e "\e[97mSetup JDK ...\e[0m"
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/bin/javac" 1
sudo update-alternatives --set java /usr/local/java/bin/java
sudo update-alternatives --set javac /usr/local/java/bin/javac
if ! grep "JAVA_HOME=/usr/local/java" /etc/profile >/dev/null
then
sudo bash -c 'echo "JAVA_HOME=/usr/local/java" >>/etc/profile'
sudo bash -c 'echo "JRE_HOME=$JAVA_HOME/jre" >>/etc/profile'
sudo bash -c 'echo "PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin" >>/etc/profile'
sudo bash -c 'echo "export JAVA_HOME" >>/etc/profile'
sudo bash -c 'echo "export JRE_HOME" >>/etc/profile'
sudo bash -c 'echo "export PATH" >>/etc/profile'
fi
java -version
fi
echo "Done."
}

function Download_Expand_ {
echo -e "\n\e[95mDownload and expand NXT Server:\e[0m"
if ! [ -d /home/$USER/nxt-client-$NXT_v.zip ]
then
cd /home/$USER
wget -c https://bitbucket.org/Jelurida/nxt/downloads/nxt-client-$NXT_v.zip
unzip -o -q nxt-client-$NXT_v.zip
fi
echo -e "Done."
}

function conf_ {
echo -e "\n\e[95mInstall nxt.properties :\e[0m"
if ! [ -f /home/$USER/nxt/conf/nxt.properties ]
then
touch /home/$USER/nxt/conf/nxt.properties
cat <<'EOF'>> /home/$USER/nxt/conf/nxt.properties
#config
nxt.myAddress=88.88.88.88
nxt.apiServerHost=0.0.0.0
nxt.allowedBotHosts=*
nxt.shareMyAddress=true
nxt.myPlatform=Raspberry IOT
nxt.maxNumberOfInboundConnections=2000
nxt.maxNumberOfOutboundConnections=50
nxt.maxNumberOfConnectedPublicPeers=20
nxt.enablePeerServerDoSFilter=true
nxt.peerServerDoSFilter.maxRequestsPerSec=30
nxt.peerServerDoSFilter.delayMs=1000
nxt.peerServerDoSFilter.maxRequestMs=300000
EOF
pbip=$(curl ipinfo.io/ip)
sed -i -e "s/nxt.myAddress=88.88.88.88/nxt.myAddress=$pbpip/g" /home/$USER/nxt/conf/nxt.properties
else
echo -e "Done."
fi

echo -e "\n\e[95mMod Startup files:\e[0m"
rm /home/$USER/nxt/run.sh
cat <<'EOF'>> /home/$USER/nxt/run.sh
#!/bin/sh
if [ -x jre/bin/java ]; then
    JAVA=./jre/bin/java
else
    JAVA=java
fi
screen -dmS nxt ${JAVA} -Xmx700m -cp classes:lib/*:conf:addons/classes:addons/lib/* nxt.Nxt
EOF
chmod +x /home/$USER/nxt/run.sh
echo "Done."

echo -e "\n\e[95mMod rc.local startup file:\e[0m"
if ! grep "cd /home/pi/nxt" /etc/rc.local >/dev/null
then
sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
sudo bash -c 'echo -e "echo \x22NXT server starting...\x22" >>/etc/rc.local'
sudo bash -c 'echo -e "su - pi -c \x27cd /home/pi/nxt && ./run.sh\x27" >>/etc/rc.local'
sudo bash -c 'echo "exit 0" >>/etc/rc.local'
fi
echo "Done."
}


echo -e "\n\e[95mCheck system :\e[0m"
prereq_
Download_Expand_
conf_

if [ $Bootstrap = "YES" ]
then
echo -e "\n\e[95mDownload nxt bootstrap :\e[0m"
cd /home/$USER
wget -c http://wareck.free.fr/nxt/nxt-bootstrap.tar.xz
wget -c http://wareck.free.fr/nxt/nxt-bootstrap.md5
echo -e -n "nxt_bootstrap.tar.xz checksum test : "
if md5sum --status -c nxt-bootstrap.md5
then
echo -e "[\e[92mOK\e[0m]"
echo -e "\nUntar nxt_bootstrap.tar.xz:\n"
tar xvfJ nxt-bootstrap.tar.xz
else
echo -e "[\e[91mNO\e[0m]"
echo -e "\e[38;5;166mnxt_bootstrap.tar.xz error !\e[0m"
echo -e "\e[38;5;166mMaybe file damaged or not fully download\e[0m"
echo -e "\e[38;5;166mTry again !\e[0m"
exit
fi
fi

if [ $Motd = "YES" ]
then
echo -e "\n\e[95mTune message of the day:\e[0m"
if ! [ -f /etc/motd.bak ];then sudo bash -c 'sudo mv /etc/motd /etc/motd.bak';fi
if [ -f /tmp/motd ];then rm /tmp/motd;fi
cat <<'EOF'>> /tmp/motd
 _____ __ __ _____
|   | |  |  |_   _|
| | | |-   -| | |  
|_|___|__|__| |_|  
 
EOF
echo "NXT server node v$NXT_v" >>/tmp/motd
echo "" >>/tmp/motd
sudo bash -c 'cp /tmp/motd /etc/motd'
echo "Done."
fi


if [ $Raspi_optimize = "YES" ]
then
echo -e "\n\e[95mRaspberry Optimisation:\e[0m"
echo -e "\n\e[95mkernel Update:\e[0m"
sudo rpi-update

echo -e "\n\e[95mWatchDog and Autostart :\e[0m"
sudo apt-get install watchdog chkconfig -y
sudo chkconfig watchdog on
sudo /etc/init.d/watchdog start
sudo update-rc.d watchdog enable

echo -e "\n\e[97mEnabling and tunning Watchdog:\e[0m"
sudo bash -c 'sed -i -e "s/#watchdog-device/watchdog-device/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#interval             = 1/interval            = 4/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#RuntimeWatchdogSec=0/RuntimeWatchdogSec=14/g" /etc/systemd/system.conf'
if ! [ -f /etc/modprobe.d/bcm2835_wdt.conf ]
then
sudo bash -c 'touch /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "alias char-major-10-130 bcm2835_wdt" /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "alias char-major-10-131 bcm2835_wdt" /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "bcm2835_wdt" >>/etc/modules'
fi
echo -e "Done !"

echo -e "\n\e[95mEnable Swap :\e[0m"
sudo apt-get install dphys-swapfile -y
sudo bash -c 'sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g" /etc/dphys-swapfile'
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
echo -e "Done !"

echo -e "\n\e[95mEnable Memory split :\e[0m"
if ! grep "gpu_mem=16" /boot/config.txt >/dev/null
then
sudo bash -c 'echo "gpu_mem=16" >>/boot/config.txt'
fi
echo -e "Done !"
fi

echo -e "\n\e[97mInstall is finished !!!\e[0m"
echo "wareck@gmail.com"

if [ $daemon_work = 1 ]
then
echo -e "\e[38;5;166mNXT daemon restart \e[0m"
~/nxt/stop.sh
sleep 5
killall -9 java
~/nxt/run.sh
echo "Done."
fi
echo ""
