#!/bin/sh

# 1. Mount SD card
if [ -b /dev/mmcblk0p1 ]; then
    mount /dev/mmcblk0p1 /media
elif [ -b /dev/mmcblk0 ]; then
    mount /dev/mmcblk0 /media
fi

# 2. Setup Hack Environment
HACK_BIN="/home/busybox"
mkdir -p $HACK_BIN
chmod +x /media/hack/busybox

# 3. Create Symlinks for YOUR tools
# We point these directly to the SD card binary to avoid "applet not found"
ln -sf /media/hack/busybox $HACK_BIN/httpd
ln -sf /media/hack/busybox $HACK_BIN/ftpd
ln -sf /media/hack/busybox $HACK_BIN/tcpsvd
ln -sf /media/hack/busybox $HACK_BIN/ntpd

mount --bind /media/hack/etc/profile /etc/profile
mount --bind /media/hack/etc/passwd /etc/passwd
mount --bind /media/hack/etc/shadow /etc/shadow
mount --bind /media/hack/etc/group /etc/group


# 4. Path Injection
# Your tools come first, but the system's original tools
# remain available in /bin/ as a fallback.
export PATH=$HACK_BIN:/usr/bin:/usr/sbin:/bin:/sbin

# 5. Load Configuration
[ -f /media/config.txt ] && . /media/config.txt

# 6. SSH connection with ecdsa key
if [ "$HACK_SSH" = "YES" ]; then
    #copying authorized_keys to tmp folder because specific storage permission are needed
    mkdir -p /tmp/root/.ssh
    cp /media/hack/root/.ssh/authorized_keys /tmp/root/.ssh/authorized_keys
    chmod 700 /tmp/root
    chmod 700 /tmp/root/.ssh
    chmod 600 /tmp/root/.ssh/authorized_keys
    mount --bind /tmp/root /root
    
    # to access without password or key change to: 
    # /media/hack/dropbearmulti dropbear -r /media/hack/dropbear_ecdsa_host_key -B
    
    /media/hack/dropbearmulti dropbear -r /media/hack/dropbear_ecdsa_host_key
fi

if [ "$HACK_CLOUD" = "YES" ]; then
    mount --bind /media/hack/etc/hosts /etc/hosts
fi

# 7. Start Servers
if [ "$HACK_HTTPD" = "YES" ]; then
    $HACK_BIN/httpd -p 8080 -h /media/hack/www
fi

if [ "$HACK_FTP" = "YES" ]; then
    ($HACK_BIN/tcpsvd -E 0.0.0.0 21 $HACK_BIN/ftpd -w / ) &
fi

if [ "$HACK_TELNET" = "NO" ]; then
    killall telnetd 2>/dev/null
fi

# 8. Time Sync
(sleep 30 && $HACK_BIN/ntpd -q -p 0.pool.ntp.org ) &
echo "UTC-1" > /etc/TZ

# 9. Silence the voices
if [ "$VOICE" = "YES" ]; then
    mount --bind /media/hack/home/VOICE.tgz /home/VOICE.tgz
fi

# Disable the white light (example config: support_doublelight = 2)
mount --bind /media/hack/home/hwcfg.ini /home/hwcfg.ini

# 10. --- Connectivity Watchdog ---
(
    # Wait 2 minutes for the router to boot
    sleep 120 
    
    # If no IP address is assigned to ANY interface
    if ! ifconfig | grep -q "inet "; then
        echo "$(date): WiFi/Router not found. Rebooting..." >> /media/log.txt
        sync
        reboot
    else
        echo "$(date): Network OK. IP: $(ifconfig | grep 'inet ' | awk '{print $2}')" >> /media/log.txt
    fi
) &

echo "Hack script finished successfully." >> /media/log.txt