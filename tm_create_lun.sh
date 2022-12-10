#!/bin/bash
for i in {1..100000}
do
onestor blk LUN_create -d "{'pool_name':'p1','lun_name':'ma-$i','lun_type':'thin','lun_size':100,'redundancy':'replicated','replicate_num':3,'min_size':'task'}"
done
