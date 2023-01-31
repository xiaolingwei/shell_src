#!/bin/bash

# 初始化新服务器

touch /etc/init.d/cx.sh
chmod 755 /etc/init.d/cx.sh
cat > /etc/init.d/cx.sh <<- EOF
#!/bin/bash
for mlx_dev in \$(ibdev2netdev | awk '{print \$1}')
do
   if_dev=\$(ibdev2netdev | grep \$mlx_dev | awk '{print \$5}')
   echo "------------> Current: \${mlx_dev}:\${if_dev}"
   cma_roce_mode -d "\${mlx_dev}" -p 1 -m 2
   cma_roce_tos -d "\${mlx_dev}" -t 160
   mlnx_qos -i "\${if_dev}" --pfc 0,0,0,0,0,1,0,0 --trust dscp
   echo 6 > /sys/class/net/\${if_dev}/ecn/roce_np/cnp_802p_prio
   sysctl -w net.ipv4.tcp_ecn=1
done

EOF

echo "sh /etc/init.d/cx.sh" >> /etc/rc.local
chmod 755 /etc/rc.local
