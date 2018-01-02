#!/bin/bash
Version=0.1b
Release=12/17/2017
set -e
echo -e "\n\e[97mRTC addon v$Version :\e[0m"
echo -e "wareck@gmail.com $Release"
echo -e ""

if [ ! -f .rtc ]
then
echo -e "\e[95mRaspberry update :\e[0m"
sudo apt-get update
echo -e "\n\e[95mInstalling libraries :\e[0m"
sudo apt-get install python-smbus python3-smbus python-dev python3-dev -y
sudo apt-get install i2c-tools -y
if ! grep "dtparam=i2c1=on" /boot/config.txt ;then sudo bash -c 'echo "dtparam=i2c1=on" >>/boot/config.txt';fi
if ! grep "i2c-dev" /etc/modules ; then sudo bash -c 'echo "i2c-dev" >>/etc/modules';fi
if ! grep "rtc-ds1307" /etc/modules ; then sudo bash -c 'echo "rtc-ds1307" >>/etc/modules';fi
echo -e "\n\e[31mFirst step of RTC install was done.\e[0m"
echo -e "\e[31mYou need to reboot and start rtc.sh again!\n\e[0m"
touch .rtc && exit 0
fi

function install_step2 {
echo -e "\n\e[95mCreate device:\e[0m"
sudo bash -c 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device > /dev/null 2>&1' || true
echo "Done."
echo -e "\n\e[95mRTC clock reset:\e[0m"
sudo bash -c 'hwclock -r'

echo -e "\n\e[95mRTC clock setup :\e[0m"
sudo bash -c 'hwclock -w'
echo "Done."

echo -e "\n\e[95mAdding RTC to RPI startup:\e[0m"
if ! grep "echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device" /etc/rc.local >/dev/null 2>&1
then
sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
sudo bash -c 'echo "echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device" >> /etc/rc.local'
sudo bash -c 'echo "sudo hwclock -s" >>/etc/rc.local'
sudo bash -c 'echo "exit 0" >>/etc/rc.local'
fi

echo -e "\n\e[95mCheck :\e[0m"
echo "Raspberry time:"
date
echo "Rtc time:"
sudo bash -c 'hwclock -r'
echo ""
echo "Done !"
}

function rtc_check {
echo -e "\e[95mRTC check :\e[0m"
sudo i2cdetect -y 1
echo -e "\e[31mYou must see \"UU\" on address 68.\e[0m"
echo -e "\e[31mIf not, double check your wiring and try again.\e[0m"
PS3='Please enter your choice: '
options=("Check again" "Continue" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Check again")
	    rtc_check
	    break
            ;;
        "Continue")
            break
	    ;;
        "Quit")
            exit 0 && break
            ;;
        *) echo invalid option;;
    esac
done
}

if [ -f .rtc ]
then
rtc_check
install_step2
fi
