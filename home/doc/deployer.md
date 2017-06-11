#### Hardware
We need a deploy host, as well as target hosts to which we will be deploying.
<details>
<summary>Hardware requirements</summary>

*Deployer:*
The inital host that deploys OpenBSD.
  - Rasbberry pi 2 (I used a kano kit with kano HDMI monitor)
  - 64GB micro SD card

*Targets:*
We also need target hosts onto which we'll be installing OpenBSD.
  - Soekris net5501 (at least 2) for a redundant firewall
  - One switch per network (up to 4, as the soekris 5501 has 4 NICs)
</details>

#### Installation Media
  You'll need a copy of the OpenBSD install media staged on the deploy server from which to install.
<details>
<summary>Preparing the OpenBSD install space.</summary>
Decide which version of openBSD to install: ftp://mirror.esc7.net/pub/OpenBSD/
Download the iso and copy it to some place served up by nginx.
We'll use 6.1 in the following examples.

```
apt-get install -y nginx rsync
[ ! -d /var/www/html/openbsd/install61 ] && mkdir -p /var/www/html/openbsd/install61
wget -O /tmp/install61.iso "ftp://mirror.esc7.net/pub/OpenBSD/6.1/i386/install61.iso"
mount -o loop /tmp/install61.iso /mnt/
rsync -avzPC /mnt/ /var/www/html/openbsd/install61/
umount /mnt

```

If you don't create an index.txt the installer throws its hands up.

```
(cd /var/www/html/openbsd/install61/6.1/i386; ls -ln > index.txt)

```


Auto indexing is evidently something the OpenBSD installer relies on:
Add `autoindex on;` to the `server` section of `/etc/nginx/sites-enabled/default` and `/etc/init.d/nginx restart`

</details>

#### TFTP
You'll need to install and configure the Trivial File Transfer Protocol (TFTP) Service.
<details>
<summary>Preparing the TFTP service.</summary>

```
apt-get install -y tftpd-hpa
[ ! -d /etc/default/tftpd-hpa.dist ] && cp /etc/default/tftpd-hpa /etc/default/tftpd-hpa.dist
cat<<EOF> /etc/default/tftpd-hpa
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
# TFTP_OPTIONS="-4 --secure --create"
TFTP_OPTIONS="-4 --secure"
EOF

/etc/init.d/tftpd-hpa restart
```

Get the files the boostrap process will need:

```
(
  wget -O /srv/tftp/pxeboot.openbsd ftp://mirror.esc7.net/pub/OpenBSD/6.1/i386/pxeboot
  (cd /srv/tftp; ln -s pxeboot.openbsd auto_install)

  mount -o loop /tmp/install61.iso /mnt/
  [ ! -d /srv/tftp/pxelinux.kernels/openbsd/6.1 ] && \
    mkdir -p /srv/tftp/pxelinux.kernels/openbsd/6.1
  mount -o loop /tmp/install61.iso /mnt/
  cp /mnt/6.1/i386/bsd.rd /srv/tftp/pxelinux.kernels/openbsd/6.1/bsd.rd
  umount /mnt

  [ ! -d /srv/tftp/etc ] && \
    mkdir -p /srv/tftp/etc
cat<<EOF > /srv/tftp/etc/boot.conf
set tty com0
stty com0 38400
boot pxelinux.kernels/openbsd/6.1/bsd.rd
EOF

dd if=/dev/random of=/srv/tftp/etc/random.seed bs=512 count=1
chmod 644 /srv/tftp/etc/random.seed

```

Ensure you can download files via tftp: (This will save you a lot of grief later.)
From your workstation:

```
$ cd /tmp
$ tftp 10.255.1.101
tftp> get auto_install
Received 97444 bytes in 8.5 seconds
tftp> get etc/boot.conf
Received 73 bytes in 0.0 seconds
tftp> get pxelinux.kernels/openbsd/6.1/bsd.rd

```
</details>

#### Serial Console
We'll need to console the target from the deployer in order to get the target's MAC address.
<details>
<summary>Set up minicom, serial console a soekris 5501 with a pl2303 adapter</summary>

```
apt-get install -y minicom

cat<<EOF> /root/minirc.ttyUSB0
# Machine-generated file - use setup menu in minicom to change parameters.
pu port             /dev/ttyUSB0
pu baudrate         38400
pu bits             8
pu parity           N
pu stopbits         1
pu rtscts           No
EOF

```

