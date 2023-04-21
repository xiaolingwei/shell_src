#!/bin/bash
# 日志文件daos_server.yml配置脚本
# 脚本功能：配置集群所有节点daos_server.yml,daos_block.yml日志
# 使用方法：修改开头集群列表，在集群Handy节点、任一位置执行脚本即可配置集群所有节点daos_server.yml,daos_block.yml

nodes=(55.149.1.83 55.149.1.85 55.149.1.86) # 节点列表

daos_server_path="/etc/daos/daos_server.yml" # 需要同步修改revise函数中路径
# content to revise
function revise {
        # 设置开启DEBUG日志的模块 - DD_SUBSYS前空两个空格
        sed -i '/- FI_OFI_RXM_USE_SRX=1/i \
  - DD_SUBSYS= - DD_SUBSYS=vos,tree,dtx,pool,container,rebuild,server,array,rpc,object\
  - DD_MASK=all\
  - SWIM_ROCEV_TIMEOUT=60' /etc/daos/daos_server.yml ;
        sed -i "s/INFO/DEBUG/g" /etc/daos/daos_server.yml ;
        # 设置客户端DEBUG
        sed -i "s/INFO/DEBUG/g" /etc/daos/daos_block.yml ;
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

# check if already configrution
function already_config {
        result=$(grep DD_SUBSYS $daos_server_path)
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

        # revise remote node config file
        for node in ${nodes[@]}
        do
            ssh $node  "$(typeset -f revise); revise"
        done

        echo "[INFO] The log configuration success"

        # restart daos_server
        for node in ${nodes[@]}
        do
            ssh $node "systemctl restart daos_server.service"
        done
        echo "[INFO] daos_server.service restart success"

else
        # configuration file is not exist
        echo "daos_server.yml is not exist, please check and try again";
fi
