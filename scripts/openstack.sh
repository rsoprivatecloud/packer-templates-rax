#!/bin/bash
set -x

# Turn off reverse DNS lookups so SSH login is faster
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Turn off unused SSH authentication protocols
sed -i '/GSSAPIAuthentication / s/ .*/ no/' /etc/ssh/sshd_config

# Install cloud-init packages
yum -y install cloud-utils cloud-init cloud-utils-growpart parted git

# Change cloud-init user from the default centos to rack
cat > /etc/cloud/cloud.cfg.d/02_user.cfg <<EOL
system_info:
  default_user:
    name: rack
    lock_passwd: true
    gecos: Rack user
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
EOL

# Disable zeroconf
echo 'NOZEROCONF=yes' >> /etc/sysconfig/network
echo 'PERSISTENT_DHCLIENT=yes' >> /etc/sysconfig/network

# Make sure output shows up in nova console-log and OpenStack VNC/SPICE consoles
sed -i '/GRUB_CMDLINE_LINUX=/ s/=.*/=\"console=tty0 crashkernel=auto console=ttyS0,115200\"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Remove device specific configuration
rm -f /etc/udev/rules.d/70-persistent-net.rules
touch /etc/udev/rules.d/70-persistent-net.rules

# Remove existing UUIDs and MAC addresses in the network configuration files
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# eth0 is usually the device with the default gateway.
# Make sure the eth1 default gateway doesn't clobber the eth0 default gateway.
echo 'GATEWAYDEV=eth0' >> /etc/sysconfig/network

# Support second network interface
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOL
DEVICE="eth1"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOL

# Disable root password and login
passwd -d root
passwd -l root
