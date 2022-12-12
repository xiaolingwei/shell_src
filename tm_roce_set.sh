#!/bin/bash

echo 'Query the nic information of a node'
ibdev2netdev


# 其他两个节点IP
node_ip1="55.149.1.85"
node_ip2="55.149.1.86"

nic_1="ens3f0"
nic_2="ens3f1"

#设置RoCE模式为V2
#echo 'Set RoCE V2..'

for i in {0,1};
do
 echo '[INFO]Set RoCE V2..';
 cma_roce_mode -d mlx5_$i -p 1 -m 2;
 ssh -q root@$node_ip1 "cma_roce_mode -d mlx5_$i -p 1 -m 2";
 ssh -q root@$node_ip2 "cma_roce_mode -d mlx5_$i -p 1 -m 2";
done
sleep 1

#设置QOS信任模式为DSCP
#echo 'Set qos_mode dscp..'
for j in {$nic_1,$nic_2};
do
 echo '[INFO]Set qos_mode dscp..';
 mlnx_qos -i $j --trust=dscp && echo ------------------;
 ssh -q root@$node_ip1 "mlnx_qos -i $j --trust=dscp && echo ------------------";
 ssh -q root@$node_ip2 "mlnx_qos -i $j --trust=dscp && echo ------------------";
done
sleep 1

#设置ToS(DSCP)值
#echo 'Set dscp_value 160..'
for i in {0,1};
do
 echo '[INFO]Set dscp_value 160..';
 cma_roce_tos -d mlx5_$i -t 160 && sleep 1;
 ssh -q root@$node_ip1 "cma_roce_tos -d mlx5_$i -t 160 && sleep 1";
 ssh -q root@$node_ip2 "cma_roce_tos -d mlx5_$i -t 160 && sleep 1";
done
sleep 1

#CNP的PFC有限级单独设置为6
#echo 'Set CNP_PFC 6..'
for j in {$nic_1,$nic_2};
do
 echo '[INFO]Set CNP_PFC 6..';
 echo 6 > /sys/class/net/$j/ecn/roce_np/cnp_802p_prio;
 ssh -q root@$node_ip1 "echo 6 > /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
 ssh -q root@$node_ip2 "echo 6 > /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
done
sleep 1

for j in {$nic_1,$nic_2};
do
 echo '[INFO]Query CNP_PFC..';
 cat /sys/class/net/$j/ecn/roce_np/cnp_802p_prio;
 ssh -q root@$node_ip1 "cat /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
 ssh -q root@$node_ip2 "cat /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
done
sleep 1

#设置RoCE的PFC的优先级
#echo 'Set priority_RoCE_PFC..'
for j in {$nic_1,$nic_2};
do
 echo '[INFO]Set priority_RoCE_PFC..';
 mlnx_qos -i $j --pfc=0,0,0,0,0,1,0,0 && sleep 1;
 ssh -q root@$node_ip1 "mlnx_qos -i $j --pfc=0,0,0,0,0,1,0,0 && sleep 1";
 ssh -q root@$node_ip2 "mlnx_qos -i $j --pfc=0,0,0,0,0,1,0,0 && sleep 1";
done
sleep 1

#设置TCP流量的ENC使能标记
echo '[INFO]Set TCP_ECN..'
sysctl -w net.ipv4.tcp_ecn=1
ssh -q root@$node_ip1 "sysctl -w net.ipv4.tcp_ecn=1"
ssh -q root@$node_ip2 "sysctl -w net.ipv4.tcp_ecn=1"


# 检查sysctl.conf
function check_sysctl {

echo "[INFO]Check and set sysctl.conf.."
if [[ `grep all.arp_ignore /etc/sysctl.conf` == "" ]]; then  # arp ignore
    sed -i "\$anet.ipv4.conf.all.arp_ignore = 1" /etc/sysctl.conf
fi

for j in {$1,$2};
do
if [[ `grep ${j}.rp_filter /etc/sysctl.conf` == "" ]]; then # rp filter
    sed -i "\$anet.ipv4.conf.${j}.rp_filter = 2" /etc/sysctl.conf
fi
done

for j in {$1,$2};
do
if [[ `grep ${j}.accept_local /etc/sysctl.conf` == "" ]]; then # accept local
    sed -i "\$anet.ipv4.conf.${j}.accept_local = 2" /etc/sysctl.conf
fi
done
echo "[INFO]OK!"

}


# 检查sysctl.conf配置
check_sysctl $nic_1 $nic_2
ssh -q root@$node_ip1  "$(typeset -f check_sysctl); check_sysctl $nic_1 $nic_2"
ssh -q root@$node_ip2  "$(typeset -f check_sysctl); check_sysctl $nic_1 $nic_2"



