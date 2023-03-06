#!/bin/sh

handy_ip=55.149.1.83
node_ip=(55.149.1.83 55.149.1.85 55.149.1.86) # 节点列表

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

echo '[INFO]start reset tgt db...'
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_ha_info"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_ha_slaves"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_chap"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_chap_initiator"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_hg_host"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_host_group"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_host_group_relate_port"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_initiator"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_initiator_mapping"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_lun_mapping"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_lun_target"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_node_status"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_target"
mariadbsql -ucalamari -p27HbZwr*g calamari -e "delete from tgt_host"
sleep 2
rm -f /etc/keepalived/keepalived.conf
service keepalived stop
for var in ${node_ip[@]}
do
ssh -q root@$var "rm -f /etc/keepalived/keepalived.conf"
ssh -q root@$var "service keepalived stop"
done

echo '[INFO]restart tgt...'
service tgt restart
for var in ${node_ip[@]}
do
ssh -q root@$var "service tgt restart"
done
echo '[INFO]OK! Now you can operate the cluster'
