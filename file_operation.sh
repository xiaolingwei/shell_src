#!/bin/bash


usage() {
        echo "
usage: ${0} 0|1
       脚本接受一个参数0或者1
       0表示单线程
       1表示多线程"

}

hostname=`hostname`
read -p "请输入要跑脚本的目录全路径（eg:/mnt/note3/dir）：" dir

if [ ! -d $dir ];then
        mkdir $dir
else
        echo "$dir exits,no need to create"
fi

read -p "请输入脚本要循环的次数（只能输入数字）：" count

operation(){
        echo "[INFO] Create dir"
        mkdir $dir/dir1
        mkdir $dir/dir2
        echo "[INFO] Create file"
        touch $dir/dir1/file1
        touch $dir/dir2/file2
        echo "[INFO] Write file"
        dd if=/dev/zero of=$dir/dir1/file1 bs=64k count=1
        dd if=/dev/zero of=$dir/dir2/file2 bs=1M count=1

        # 文件软链接
        echo "[INFO] Create soft link"
        ln -s  $dir/dir1/file1 $dir/dir1/file1_lns
        ln -s  $dir/dir2/file2 $dir/dir2/file2_lns
        echo "[INFO] Read soft link"
        cat $dir/dir1/file1_lns
        cat $dir/dir2/file2_lns
        echo "[INFO] Write soft link"
        dd if=/dev/zero of=$dir/dir1/file1_lns bs=64k count=1
        dd if=/dev/zero of=$dir/dir2/file2_lns bs=1M count=1
        echo "[INFO] Rename soft link"
        mv $dir/dir1/file1_lns $dir/dir1/file1_lns_rename
        mv $dir/dir2/file2_lns $dir/dir2/file2_lns_rename
        echo "[INFO] Delete soft link"
        rm -f $dir/dir1/file1_lns_rename
        rm -f $dir/dir2/file2_lns_rename

        # 文件硬链接
        echo "[INFO] Create hard link"
        ln  $dir/dir1/file1 $dir/dir1/file1_ln
        ln  $dir/dir2/file2 $dir/dir2/file2_ln
        echo "[INFO] Read hard link"
        cat $dir/dir1/file1_ln
        cat $dir/dir2/file2_ln
        echo "[INFO] Write hard link"
        dd if=/dev/zero of=$dir/dir1/file1_ln bs=64k count=1
        dd if=/dev/zero of=$dir/dir2/file2_ln bs=1M count=1
        echo "[INFO] Rename hard link"
        mv $dir/dir1/file1_ln $dir/dir1/file1_ln_rename
        mv $dir/dir2/file2_ln $dir/dir2/file2_ln_rename
        echo "[INFO] Delete hard link"
        rm -f $dir/dir1/file1_ln_rename
        rm -f $dir/dir2/file2_ln_rename

        echo "[INFO] Read file"
        cat $dir/dir1/file1
        cat $dir/dir2/file2
        echo "[INFO] Rename file"
        mv $dir/dir1/file1 $dir/dir1/file1_rename
        mv $dir/dir2/file2 $dir/dir2/file2_rename
        echo "[INFO] Delete file"
        rm -f $dir/dir1/file1_rename
        rm -f $dir/dir2/file2_rename

        # 目录软链接
        echo "[INFO] Create dir soft link"
        ln -s  $dir/dir1 $dir/dir1_lns
        ln -s  $dir/dir2 $dir/dir2_lns
        echo "[INFO] Read dir soft link"
        ls $dir/dir1_lns
        ls $dir/dir2_lns
        echo "[INFO] Write dir soft link"
        dd if=/dev/zero of=$dir/dir1_lns/file1 bs=64k count=1
        dd if=/dev/zero of=$dir/dir2_lns/file2 bs=1M count=1
        echo "[INFO] Rename dir soft link"
        mv $dir/dir1_lns $dir/dir1_lns_rename
        mv $dir/dir2_lns $dir/dir2_lns_rename
        echo "[INFO] Delete dir soft link"
        rm -f $dir/dir1_lns_rename
        rm -f $dir/dir2_lns_rename

        # 目录硬链接
        echo "[INFO] Create dir hard link"
        ln -s  $dir/dir1 $dir/dir1_ln
        ln -s  $dir/dir2 $dir/dir2_ln
        echo "[INFO] Read dir hard link"
        ls $dir/dir1_ln
        ls $dir/dir2_ln
        echo "[INFO] Write dir hard link"
        dd if=/dev/zero of=$dir/dir1_ln/file1 bs=64k count=1
        dd if=/dev/zero of=$dir/dir2_ln/file2 bs=1M count=1
        echo "[INFO] Rename dir hard link"
        mv $dir/dir1_ln $dir/dir1_ln_rename
        mv $dir/dir2_ln $dir/dir2_ln_rename
        echo "[INFO] Delete dir hard link"
        rm -f $dir/dir1_ln_rename
        rm -f $dir/dir2_ln_rename

        echo "[INFO] Read dir"
        ls $dir/dir1
        ls $dir/dir2
        echo "[INFO] Write dir"
        dd if=/dev/zero of=$dir/dir1/file1 bs=64k count=1
        dd if=/dev/zero of=$dir/dir2/file2 bs=1M count=1
        echo "[INFO] Rename dir"
        mv $dir/dir1 $dir/dir1_rename
        mv $dir/dir2 $dir/dir2_rename
        echo "[INFO] Delete dir"
        rm -rf $dir/dir1_rename
        rm -rf $dir/dir2_rename

}

if [ $# -ne 1 ]; then
        usage
        exit
fi

if [ $1 -eq 0 ]; then
{
        for i in `seq 1 $count`
        do
        {
        operation
        echo $i
        }
        done
}

elif [ $1 -eq 1 ]; then
{
        read -p "请输入要并发的线程数（只能输入数字）：" thread
        [ -e /tmp/fd1 ] || mkfifo /tmp/fd1
        exec 3<>/tmp/fd1
        rm -rf /tmp/fd1

        for i in `seq 1 $thread`
        do
        {
        echo >&3
        echo a=$i
        }
        done

        for j in `seq 1 $count`
        do
        read -u3
        {
        operation
        echo $j
        echo >&3
        }&
        done
        wait
        exec 3<&-
        exec 3>&-

}
else
        usage
fi