Use a minicom session to grab the MAC Address the soekris will attempt to PXE boot from

sample session output:
```
minicom ttyUSB0
Welcome to minicom 2.7

OPTIONS: I18n
Compiled on Jan 12 2014, 05:42:53.
Port /dev/ttyUSB0, 18:31:36

Press CTRL-A Z for help on special keys

> show

ConSpeed = 38400
ConLock = Enabled
ConMute = Disabled
BIOSentry = Enabled
PCIROMS = Enabled
PXEBoot = Enabled
FLASH = Primary
BootDelay = 5
FastBoot = Disabled
BootPartition = Disabled
BootDrive = 80 81 F0 FF
ShowPCI = Enabled
Reset = Hard
CpuSpeed = Default

> set BootDrive F0 80 81 FF
> reboot
POST: 012345689bcefghips1234ajklnopqr,,,tvwxy
comBIOS ver. 1.33  20070103  Copyright (C) 2000-2007 Soekris Engineering.
net5501
CPU Geode LX 500 Mhz
0000 Mbyte Memory
0512
Pri Mas  SanDisk SDCFH-004G              LBA Xlt 968-128-63  3906 Mbyte
Slot   Vend Dev  ClassRev Cmd  Stat CL LT HT  Base1    Base2   Int
-------------------------------------------------------------------
0:01:2 1022 2082 10100000 0006 0220 08 00 00 A0000000 00000000 10
0:06:0 1106 3053 02000096 0117 0210 08 40 00 0000E101 A0004000 11
0:07:0 1106 3053 02000096 0117 0210 08 40 00 0000E201 A0004100 05
0:08:0 1106 3053 02000096 0117 0210 08 40 00 0000E301 A0004200 09
0:09:0 1106 3053 02000096 0117 0210 08 40 00 0000E401 A0004300 12
0:20:0 1022 2090 06010003 0009 02A0 08 40 80 00006001 00006101
0:20:2 1022 209A 01018001 0005 02A0 08 00 00 00000000 00000000
0:21:0 1022 2094 0C031002 0006 0230 08 00 80 A0005000 00000000 15
0:21:1 1022 2095 0C032002 0006 0230 08 00 00 A0006000 00000000 15
Seconds to automatic boot.   Press Ctrl-P for entering Monitor.
 5
 4
 3
 2
 1
Intel UNDI, PXE-2.0 (build 082)
Copyright (C) 1997,1998,1999  Intel Corporation
VIA Rhine III Management Adapter v2.43 (2005/12/15)
CLIENT MAC ADDR: 00 00 24 CC 5B 00.

```
</details>

#### DHCP
<details>
DHCP is used to bootstrap PXE, which bootstraps TFTP
<summary>DHCP</summary>

Set up DHCP
  - wlan0: 10.255.3.101/24 (uplink)
  - eth0:  10.255.1.101/24 (downlink)

```
apt-get install -y isc-dhcp-server bind9

cat<<EOF > /etc/dhcp/dhpcd.conf
ddns-update-style none;
option domain-name "apt.jameswhite.org";
option domain-name-servers 10.255.1.101;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;

subnet 10.255.3.0 netmask 255.255.255.0 {
  deny unknown-clients;
}

subnet 10.255.1.0 netmask 255.255.255.0 {
  option routers 10.255.1.101;
  # clients
  deny unknown-clients;

  host hogun {
               hardware ethernet 0:0:24:cc:5b:00;
               next-server 10.255.1.101;
               fixed-address 10.255.1.105;
               filename "auto_install";
               server-name "10.255.1.101";
             }
}

EOF
/etc/init.d/isc-dhcp-server restart
```

