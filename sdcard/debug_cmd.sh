#!/bin/sh

# Mount SD card to /media
if [ -b /dev/mmcblk0p1 ]; then
    mount /dev/mmcblk0p1 /media
elif [ -b /dev/mmcblk0 ]; then
    mount /dev/mmcblk0 /media
fi

# Include configuration file
. /media/config.txt

# Confirm hack type
touch /home/HACKSD

# Functions for remounting /bak
mountBakRW() {
    echo "Mounting /bak read & write ..."
    mount -o rw,remount /bak
}

mountBakRO() {
    echo "Mounting /bak read-only ..."
    mount -o ro,remount /bak
}

# Prepare directories
mkdir -p /home/busybox

# Install updated version of busybox
mount --bind /media/hack/busybox /bin/busybox
/bin/busybox --install -s /home/busybox

# Mount /etc/ files from microSD card
mount --bind /media/hack/etc/profile /etc/profile
mount --bind /media/hack/etc/group /etc/group
mount --bind /media/hack/etc/passwd /etc/passwd
mount --bind /media/hack/etc/shadow /etc/shadow

# Force timezone
echo "$TZ" > /media/hack/etc/TZ
(sleep 10 && mount --bind /media/hack/etc/TZ /etc/TZ) &

# Update hosts file to prevent cloud communication
if [ "$HACK_CLOUD" = "YES" ]; then
    mount --bind /media/hack/etc/hosts /etc/hosts
fi

# Wi-Fi Settings
if [ "$HACK_WIFI" = "YES" ]; then
    cat <<EOF > cls.conf
[cls_server]
ssid = $WIFI_SSID
passwd = $WIFI_PASSWORD
EOF
fi

# Start services
# Busybox HTTPD
if [ "$HACK_HTTPD" = "YES" ]; then

    if [[ -z "$WEB_AUTH_USER" ]]; then
        WEB_AUTH_USER="admin"
    fi
    if [[ -z "$WEB_ACCESS_PWD" ]]; then
        WEB_ACCESS_PWD="1234"
    fi
    
    #echo -e "/:$WEB_AUTH_USER:$WEB_ACCESS_PWD" >> /media/hack/etc/httpd.conf
    sed -i '/\/:/c\\/:'$WEB_AUTH_USER':'$WEB_ACCESS_PWD'' /media/hack/etc/httpd.conf
    touch /home/etc/httpd.conf
    mount --bind /media/hack/etc/httpd.conf /home/etc/httpd.conf
    /home/busybox/httpd -p $HTTP_PORT -h /media/hack/www -c /home/etc/httpd.conf
    #/home/busybox/httpd -p $HTTP_PORT -h /media/hack/www -C /media/hack/www/cgi-bin/
fi

# SSH Server
if [ "$HACK_SSH" = "YES" ]; then
    /media/hack/dropbearmulti dropbear -r /media/hack/dropbear_ecdsa_host_key -B
fi

# FTP Server
if [ "$HACK_FTP" = "YES" ]; then
    (/home/busybox/tcpsvd -E 0.0.0.0 21 /home/busybox/ftpd -w / ) &
fi

# Disable Telnet Server
if [ "$HACK_TELNET" = "NO" ]; then
    start-stop-daemon -K -n telnetd
fi

# Sync time with NTP server
(sleep 20 && /home/busybox/ntpd -q -p 0.uk.pool.ntp.org) &

# Camera configuration
# Disable the white light (example config: support_doublelight = 2)
mount --bind /media/hack/home/hwcfg.ini /home/hwcfg.ini

# Silence the voices
if [ "$VOICE" = "YES" ]; then
    mount --bind /media/hack/home/VOICE.tgz /home/VOICE.tgz
fi
