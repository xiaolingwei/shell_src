#!/bin/bash

# 创建多个卷脚本
# RP3GX：onestor blk LUN_create -d "{'pool_name':'p1','lun_name':'lun-$i','lun_type':'thin','lun_size':1000,'redundancy':'replicated','replicate_num':3,'min_size':'task'}"
# EC4+2： onestor blk LUN_create -d "{'pool_name':'pl','lun_name':'lun-$i','lun_type':'thin','lun_size':1000,'redundancy':'ec','replicate_num':{'k':4, 'm':2},'min_size':'task'}"


for i in {1..1000}
do
    onestor blk LUN_create -d "{'pool_name':'p1','lun_name':'lun-$i','lun_type':'thin','lun_size':1000,'redundancy':'replicated','replicate_num':3,'min_size':'task'}"
    create_status=$?  # get return status of the last command

    if (($create_status)); then
        echo "[ERROR]The command execute failed."
        exit 0
    fi
    echo "[INFO]The ${i}th lun have been created."
done
