#!/bin/bash

bond_name=$1
slave1=$2
slave2=$3
IP=$4
PREFIX=$5

# 设置bond
for slave in {$slave1,$slave2};
do

  sed -i "s/^BOOTPROTO.*$/BOOTPROTO=none/"  /etc/sysconfig/network-scripts/ifcfg-$slave
  sed -i "s/^ONBOOT.*$/ONBOOT=yes/"  /etc/sysconfig/network-scripts/ifcfg-$slave
  echo  "MASTER=$bond_name" >> /etc/sysconfig/network-scripts/ifcfg-$slave
  echo  "SLAVE=yes" >> /etc/sysconfig/network-scripts/ifcfg-$slave
done

touch /etc/sysconfig/network-scripts/ifcfg-$bond_name


cat > /etc/sysconfig/network-scripts/ifcfg-$bond_name <<- EOF
DEVICE=$bond_name
NAME=$bond_name
TYPE=Bond
BONDING_MASTER=yes
IPADDR=$IP
PREFIX=$PREFIX
ONBOOT=yes
BOOTPROTO=static
BONDING_OPTS="mode=4 miimon=100 lacp_rate=fast xmit_hash_policy=layer3+4 updelay=30000 downdelay=0"
EOF
~
