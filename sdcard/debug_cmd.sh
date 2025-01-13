#!/bin/sh

# mount sd card to separate location
if [ -b /dev/mmcblk0p1 ]; then
	mount /dev/mmcblk0p1 /media
elif [ -b /dev/mmcblk0 ]; then
	mount /dev/mmcblk0 /media
fi

# include config
. /media/config.txt

# confirm hack type
touch /home/HACKSD

#this camera model transfer all the files from /home to /bak
#function to remount as read and write
mountBakRW()
{
		echo "mounting /bak read & write ..."
		mount -o rw,remount /bak
}
#function to remount as read only
mountBakRO()
{
		echo "mounting /bak readonly ..."
		mount -o ro,remount /bak
}

mkdir -p /home/busybox

# install updated version of busybox
mount --bind /media/hack/busybox /bin/busybox
/bin/busybox --install -s /home/busybox


## Mount /etc/ files from microSD card
# env
mount --bind /media/hack/etc/profile /etc/profile
# users and groups
mount --bind /media/hack/etc/group /etc/group
mount --bind /media/hack/etc/passwd /etc/passwd
mount --bind /media/hack/etc/shadow /etc/shadow

# forcing Timezone
mount --bind /media/hack/etc/TZ /etc/TZ
# update hosts file to prevent communication
if [ "$HACK_CLOUD" = "YES" ]; then
    mount --bind /media/hack/etc/hosts /etc/hosts
fi



# Wi-Fi Settings
if [ "$HACK_WIFI" = "YES" ]; then
    echo "[cls_server]" > cls.conf
    echo "ssid = $WIFI_SSID" >> cls.conf
    echo "passwd = $WIFI_PASSWORD" >> cls.conf
fi


## Servers

# Busybox httpd
if [ "$HACK_HTTPD" = "YES" ]; then
    /home/busybox/httpd -p 8080 -h /media/hack/www
fi

# SSH Server - user root with no password required
if [ "$HACK_SSH" = "YES" ]; then
    /media/hack/dropbearmulti dropbear -r /media/hack/dropbear_ecdsa_host_key -B
fi

# FTP Server
if [ "$HACK_FTP" = "YES" ]; then
    (/home/busybox/tcpsvd -E 0.0.0.0 21 /home/busybox/ftpd -w / ) &
fi

# Telnet Server
if [ "$HACK_TELNET" = "NO" ]; then
    start-stop-daemon -K -n telnetd
fi



# Sync the time
(sleep 20 && /home/busybox/ntpd -q -p 0.uk.pool.ntp.org ) &

#camera config, mine is modified to disable the whitelight | support_doublelight = 2
mountBakRW
mount --bind /media/hack/bak/hwcfg.ini /bak/hwcfg.ini
# Silence the voices
if [ "$VOICE" = "YES" ]; then
    mount --bind /media/hack/bak/VOICE.tgz /bak/VOICE.tgz
fi
mountBakRO