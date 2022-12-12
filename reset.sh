#!/bin/bash

handy_ip=55.149.1.83
node_ip1=55.149.1.85
node_ip2=55.149.1.86


echo '[INFO]stop daos server...'
systemctl stop daos_server.service
ssh -q root@$node_ip1 "systemctl stop daos_server.service"
ssh -q root@$node_ip2 "systemctl stop daos_server.service"

echo '[INFO]umount daos0...'
umount /mnt/daos0
ssh -q root@$node_ip1 "umount /mnt/daos0"
ssh -q root@$node_ip2 "umount /mnt/daos0"

echo '[INFO]umount daos1...'
umount /mnt/daos1
ssh -q root@$node_ip1 "umount /mnt/daos1"
ssh -q root@$node_ip2 "umount /mnt/daos1"

echo '[INFO]format pmem0...'
wipefs -a /dev/pmem0
ssh -q root@$node_ip1 "wipefs -a /dev/pmem0"
ssh -q root@$node_ip2 "wipefs -a /dev/pmem0"

echo '[INFO]format pmem1...'
wipefs -a /dev/pmem1
ssh -q root@$node_ip1 "wipefs -a /dev/pmem1"
ssh -q root@$node_ip2 "wipefs -a /dev/pmem1"

echo '[INFO]start daos server...'
systemctl start daos_server.service
ssh -q root@$node_ip1 "systemctl start daos_server.service"
ssh -q root@$node_ip2 "systemctl start daos_server.service"

#echo 'prepare scm ...'
#/opt/h3c/bin/daos_server storage prepare --scm-only
#ssh -q root@$node_ip1 "/opt/h3c/bin/daos_server storage prepare --scm-only"
#ssh -q root@$node_ip2 "/opt/h3c/bin/daos_server storage prepare --scm-only"

#echo 'restart daos server...'
#systemctl restart daos_server.service
#ssh -q root@$node_ip1 "systemctl restart daos_server.service"
#ssh -q root@$node_ip2 "systemctl restart daos_server.service"

#echo 'prepare scm...'
#/opt/h3c/bin/daos_server storage prepare --scm-only
#ssh -q root@$node_ip1 "/opt/h3c/bin/daos_server storage prepare --scm-only"
#ssh -q root@$node_ip2 "/opt/h3c/bin/daos_server storage prepare --scm-only"

#echo 'prepare nvme...'
#/opt/h3c/bin/daos_server storage prepare --nvme-only -u root
#ssh -q root@$node_ip1 "/opt/h3c/bin/daos_server storage prepare --nvme-only -u root"
#ssh -q root@$node_ip2 "/opt/h3c/bin/daos_server storage prepare --nvme-only -u root"

echo '[INFO]restart daos agent...'
systemctl restart daos_agent.service
ssh -q root@$node_ip1 "systemctl restart daos_agent.service"
ssh -q root@$node_ip2 "systemctl restart daos_agent.service"

sleep 10
/opt/h3c/bin/dmg storage format

echo '[INFO] Datebase initializing...'
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from op_blk_lunmng"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from op_cluster_pool"

sleep 2
echo '[INFO]Datebase initialization complete'

echo '[INFO]start tgt_db_reset...'
mariadbsql -p27HbZwr*g -A < "tgt_db_reset.sql"
sleep 2

echo '[INFO]restart tgt...'
service tgt restart
ssh -q root@$node_ip1 "service tgt restart"
ssh -q root@$node_ip2 "service tgt restart"

echo '[INFO]OK! Now you can operate the cluster'
