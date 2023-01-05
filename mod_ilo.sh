#!/bin/bash


read -p "Please input your new ilo ip:" mod_ip
read -p "Please input your new ilo gateway:" mod_gateway


ipmitool lan set 8 ipsrc static
ipmitool lan set 8  ipaddr  $mod_ip
ipmitool lan set 8  netmask  255.255.0.0
ipmitool  lan  set  8  defgw  ipaddr $mod_gateway
ipmitool  lan  print 8

ipmitool lan set 1 ipsrc static
ipmitool lan set 1  ipaddr  $mod_ip
ipmitool lan set 1  netmask  255.255.0.0
ipmitool  lan  set  1  defgw  ipaddr $mod_gateway
ipmitool  lan  print 1
