#!/bin/bash
# 日志文件daos_server.yml配置脚本
# 脚本功能：配置集群所有节点daos_server.yml日志
# 使用方法：在集群Handy节点、任一位置执行脚本即可配置集群所有节点daos_server.yml日志，脚本会自动获取集群节点IP.
daos_server_path="etc/daos/daos_server.yml" # 需要同步修改revise函数中路径

# content to revise
function revise {
        sed -i '/- FI_OFI_RXM_USE_SRX=1/i \
  - DAOS_MD_CAP=1024\
  - CRT_TIMEOUT=120\
  - D_LOG_SIZE=5g\
  - D_LOG_MASK=DEBUG\
  - DD_SUBSYS=all\
  - DD_MASK=all\
  - HG_LOG_SUBSYS=hg,na,cls,op\
  - HG_LOG_LEVEL=debug\
  - HG_NA_LOG_LEVEL=debug' /etc/daos/daos_server.yml ;
        sed -i "s/INFO/DEBUG/g" /etc/daos/daos_server.yml ;
}

# interact (y/n)
function yes_or_no {
        read -r input_str
    while [[ ! $input_str =~ ^([yY][eE][sS]|[yY])$ ]] && [[ ! $input_str =~ ^([nN][oO]|[nN])$ ]]; do
                read -r -p "[INFO] Input 'yes' or 'no' : " input_str
        done
        if [[ $input_str =~ ^([yY][eE][sS]|[yY])$ ]]; then
                return 1;
        else
                return 0;
        fi
}

# check current node id
function check_node {
    # $1 nodes $2 num_nodes
        array="`ifconfig -a |grep -v inet6 |grep inet|grep -v 127.0.0.1|awk '{print $2}'`"
        nodes=$1
        num_nodes=$2
        for var in ${array[@]}
        do
                for((i=0; i<$num_nodes; i++))
                do

                if [[ "$var" == $nodes[$i] ]]; then
                        return $i
                fi
                done
        done

}

# check if already configrution
function already_config {
        result=$(grep D_LOG_MASK $daos_server_path)
        if [[ $result != "" ]]; then
                echo "[ERROR]The config file already configured "
                return 1
        else
                return 0
        fi
}






# if the config file exist
if [ -e $daos_server_path ]; then

        # if already_config
        if already_config; then
                echo "Starting"
        else
                exit 0
        fi


        # get the ip of nodes
        num_nodes=`sed -n '/[0-9]\{1,\}.[0-9]\+.[0-9]\+.[0-9]\+$/p' $daos_server_path | awk '{print $2}'| wc -l`
        echo "[INFO]The nodes number of the cluster is $num_nodes"
        nodes[$((num_nodes-1))]=""
        for ((i=1; i<=$num_nodes; i++));
        do
            nodes[(($i-1))]=`sed -n '/[0-9]\{1,3\}.[0-9]\+.[0-9]\+.[0-9]\+$/p' $daos_server_path | awk '{print $2}'| sed -n "${i}p"`

        done

        echo "[INFO]The nodes IP in the cluster are ${nodes[@]}"

        # check current node ip
        check_node $nodes $num_nodes
        node_id=$?
        echo "[INFO]Current node IP is ${nodes[$node_id]}"

        # revise remote node config file
        for ((i=0; i<$num_nodes; i++))
        do
                if [[ $i -ne $node_id ]]; then
                        ssh ${nodes[$i]}  "$(typeset -f revise); revise"
                fi
        done

        revise # revise current node config file


        echo "[INFO] The log configuration success"


        # restart daos_server

        for ((i=0; i<$num_nodes; i++))
        do
                if [[ $i -ne $node_id ]]; then
                        ssh ${nodes[$i]} "systemctl restart daos_server.service"
                fi
        done
        systemctl restart daos_server.service
        echo "[INFO] daos_server.service restart success"

else
        # configuration file is not exist
        echo "daos_server.yml is not exist, please check and try again";
fi
