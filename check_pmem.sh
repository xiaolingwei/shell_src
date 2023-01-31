#!/bin/bash

# 功能: 检查pmem状态

echo "[INFO] The state of PMEM regions are:"
ipmctl show -region

echo "[INFO] The namespaces of PMEM are:"
ndctl list --human

if [[ `ipmctl show -region | grep Healthy | wc -l` != `ipmctl show -region |grep 0x | wc -l` ]]; then
        echo "[ERROR] The PMEM region 'HealthState' may have some problems."
fi

if [[ `ipmctl show -region | grep AppDirectNotInterleaved | wc -l` != `ipmctl show -region |grep 0x | wc -l` ]]; then
        echo "[ERROR] The PMEM region 'PersistentMemoryType' may have some problems."
fi

if [[ `ndctl list --human | grep dev` != "" ]]; then
        echo "[ERROR] The PMEMs have namespaces which may you want to destroy."
fi





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

echo "[WARNING] If you want to reset the PMEM, please input yes or no."


if yes_or_no
then
        echo "[INFO] Exit"
else
        echo "ndctl destroy-namespace all"
        ndctl destroy-namespace all --force
        sleep 2
        echo "ipmctl delete goal"
        ipmctl delete goal
        sleep 2
        echo "ipmctl create -goal"
        ipmctl create -goal
        echo "[INFO] The PMEM have been reset."
fi
