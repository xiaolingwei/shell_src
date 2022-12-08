#!/bin/bash
log_array=(/var/log/diamond/archive.log /var/log/mariadbcluster/handyha.log /var/log/calamari/calamari.log /var/log/storage/DIAMOND/DIAMOND.log)
echo "We will check logfile ${log_array[@]}"
for log in ${log_array[@]};
do
    echo "[INFO]$log is checking:"
    grep ERR $log
done

