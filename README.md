## Working on the following camera models

* P05-7-C


## Features

* Blocking cloud hosts
* New version of BusyBox v1.37.0 (not touching the original, running the other services from the SD)
* Configurable settings
* BusyBox FTP Server (http://192.168.1.xx:21) (camera ip)
* dropbear SSH Server: (ssh -i cam_key_ecdsa root@192.168.1.xx) root can login with ecdsa authorization key in hack/root/.ssh/authorized_keys or ssh without password modifying debug.sh
* WebUI PTZ - (http://192.168.1.xx:8080) (camera ip)
* Changes login credentials to ```user: root password: cxlinux```
* Wi-Fi configuration without cloud account


## Installation

Current version works only from microSD card and do not require installation. It should work normaly on both old and new read-only firmwares.

* Download the hack
* Copy contents of folder ```sdcard``` to the main directory of a vfat/fat32 formatted microSD card
* Change options in ```config.txt```
* Insert microSD card into camera and reboot the device
* Enjoy


### Default Credentials

   IP                Port     Service     Username     Password     
   ------            ----     -------     --------     --------     
   192.168.200.1     23       telnet      root         cxlinux     


### RTSP Connection

* rtsp://admin:@192.168.200.1:554
* rtsp://admin:@192.168.200.1:554/0/av0 (with audio)
* rtsp://admin:@192.168.200.1:554/0/av1 (low quality)
* rtsp://admin:@192.168.200.1:8001
* rtsp://admin:@192.168.200.1:8001/0/av0 (with audio)
* rtsp://admin:@192.168.200.1:8001/0/av1 (low quality)

### Commands
```
ircut?mode=night
ircut?mode=day
ircut?mode=auto
whitelight?mode=off
whitelight?mode=on
playaudio?file=/tmp/VOICE/alarm.wav
irctrl?mode=day
irctrl?mode=night
redinfra?mode=on
redinfra?mode=off
buleled?mode=on
buleled?mode=off
redled?mode=on
redled?mode=off
ircut_only?mode=day
ircut_only?mode=night

ptzctrl //already using the one from the hack
reloadcf
rstsys
wexit "close watchdog then exit !!!" Subroutine does not retur
4gstatus

```


### Debug Scripts and Files

By default, the startup script ```/home/start.sh``` will try to load and run some commands

#### Files running from SD Card

To run debug scripts create a file ```debug_cmd.sh``` on an SD card and you will be able to execute bash commands from it.


### Date and time

Camera loses the date and time setting when it loses power. The time is updated from a remote server.

You can set your date and time manualy by `date --set`
```
Recognized TIME formats:
   hh:mm[:ss]
   [YYYY.]MM.DD-hh:mm[:ss]
   YYYY-MM-DD hh:mm[:ss]
   [[[[[YY]YY]MM]DD]hh]mm[.ss]
   'date TIME' form accepts MMDDhhmm[[YY]YY][.ss] instead
```
For example:
`date --set="2023-03-23 16:10:00"`


### Disable the whitelight

If you want to disable the whitelight you can edit `hwcfg.ini` and change support_doublelight from 2 to 1. Check [RussH007's comment](https://github.com/dc35956/gk7102-hack/issues/13) for more details.
`support_doublelight = 1`


### Product

1080P IP Indoor Camera EU Power Plug & Auto Track Function
Brand: V-Tac
Model: p05 7 

ycc365 p05 7 camera




### Open ports
```
$ nmap -p- 192.168.200.1
Nmap scan report for _gateway (192.168.200.1)
Host is up (0.018s latency).
Not shown: 65525 closed ports
PORT     STATE SERVICE
23/tcp   open  telnet
80/tcp   open  http
554/tcp  open  rtsp
843/tcp  open  unknown
3201/tcp open  cpq-tasksmart
5050/tcp open  mmcc
6670/tcp open  irc
7101/tcp open  elcn
7103/tcp open  unknown
8001/tcp open  vcom-tunnel
```

