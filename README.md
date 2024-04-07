# 介绍

ambari docker镜像，版本2.7.6，测试环境centos7

```
.
├── app.bat 创建/启动/停止
├── node   node节点镜像
├── init-ambari-server.sh node节点依赖脚本
├── init-hosts.sh         node节点依赖脚本
└── repo   ambari hdp本地仓库镜像
```
组件版本，HDP 3.3.1.0-002，如果安装全部组件，建议32G内存。安装常用组件大约会占用15G内存。下面hadoop三节点，然后关闭了hbase约15G内存
| 组件             | 版本        | 介绍                                                                                                                                                                                                                                            |
| -------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| HDFS           | 3.3.4     | Apache Hadoop Distributed File System                                                                                                                                                                                                         |
| YARN           | 3.3.4     | Apache Hadoop NextGen MapReduce (YARN)                                                                                                                                                                                                        |
| MapReduce2     | 3.1.1     | Apache Hadoop NextGen MapReduce (YARN)                                                                                                                                                                                                        |
| Tez            | 0.10.2    | Tez is the next generation Hadoop Query Processing framework written on top of YARN.                                                                                                                                                          |
| Hive           | 3.1.3     | Data warehouse system for ad-hoc queries & analysis of large datasets and table & storage management service                                                                                                                                  |
| HBase          | 2.4.14    | Non-relational distributed database and centralized service for configuration management & synchronization                                                                                                                                    |
| Sqoop          | 1.4.7     | Tool for transferring bulk data between Apache Hadoop and structured data stores such as relational databases                                                                                                                                 |
| ZooKeeper      | 3.7.1     | Centralized service which provides highly reliable distributed coordination                                                                                                                                                                   |
| Infra Solr     | 8.11.2    | Core shared service used by Ambari managed components.                                                                                                                                                                                        |
| Ambari Metrics | 0.2.0     | A system for metrics collection that provides storage and retrieval capability for metrics collected from the cluster                                                                                                                         |
| Atlas          | 2.2.0     | Atlas Metadata and Governance platform                                                                                                                                                                                                        |
| Kafka          | 2.8.2     | A high-throughput distributed messaging system                                                                                                                                                                                                |
| Knox           | 1.6.1     | Provides a single point of authentication and access for Apache Hadoop services in a cluster                                                                                                                                                  |
| Log Search     | 0.5.0     | Log aggregation, analysis, and visualization for Ambari managed services. This service is Technical Preview.                                                                                                                                  |
| Ranger         | 2.3.0     | Comprehensive security for Hadoop                                                                                                                                                                                                             |
| Ranger KMS     | 2.3.0     | Key Management Server                                                                                                                                                                                                                         |
| Spark2         | 2.4.8     | Apache Spark 2.3 is a fast and general engine for large-scale data processing.                                                                                                                                                                |
| Flink          | 1.15.2    | Apache Flink is a framework and distributed processing engine for stateful computations over unbounded and bounded data streams. This service is Technical Preview.                                                                           |
| Hue            | 4.10.0    | Hue is a graphical user interface to operate and develop applications for Apache Hadoop.This service is Technical Preview.                                                                                                                    |
| Impala         | 4.1.1     | an open source, analytic MPP database for Apache Hadoop that provides the fastest time-to-insight. This service is Technical Preview.                                                                                                         |
| Kerberos       | 1.10.3-30 | A computer network authentication protocol which works on the basis of 'tickets' to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner.                                            |
| Kyuubi         | 1.6.1     | AKyuubi is a distributed multi-tenant Thrift JDBC/ODBC server for large-scale data management, processing, and analytics, built on top of Apache Spark and designed to support more engines (i.e., Flink). This service is Technical Preview. |
| Ozone          | 1.3.0     | Ozone is a scalable, redundant, and distributed object store for Hadoop.This service is Technical Preview.                                                                                                                                    |
| Spark3         | 3.3.2     | Apache Spark 3.3 is a fast and general engine for large-scale data processing. This service is Technical Preview.                                                                                                                             |

# quick start
```
./app.bat create
./app.bat start
```

访问http://127.0.0.1:18080/，初始化配置如下
```
软件源地址：
**不要勾选skip那两个复选框**
http://172.188.0.2/HDP/centos8/3.3.1.0-002/
http://172.188.0.2/HDP-UTILS/centos7/1.1.0.22/

主机名称和server机器的私钥
amb-server.hdp.link
amb1.hdp.link
amb2.hdp.link
查看命令
docker exec -it amb-server cat /root/.ssh/id_rsa


hive元数据默认用的是server自带的postgresql,已创建好两个库
主机名amb-server 
库名hive 账号hive 密码hive 在安装界面注意正确配置hive元数据使用的postgresql的jdbc url 已截图
库名hue  账号hue  密码hue  在安装界面注意正确配置hue使用postgresql的主机名为amb-server  已截图，发现不支持最新chrome浏览器，试试360等比较旧的浏览器。
```
局域网中的windows访问docker网络
```
如果centos7的ip是192.168.8.147
windows 添加路由, -p永久 
route add -p 172.188.0.0 mask 255.255.0.0 192.168.8.147

linux 修改完后一定要重启
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
```
