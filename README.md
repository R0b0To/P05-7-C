# Hack for Cheap Chinese Goke GK7102 Cloud IP Cameras

This hack is for various Chinese Goke GK7102 based IP Cameras. There are few different firmware varieties across various brands of cameras, which means it is impossible to know what exactly will work for you. Older firmware are more hackable because the root filesystem is mounted read/write. In the new firmwares the root filesystem is mounted read-only but the /home directory is writeable. This hack is based on (https://github.com/ant-thomas/zsgx1hacks)


## Working on the following camera models

* P05-7-C


## Features

* Blocking cloud hosts
* New version of BusyBox v1.26.2
* Configurable settings
* BusyBox FTP Server (http://192.168.1.66:21) (camera ip)
* dropbear SSH Server: root can login ssh without password
* WebUI PTZ - (http://192.168.1.66:8080) (camera ip)
* Telnet on port 22
* Debug and diagnostics tools: [andrew-d/static-binaries](https://github.com/andrew-d/static-binaries/tree/master/binaries/linux/arm)
* Changes login credentials to ```user: root password: cxlinux```
* Improved terminal experience
* Wi-Fi configuration without cloud account


## Installation

Current version works only from microSD card and do not require installation. It should work normaly on both old and new read-only firmwares.

* Download the hack
* Copy contents of folder ```sdcard``` to the main directory of a vfat/fat32 formatted microSD card
* Change options in ```config.txt```
* Insert microSD card into camera and reboot the device
* Enjoy


## Security

The security of these devices is terrible.
* DO NOT expose these cameras to the internet.
* For this hack, config.txt is used to decide what servers you want to run.
* This hack is blocking the communication with the cloud providers, see /media/hack/etc/hosts.
* By default the camera wants to use some app [YCC365 Plus](https://play.google.com/store/apps/details?id=com.ycc365plus.aws&hl=en)
* tcpdump binary is included with this hack on /media/hack/bin/tcpdump
* Logs in /tmp/closelicamera.log
* The device was communicating with servers of icloseli.cn, icloseli.com and arcsoft.com
* Some cameras are trying to use 30.108.91.227 and 47.104.139.168, even with the blocked hosts.
```
1970-01-01 12:39:32.251493 [4342] [APDirectConnect.cpp(136) bindUdpPort]Trace: Begin___
1970-01-01 12:39:32.252391 [4342] [APDirectConnect.cpp(157) bindUdpPort]Trace: udp bind port-9999 success.
1970-01-01 12:39:32.253287 [4342] [APDirectConnect.cpp(179) bindUdpPort]Trace: udp bind port-8888 success.
1970-01-01 12:39:32.229498 [4311] [Common.cpp(378) ParseCloudIniFile]Trace: read inifile, stun_server_ip = stun.icloseli.cn.
1970-01-01 12:39:32.257463 [4311] [Common.cpp(378) ParseCloudIniFile]Trace: read inifile, return_server_ip = relaycn.closeli.cn.
1970-01-01 12:39:32.265895 [4311] [NetInterface.cpp(453) GetIpByHostName]Error: can not get (stun.icloseli.cn) ip addr!
1970-01-01 12:39:32.267988 [4311] [P2PPlayback.cpp(913) Init]Trace: parse stun domain:stun.icloseli.cn, ret=0, ip=
1970-01-01 12:39:32.273120 [4311] [NetInterface.cpp(453) GetIpByHostName]Error: can not get (relaycn.closeli.cn) ip addr!
1970-01-01 12:39:32.274199 [4311] [P2PPlayback.cpp(918) Init]Trace: parse return domain:relaycn.closeli.cn, ret=0, ip=
1970-01-01 12:39:32.275416 [4311] [P2PNew.cpp(926) SetServerAddr]Trace: stunserver:47.104.139.168:19302, turnserver:30.108.91.227:5000
1970-01-01 12:39:32.276744 [4311] [P2PNew.cpp(53) P2PLogCb]Trace: ####p2p_log:M=CLP2P;V=c7ab521e;L=error;FC=createP2PClient;MSG=createP2PClient[No StunConfision] >>> build:[Nov 28 2018 16:31:52]
```
* DO NOT expose these cameras to the internet.


## Instructions

### How to check version

* Using an onvif tool/app like Onvifer (Android) should give firmware version.
* You should also be able to find the firmware version by logging in via telnet and excuting the command
* If you have already configured the camera with the cloud app there should be some info within the app showing firmware version.
```
ls /tmp | grep -F 3. or ls /tmp | head -1
```

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


### Debug Scripts and Files

By default, the startup script ```/home/start.sh``` will try to load and run some commands

#### Files running from SD Card

To run debug scripts create a file ```debug_cmd.sh``` on an SD card and you will be able to execute bash commands from it.

#### Files copied from SD Card to /home

```*-hwcfg.ini, *-VOICE.tgz, *-ptz.cfg, *-hardinfo.bin, *-custom_init.sh```

#### File will be flashed

```firmware.bin```


### Connect to Wi-fi network

On the SD card, create the ```cls.conf``` file and write these 3 lines in it. Replace your_wifi_ssid and your_wifi_password with your credentials.
```
[cls_server]
ssid = your_wifi_ssid
passwd = your_wifi_password
```


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



### Tweaks

* [Security, RTSP, SSH, Video files to SD Card](https://github.com/ant-thomas/zsgx1hacks/pull/93/files)
* [Logs and other useful ideas](https://github.com/ant-thomas/zsgx1hacks/pull/4/files)
* [Original ant-thomas with Persistent hack](https://github.com/ant-thomas/zsgx1hacks)
* [Read-only modular customizer by bolshevik](https://github.com/bolshevik/goke-GK7102-customizer)



## Device Details

### Product

1080P IP Indoor Camera EU Power Plug & Auto Track Function
Brand: V-Tac
Model: p05 7 

ycc365 p05 7 camera]


### Wi-Fi Manufacturer

MAC Address: 88:E6:28:xx:xx:xx - Shenzhen Kezhonglong Optoelectronic Technology Co.,Ltd
Floor 3, Bldg. 5, Area B, Xinfu Industrial Park, Chongqing Rd., Baoan Dist,Shenzhen,Guangdong, China Shenzhen Guangdong CN 518103
(https://fccid.io/2AF2K-WM415)


### Software Versions
```ls
$ uname -a
Linux localhost 3.4.43-gk #40 PREEMPT Thu May 21 10:00:34 CST 2020 armv6l GNU/Linux

p2pcam
ver: 3.4.2.0724
Get Hardware Info: model:Y13,  firmware-ident:eyeplus_ipc_gk_008

"GOKE 7102C BOARD"
```

### Hardware info
```
$ cat /bak/hardinfo.bin
<?xml version="1.0" encoding="UTF-8"?>
<DeviceInfo version="1.0">
<DeviceClass>0</DeviceClass>
<OemCode>0</OemCode>
<BoardType>1300</BoardType>
<FirmwareIdent>eyeplus_ipc_gkc_002</FirmwareIdent>
<Manufacturer>KAIZE</Manufacturer>
<Model>GK7102</Model>
<WifiChip>RTL8188</WifiChip>
<GPIO>
<BoardReset>16_0x00000000_0_0</BoardReset>
<SpeakerCtrl>12_0x00000000_0_0</SpeakerCtrl>
<IrFeedback>0</IrFeedback>
<BlueLed>-1</BlueLed>
<RedLed>-1</RedLed>
<IrCtrl>23_0x00000000_0_1</IrCtrl>
<IrCut2B>14_0x00000000_0_1</IrCut2B>
<IrCut1B>17_0x00000000_0_1</IrCut1B>
<WhiteLight>24_0x00000000_0_1</WhiteLight>
<ALarmLight>11_0x00000000_0_0</ALarmLight>
</GPIO>

```

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

### Processor
```
$ cat /proc/cpuinfo 
Processor       : ARMv6-compatible processor rev 7 (v6l)
BogoMIPS        : 597.60
Features        : swp half fastmult vfp edsp java tls 
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x0
CPU part        : 0xb76
CPU revision    : 7

Hardware        : Goke IPC Board
Revision        : 0000
Serial          : 0000000000000000
$ 
```

## References

* [V-Tac VT-5122: 1080P IP Indoor Camera EU Power Plug & Auto Track Function](https://www.v-tac.eu/products/smart-home/cameras/1080p-ip-indoor-camera-eu-power-plug-auto-track-function-detail.html)

* [Hacks for ZS-GX1 IP Camera and various Goke GK7102 based IP Cameras](https://github.com/ant-thomas/zsgx1hacks)

* [The BusyBox project](https://busybox.net/)

* [ARM Binary andrew-d/static-binaries](https://github.com/andrew-d/static-binaries/tree/master/binaries/linux/arm)

* [WiFi IP CloudCamer-ы: HIP291-1M/2M-AI, Digoo DG-W01F, Digoo DG-MYQ и другие на процессоре от GOKE: GK7102 (GK7102S)](https://4pda.ru/forum/index.php?showtopic=928641)

* [GOKE HD IP CAMERA SOLUTION GK7101 GK7102](https://www.unifore.net/company-highlights/goke-hd-ip-camera-solution-gk7101-gk7102.html)

* [Aliexpress: INQMEGA 1080P Cloud Wireless IP Camera Intelligent Auto Tracking](https://www.aliexpress.com/item/32796421899.html)

* [threat9/routersploit - Exploitation Framework for Embedded Devices](https://github.com/threat9/routersploit)

* [GK7102 Based IP Camera](https://gist.github.com/brianpow/d8eeaee0879b1fd46ccedfae04799f49)

* [Read-only modular GOKE GK7102/GK7102S camera customizer](https://github.com/bolshevik/goke-GK7102-customizer)
