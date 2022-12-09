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
 echo 'Set RoCE V2..';
 cma_roce_mode -d mlx5_$i -p 1 -m 2;
 ssh -q root@$node_ip1 "cma_roce_mode -d mlx5_$i -p 1 -m 2";
 ssh -q root@$node_ip2 "cma_roce_mode -d mlx5_$i -p 1 -m 2";
done
sleep 1

#设置QOS信任模式为DSCP
#echo 'Set qos_mode dscp..'
for j in {$nic_1,$nic_2};
do
 echo 'Set qos_mode dscp..';
 mlnx_qos -i $j --trust=dscp && echo ------------------;
 ssh -q root@$node_ip1 "mlnx_qos -i $j --trust=dscp && echo ------------------";
 ssh -q root@$node_ip2 "mlnx_qos -i $j --trust=dscp && echo ------------------";
done
sleep 1

#设置ToS(DSCP)值
#echo 'Set dscp_value 160..'
for i in {0,1};
do
 echo 'Set dscp_value 160..';
 cma_roce_tos -d mlx5_$i -t 160 && sleep 1;
 ssh -q root@$node_ip1 "cma_roce_tos -d mlx5_$i -t 160 && sleep 1";
 ssh -q root@$node_ip2 "cma_roce_tos -d mlx5_$i -t 160 && sleep 1";
done
sleep 1

#CNP的PFC有限级单独设置为6
#echo 'Set CNP_PFC 6..'
for j in {$nic_1,$nic_2};
do
 echo 'Set CNP_PFC 6..';
 echo 6 > /sys/class/net/$j/ecn/roce_np/cnp_802p_prio;
 ssh -q root@$node_ip1 "echo 6 > /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
 ssh -q root@$node_ip2 "echo 6 > /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
done
sleep 1

for j in {$nic_1,$nic_2};
do
 echo 'Query CNP_PFC..';
 cat /sys/class/net/$j/ecn/roce_np/cnp_802p_prio;
 ssh -q root@$node_ip1 "cat /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
 ssh -q root@$node_ip2 "cat /sys/class/net/$j/ecn/roce_np/cnp_802p_prio";
done
sleep 1

#设置RoCE的PFC的优先级
#echo 'Set priority_RoCE_PFC..'
for j in {$nic_1,$nic_2};
do
 echo 'Set priority_RoCE_PFC..';
 mlnx_qos -i $j --pfc=0,0,0,0,0,1,0,0 && sleep 1;
 ssh -q root@$node_ip1 "mlnx_qos -i $j --pfc=0,0,0,0,0,1,0,0 && sleep 1";
 ssh -q root@$node_ip2 "mlnx_qos -i $j --pfc=0,0,0,0,0,1,0,0 && sleep 1";
done
sleep 1

#设置TCP流量的ENC使能标记
echo 'Set TCP_ECN..'
sysctl -w net.ipv4.tcp_ecn=1
ssh -q root@$node_ip1 "sysctl -w net.ipv4.tcp_ecn=1"
ssh -q root@$node_ip2 "sysctl -w net.ipv4.tcp_ecn=1"


