  1. Hardware
<details>
<summary>Hardware requirements</summary>
We need a host to deploy our soekris boxes.

  - Rasbberry pi 2 (I used a kano kit with kano HDMI monitor)
  - 64GB Compact flash

We also need a host we'll be installing OpenBSD on:

  - Soekris net5501 (at least 2) for a redundant firewall
  - One switch per network (up to 4, as the soekris 5501 has 4 NICs)

</details>

  1. You'll need a copy of the OpenBSD install media staged on a web server from which to install.
<details>
<summary>Preparing the OpenBSD install space.</summary>

Decide which version of openBSD to install: ftp://mirror.esc7.net/pub/OpenBSD/
Download the iso and copy it to some place served up by nginx.
We'll use 6.1 in the following examples.

```
apt-get install -y nginx rsync
[ ! -d /usr/share/nginx/html/openbsd/install61 ] && mkdir -p /usr/share/nginx/html/openbsd/install61
wget -O /tmp/install61.iso "ftp://mirror.esc7.net/pub/OpenBSD/6.1/i386/install61.iso"
mount -o loop /tmp/install61.iso /mnt/
rsync -avzPC /mnt/ /usr/share/nginx/html/openbsd/install60/
umount /mnt
rm /tmp/install61.iso
```

</details>

  1. You'll need to install and configure the Trivial File Transfer Protocol (TFTP) Service.
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

(
  wget -o /srv/tftp/pxeboot.openbsd ftp://mirror.esc7.net/pub/OpenBSD/6.1/i386/pxeboot

  [ ! -d /srv/tftp/pxelinux.kernels/openbsd/6.1 ] && \
    mkdir -p /srv/tftp/pxelinux.kernels/openbsd/6.1
  wget -o /srv/tftp/pxelinux.kernels/openbsd/6.1/bsd.rd \
    ftp://mirror.esc7.net/pub/OpenBSD/6.1/i386/bsd.rd

  [ ! -d /srv/tftp/etc ] && \
    mkdir -p /srv/tftp/etc
cat<<EOF > cat /srv/tftp/etc/boot.conf
set tty com0
stty com0 38400
boot pxelinux.kernels/openbsd/6.0/bsd.rd
EOF

```

</details>

--

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

<details>
<summary>DHCP</summary>

Set up DHCP
  - wlan0: 10.255.3.101/24 (uplink)
  - eth0:  10.255.1.101/24 (downlink)

```
apt-get install -y isc-dhcp-server

cat<<EOF > /etc/dhcp/dhpcd.conf
ddns-update-style none;
option domain-name "apartment.jameswhite.org
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
}
EOF
```
</details>
