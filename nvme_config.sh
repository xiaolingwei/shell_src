#!/bin/bash

# 函数功能：配置nvmeof

modprobe -r nvme
modprobe -r  nvme-rdma nvme-fabrics nvme-core
modprobe   nvme-rdma nvme-fabrics nvme-core
modprobe nvme

echo "[INFO] Please Check: "

lsmod|grep nvme
