![](https://raw.githubusercontent.com/wareck/nxt_pi_build/master/.docs/logo-nxt-rond.png)

## Auto-Install script for NXT server node (Raspberry Pi2 & Pi3) ##

----------
This script install "nxt server" (command line only, for best efficiency) .

Script will download/compile/configure files in autonomous .

I suggest to use Pi2 or Pi3 otherwise, it will take to much time to synchronise and never staking ...

You can use Raspbian Jessie or Strecth (lite or full, better is to use lite version for efficiency/speed).

----------

## How to use this script ? ##

When logged into Raspberry start by an update upgrade :

    sudo apt-get update
    sudo apt-get upgrade

Then :

    sudo apt-get install git -y
    git clone https://github.com/wareck/nxt_pi_build.git
    cd nxt_pi_build
    ./deploy.sh

When install finish:

    sudo reboot

## How to use server ? ##
open you internet browser, connect to you raspberry ip address and add 7876 port

    http://raspberryIP:7876

wareck
donate Bitcoin :  16F8V2EnHCNPVQwTGLifGHCE12XTnWPG8G
