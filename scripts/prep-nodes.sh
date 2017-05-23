#!/bin/sh
set -ue

PYTHON=ActivePython-2.7.13.2715-linux-x86_64-glibc-2.12-402695
Password=${Password:-ChangeMe}
NODES=${NODES:-'192.168.1.11 192.168.1.12 192.168.1.13 192.168.1.14 192.168.1.15 192.168.1.16'}
SSH_ARGS=" -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "

RunParallelTask()
{
    local cmd=$1
    local hosts="$2[@]"
    local hosts=${!hosts}
    shift 2
    local args="$@"
    for i in ${hosts[@]}
    do
        $cmd $i $args &
    done
    wait
}

SSH(){
    local ip=$1
    echo "SSH $ip"
    shift
    sshpass -p ${Password} ssh $SSH_ARGS root@${ip} "$@"
}

SCP(){
    local ip=$1
    shift
    local args=("${@}")
    local len=${#args[@]}
    local src=${args[@]:0:${len}-1}
    local dst=${args[@]:${len}-1}
    sshpass -p ${Password} scp -r $SSH_ARGS $src root@$ip:$dst
}


for x in `echo $NODES`
do
  echo $x
  sshpass -p ChangeMe ssh-copy-id root@$x
done

TARGET_DIR=/data

RunParallelTask SSH NODES mkdir -p /opt/bin
RunParallelTask SSH NODES rm -f /opt/bin/*
RunParallelTask SSH NODES rm -rf ${TARGET_DIR}/python
RunParallelTask SSH NODES rm -rf ${TARGET_DIR}/${PYTHON}*
RunParallelTask SCP NODES ${PYTHON}.tar.gz ${TARGET_DIR}
RunParallelTask SSH NODES "cd ${TARGET_DIR} && tar -xvf ${PYTHON}.tar.gz"
RunParallelTask SSH NODES "cd ${TARGET_DIR}/${PYTHON} && ./install.sh -I ${TARGET_DIR}/python/"
RunParallelTask SSH NODES ln -s ${TARGET_DIR}/python/bin/python /opt/bin/python
