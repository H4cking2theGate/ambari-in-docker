@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set "node_num=2"

if "%~1" == "" goto usage

goto %1

:create
    call :printHeader "拉取镜像"
    docker pull tungshuaishuai/ambari-repo:2.7.6.3
    docker pull tungshuaishuai/ambari-node:2.7.6.3

    call :printHeader "创建网络"
    docker network create --subnet=172.188.0.0/16 ambari_cluster_net
    goto :eof

:start
    call :printHeader "启动 Ambari 集群"

    call :printSubHeader "启动 Ambari 仓库"
    docker run -d --name ambari-repo --network ambari_cluster_net --ip 172.188.0.2 -it tungshuaishuai/ambari-repo:2.7.6.3

    call :printSubHeader "启动 Ambari Server"
    docker run -d --privileged --name amb-server --network ambari_cluster_net --ip 172.188.0.3 -p 18080:8080 -it tungshuaishuai/ambari-node:2.7.6.3
    docker cp init-hosts.sh amb-server:/root/
    docker cp init-ambari-server.sh amb-server:/root/

    for /l %%i in (1,1,%node_num%) do (
        call :printSubHeader "启动 Ambari Agent %%i"
        set /A ip_suffix=%%i+3
        docker run -d --privileged --name amb%%i --network ambari_cluster_net --ip 172.188.0.!ip_suffix! -it tungshuaishuai/ambari-node:2.7.6.3
        docker cp init-hosts.sh amb%%i:/root/
    )

    call :printSubHeader "初始化主机"
    docker exec -it amb-server bash /root/init-hosts.sh
    docker exec -it amb-server wget http://repo.hdp.link/ambari/centos7/2.7.6.3-2/ambari.repo -P /etc/yum.repos.d/
    docker exec -it amb-server wget http://repo.hdp.link/HDP/centos8/3.3.1.0-002/hdp.repo -P /etc/yum.repos.d/

    for /l %%i in (1,1,%node_num%) do (
        docker exec -it amb%%i bash /root/init-hosts.sh
        docker exec -it amb%%i wget http://repo.hdp.link/ambari/centos7/2.7.6.3-2/ambari.repo -P /etc/yum.repos.d/
        docker exec -it amb%%i wget http://repo.hdp.link/HDP/centos8/3.3.1.0-002/hdp.repo -P /etc/yum.repos.d/
    )

    call :printSubHeader "初始化 Ambari Server"
    docker exec -it amb-server rm -rf /var/lib/pgsql/data
    docker exec -it amb-server bash /root/init-ambari-server.sh
    docker exec -it amb-server ambari-server restart

    call :printSubHeader "启动 Ambari Agent"
    docker exec -it amb-server ambari-agent start

    for /l %%i in (1,1,%node_num%) do (
        docker exec -it amb%%i ambari-agent start
    )
    goto :eof

:stop
    call :printHeader "停止 Ambari 集群"

    call :printSubHeader "停止 Ambari Server"
    docker stop amb-server

    call :printSubHeader "停止 Ambari 仓库"
    docker stop ambari-repo

    for /l %%i in (1,1,%node_num%) do (
        call :printSubHeader "停止 Ambari Agent %%i"
        docker stop amb%%i
    )

    call :printSubHeader "删除容器"
    docker rm amb-server
    docker rm ambari-repo

    for /l %%i in (1,1,%node_num%) do (
        docker rm amb%%i
    )
    goto :eof

:printHeader
    echo ======================================
    echo %~1
    echo ======================================
    goto :eof

:printSubHeader
    echo ---- %~1 ----
    goto :eof

:usage
    echo 用法: %~nx0 {start^|stop^|create}
    exit /b 1