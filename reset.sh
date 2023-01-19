#!/bin/sh

handy_ip=55.149.1.68
node_ip=(55.149.1.69 55.149.1.70 55.149.1.83) # 节点列表

echo "[INFO]Handy ip: $handy_ip"
echo "[INFO]Node ip :"

for var in ${node_ip[@]}
do
    echo $var
done

echo '[INFO]stop daos server...'
systemctl stop daos_server.service
for var in ${node_ip[@]}
do
ssh -q root@$var "systemctl stop daos_server.service"
done

echo '[INFO]umount daos0...'
umount /mnt/daos0
for var in ${node_ip[@]}
do
ssh -q root@$var "umount /mnt/daos0"
done

echo '[INFO]umount daos1...'
umount /mnt/daos1
for var in ${node_ip[@]}
do
ssh -q root@$var "umount /mnt/daos1"
done


echo '[INFO]format pmem0...'
wipefs -a /dev/pmem0
for var in ${node_ip[@]}
do
ssh -q root@$var "wipefs -a /dev/pmem0"
done

echo '[INFO]format pmem1...'
wipefs -a /dev/pmem1
for var in ${node_ip[@]}
do
ssh -q root@$var "wipefs -a /dev/pmem1"
done

echo '[INFO]start daos server...'
systemctl start daos_server.service
for var in ${node_ip[@]}
do
ssh -q root@$var "systemctl start daos_server.service"
done

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
for var in ${node_ip[@]}
do
ssh -q root@$var "systemctl restart daos_agent.service"
done

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
rm -f /etc/keepalived/keepalived.conf
service keepalived stop
echo '[INFO]restart tgt...'
service tgt restart
for var in ${node_ip[@]}
do
ssh -q root@$var "service tgt restart"
done

echo '[INFO]OK! Now you can operate the cluster'


