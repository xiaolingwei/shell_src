#!/bin/bash

IP=$1
nvme discover -t rdma -a $IP -s 4420
nqn=`nvme discover -t rdma -a $IP -s 4420 | grep subnqn | awk '{print $2}'`
nvme connect -t rdma -n $nqn -a $IP -s 4420 -c 2
nvme list