Now when the target is booted, it will query DHCP, and dhcpd will tell it to download `auto_install` from `next-server 10.255.1.101;` (deployer) over tftp. We symlinked `auto_install` to `pxeboot.openbsd` back in the [TFTP section](https://github.com/jameswhite/dotfiles/blob/master/home/doc/deployer.md#tftp).
The `pxeboot.openbsd` file pulls down `etc/boot.conf` from tftp, which we created back in the [TFTP section](https://github.com/jameswhite/dotfiles/blob/master/home/doc/deployer.md#tftp) and it says to download `pxelinux.kernels/openbsd/6.1/bsd.rd`
The `bsd.rd` makes some assumptions, and tells the target to try to grab a file named `00:00:24:cc:5b:00-install.conf` (the target's MAC address) from `next-server 10.255.1.101;`, so we'd better put it there.

This creates the answerfile for hogun (our target.)
```
cat<<EOF > /var/www/html/00:00:24:cc:5b:00-install.conf
System hostname = hogun
Terminal type? = vt220
System hostname = hogun
Which network interface do you wish to configure? = vr0
IPv4 address for em0 = dhcp
#  Password for root = bearing-cajole-envision-hew-mangrove-algiers
Password for root account? = $2y$10$K7h8pG4gZnl2sG6E2AybPupvp3fzoWy6ElmShBAdKIS9Jidnh0M3u
Public ssh key for root account? = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLuHahxjD7lAWGpE1LLFXenj+90WcMBzZNdw1OuCqOR9ioJag/atjKRuV7e/SiZ2ITtArjsz/YRCsgdaB34YTovFVf5U59uGuiawfa2zpTk8TmojvpcNqNOll4kM6Fa280Uu89cy8aCANhPnnZC4l9YBuuemCDllFPvcUTkN5GpIr0eWEsI+ZbCW4jDsLsZHCFMJ0MbeRfJR1wqid+AgB3xeEIJulpqinWkx3IyGHDnG//A4AglXw7ndz0gxEeE1JAtvVX20CgZPFdRk4UivU8MtLffAh5G/gCYsDjKXHaZaswpvQAf3BcI1WuBqfA2KwP2GJLw93wmbb0euWCwJfYUobeedjxWUzscYzY5yCadPZla+FGEPCbTeRK525OxgRkxXRzW2Tlidba8wKI0xMJ66ZqizRV4wBJvEZDOI+s+kAuPEHR7RIHmagfEUUHQQFKOFxIsfBYnA5Bo12HVopEkbImQTJrAu0mwwChZD+TgOtfRLs35Cgn5uBbHGU+DKt47uMN/ZTWL/CaFX+mDv3fB1W3bB1b3g6GxpttHBtESddNXeeMY5TfT8ffMj/uOQ2aZWOwqFIlDqtvbuNxLCpjGGJKM0FFZMVq9JQ01aEF98oNNv0cwJ5fUNijndF3n7D1sfEo4mt/Fe2Ni7muusWAAjMs6BCP9cHRKj+Lgio/Yw== jameswhite@forseti.local
Start sshd(8) by default? = yes
Start ntpd(8) by default? = yes
NTP server? (hostname or 'default') = default
Do you expect to run the X Window System? = no
Change the default console to com0? = yes
Which speed should com0 use? (or 'done') = 38400
What timezone are you in? = UTC
Which disk is the root disk? = sd0
Setup a user = opt
#  Password for user = thrush-towel-rhizome-iodide-sleek-charisma
Password for user = $2y$10$7ieMw0.SjpubhVay2OeN2O/JSCmXyEcEjp3UkX9pP2IZpVqK8xSti
Use DUIDs rather than device names in fstab? = yes
Use (W)hole disk or (E)dit the MBR? = W
Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout? = a
# URL to autopartitioning template = http://10.255.1.101/openbsd/openbsd_autodisklabel
Which disk do you wish to initialize? = done
Location of sets = http
HTTP proxy URL = none
HTTP Server = 10.255.1.101
Server directory = openbsd/install61/6.1/i386/
Use http instead = yes
Set name(s)? = -all bsd bsd.rd bsd.mp base61.tgz comp61.tgz man61.tgz game61.tgz done
Directory does not contain SHA256.sig. Continue without verification = yes
Location of sets? = done
EOF

# Make a symlink so we know what file is what later.
(cd /var/www; ln -s 00:00:24:cc:5b:00-install.conf hogun-install.conf)

```

</details>

#### PXE booting and installing the target
With the target set to boot from PXE, and the deployer listening on DHCP, TFTP, and HTTP, deploy our target.
<details>
<summary>Troubleshooting the deployment process.</summary>

Attach to the serial console of the target with `minicom ttyUSB0` We wired this up in [Serial Console](https://github.com/jameswhite/dotfiles/blob/master/home/doc/deployer.md#serial-console).
You should see it request PXE, get an IP address, and pull down the `auto_install` file.

The log for dhcpd is `/var/log/syslog`, so `tail  -f /var/log/syslog` on the deployer.
Sample Output:

```
May 14 19:34:36 deployer dhcpd: DHCPDISCOVER from 00:00:24:cc:5b:00 via eth0
May 14 19:34:36 deployer dhcpd: DHCPOFFER on 10.255.1.102 to 00:00:24:cc:5b:00 via eth0
May 14 19:34:37 deployer dhcpd: DHCPREQUEST for 10.255.1.102 (10.255.1.101) from 00:00:24:cc:5b:00 via eth0
May 14 19:34:37 deployer dhcpd: DHCPACK on 10.255.1.102 to 00:00:24:cc:5b:00 via eth0
```

Having tcpdump running on port 69 (tftp) is also helpful. You should see a lot of activity at the same time that the console is trying to PXE boot.

```
apt-get install -y tcpdump
tcpdump -i eth0 port 69
20:34:46.536189 IP 10.255.1.105.2070 > 10.255.1.101.tftp:  29 RRQ "auto_install" octet tsize 0
20:34:46.565168 IP 10.255.1.105.2071 > 10.255.1.101.tftp:  34 RRQ "auto_install" octet blksize 1456
20:34:46.731693 IP 10.255.1.105.2728 > 10.255.1.101.tftp:  23 RRQ "/etc/boot.conf" octet
20:34:51.062208 IP 10.255.1.105.2733 > 10.255.1.101.tftp:  25 RRQ "/etc/random.seed" octet
20:34:51.082028 IP 10.255.1.105.2733 > 10.255.1.101.tftp:  44 RRQ "pxelinux.kernels/openbsd/6.1/bsd.rd" octet
20:34:51.090949 IP 10.255.1.105.2733 > 10.255.1.101.tftp:  44 RRQ "pxelinux.kernels/openbsd/6.1/bsd.rd" octet
```

The nginx log is `/var/log/nginx/access.log`. Look for it to pull down the `<macaddress>-install.conf`

Once the serial console says it's `Installing bsd` comment out everything in the `host hogun` block in `/etc/dhcp/dhcpd.conf` except the harware and fixed-address lines:
This will keep it from going into an infinite re-install loop.

```
  host hogun {
               hardware ethernet 0:0:24:cc:5b:00;
               fixed-address 10.255.1.105;
               # next-server 10.255.1.101;
               # filename "auto_install";
               # server-name "10.255.1.101";
             }
```
</details>

#### Additional Hosts
<details>

Adding additional hosts:

<summary>Deploying additional hosts:</summary>

Console the device, (it defaults to 19200 8n1, set it to 38400 8n1)
Set BootDrive=F0 80 81 FF to make it pxe boot to reveal the MAC address.
Get the MAC address:  00 00 24 CC E9 E4

add a host entry to `/etc/dhcp/dhcpd.conf`

```
host fandral {
                 hardware ethernet 0:0:24:cc:e9:e4;
                 fixed-address 10.255.1.106;
                 next-server 10.255.1.101;
                 filename "auto_install";
                 server-name "10.255.1.101";
             }
```

Bounce dhpcd `/etc/init.d/isc-dhcp-server restart`
Create a /var/www/html/00:00:24:cc:e9:e4-install.conf` and symlink it to `fandral-install.conf`
Reboot the device.
Once it says Installing bsd, comment out `next-server`, `filename`, and `server-name` and restart `isc-dhcp-server`

Repeat as necessary for all soekris boxes.

```
  host volstagg {
                  hardware ethernet 0:0:24:cc:e3:84;
                  fixed-address 10.255.1.107;
                  next-server 10.255.1.101;
                  filename "auto_install";
                  server-name "10.255.1.101";
                }
```

</details>


On the deployer node
echo 1> /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
/sbin/iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT

On the targets:
env PKG_PATH="ftp://mirror.esc7.net/pub/OpenBSD/`uname -r`/packages/`uname -m`/" pkg_add "curl"
env PKG_PATH="ftp://mirror.esc7.net/pub/OpenBSD/`uname -r`/packages/`uname -m`/" pkg_add "salt"

