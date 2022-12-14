#!/bin/bash


function not_in_array {

    array=$1
    element=$2
    for var in ${array[@]}
    do
        if [[ $var != $element ]]
        then
            return 1
        fi
    done
    return 0
}


# 已经配好网络的修改网口IP
nic_port=(`ifconfig | grep flag | grep -v lo | awk '{print $1}'| tr "\n" " "|tr ":" " "`)
nic_ip=(`ifconfig -a |grep -v inet6 |grep inet|grep -v 127.0.0.1|awk '{print $2}'|tr "\n" " "`)

nic_port_num=${#nic_port[@]}
echo "The list of NIC port in use:"
for ((i=0;i<$nic_port_num;i++))
do
    echo "${nic_port[$i]}: ${nic_ip[$i]}"
done


read -p "Please input NIC port you want revise:" NIC
#检查网卡是否存在
if `not_in_array ${nic_port} $NIC`
then
    echo "[ERROR]${NIC} is not in the list."
    exit 0
else
    echo "[INFO]Choose ${NIC}"
fi

# 输入IP
read -p "Please input IP you want:" IP


echo "[INFO]New ip is:$IP"
sed -i "s/^IPADDR.*$/IPADDR=$IP/"  /etc/sysconfig/network-scripts/ifcfg-$NIC
echo "[WARRING] service network restart"
service network restart
