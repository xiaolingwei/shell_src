#!/bin/bash

#脚本功能：收集三个节点的daos、storage中的日志，以及系统状态。
#使用说明：使用前需要修改开头处的节点IP。


# Please execute at handy node
handy_node="55.149.1.83"
node1="55.149.1.85"
node2="55.149.1.86"


# 检查当前节点是否为handy
function check_node {
        array="`ifconfig -a |grep -v inet6 |grep inet|grep -v 127.0.0.1|awk '{print $2}'`"
        for var in ${array[@]}
        do
                if [[ "$var" == "$handy_node" ]]; then
                        return 0
                fi
        done
        return 1
}


# 收集日志
function log_coll {
        now_time=$1
        mkdir -p "/root/log_collect/log_bak_$now_time"

        cp /var/log/messages /root/log_collect/log_bak_$now_time/
        cp -r /var/log/daos/ /root/log_collect/log_bak_$now_time/
        cp -r /var/log/storage/ /root/log_collect/log_bak_$now_time/
        cp -r /etc/daos/ /root/log_collect/log_bak_$now_time/

}

# 收集集群状态
function log_status {
        file=$1
        touch $file
        echo "dmg sys query -v:" >> $file
        dmg sys query -v && dmg sys query -v >> $file
        echo "dmg pool list:" >> $file
        dmg pool list && dmg pool list >> $file
        read -p "Please enter you pool name:" pool_name
        echo "dmg pool query:" >> $file
        dmg pool query $pool_name && dmg pool query $pool_name >> $file
        echo "dmg system leader-query:"
        dmg system leader-query && dmg system leader-query >> $file
        echo "dmg storage query usage:"
        dmg storage query usage && dmg storage query usage >> $file
}



check_node
if (($? == 0)); then
        # 获取当前时间
        now_time=`date "+%Y%m%d_%H_%M_%S"`

        # ssh到远端执行log_coll收集日志函数
        ssh root@$node1 "$(typeset -f log_coll); log_coll $now_time"
        echo "[INFO]log collected at remote $node1"
        ssh root@$node2 "$(typeset -f log_coll); log_coll $now_time"
        echo "[INFO]log collected at remote $node2"

        # 本地收集日志
        log_coll $now_time
        echo "[INFO]log collected at local host"
        # 本地收集集群状态
        log_status /root/log_collect/log_bak_$now_time/daos_status
        echo "[INFO]log collected success"
else
        echo "[ERROR]Please execute at handy node." # 不是handy node 提示
fi
