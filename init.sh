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


touch ~/.vimrc
cat > /etc/init.d/cx.sh <<- EOF

"语法高亮
syntax enable
syntax on
"显示行号
set nu
"显示括号匹配
set showmatch
"括号匹配显示时间为1(单位是十分之一秒)
set matchtime=5
"显示当前的行号列号：
set ruler
"在状态栏显示正在输入的命令
set showcmd
" 显示Tab符，使用一高亮竖线代替
set list
set listchars=tab:\|\ ,
set listchars=tab:>-,trail:-
"设置高亮搜索
set hlsearch
"在搜索时，输入的词句的逐字符高亮
set incsearch
line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent                " always set autoindenting on

endif " has("autocmd")

" 设置tab是四个空格
set ts=4
set expandtab

EOF
