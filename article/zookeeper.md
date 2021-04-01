## ZooKeeper 是什么？
ZooKeeper 是一个开源的分布式协调服务。它是一个为分布式应用提供一致性服务的软件，分布式应用程序可以基于 Zookeeper 实现诸如数据发布/订阅、负载均衡、命名服务、分布式协调/通知、集群管理、Master 选举、分布式锁和分布式队列等功能。  
ZooKeeper 的目标就是封装好复杂易出错的关键服务，将简单易用的接口和性能高效、功能稳定的系统提供给用户。  
Zookeeper 保证了如下分布式一致性特性：
- 顺序一致性
- 原子性
- 单一视图
- 可靠性
- 实时性（最终一致性） 
客户端的读请求可以被集群中的任意一台机器处理，如果读请求在节点上注册了监听器，这个监听器也是由所连接的 zookeeper 机器来处理。对于写请求，这些请求会同时发给其他 zookeeper 机器并且达成一致后，请求才会返回成功。因此，随着 zookeeper 的集群机器增多，读请求的吞吐会提高但是写请求的吞吐会下降。
有序性是 zookeeper 中非常重要的一个特性，所有的更新都是全局有序的，每个更新都有一个唯一的时间戳，这个时间戳称为 zxid（Zookeeper Transaction Id）。而读请求只会相对于更新有序，也就是读请求的返回结果中会带有这个zookeeper 最新的 zxid。

## ZooKeeper提供了什么？
- 文件系统
- 通知机制

## Zookeeper文件系统
Zookeeper提供一个多层级的节点命名空间（节点称为znode）。与文件系统不同的是，这些节点都可以设置关联的数据，而文件系统中只有文件节点可以存放数据而目录节点不行。  
Zookeeper为了保证高吞吐和低延迟，在内存中维护了这个树状的目录结构，这种特性使得Zookeeper不能用于存放大量的数据，每个节点的存放数据上限为1M。  

## ZAB协议？
ZAB协议是为分布式协调服务Zookeeper专门设计的一种支持崩溃恢复的原子广播协议。 
ZAB协议包括两种基本的模式：崩溃恢复和消息广播。 
当整个zookeeper集群刚刚启动或者Leader服务器宕机、重启或者网络故障导致不存在过半的服务器与Leader服务器保持正常通信时，所有进程（服务器）进入崩溃恢复模式，首先选举产生新的Leader服务器，然后集群中Follower服务器开始与新的Leader服务器进行数据同步，当集群中超过半数机器与该Leader服务器完成数据同步之后，退出恢复模式进入消息广播模式，Leader服务器开始接收客户端的事务请求生成事物提案来进行事务请求处理。  

## 四种类型的数据节点 Znode
- PERSISTENT-持久节点  
除非手动删除，否则节点一直存在于Zookeeper上  

- EPHEMERAL-临时节点  
临时节点的生命周期与客户端会话绑定，一旦客户端会话失效（客户端与zookeeper连接断开不一定会话失效），那么这个客户端创建的所有临时节点都会被移除。

- PERSISTENT_SEQUENTIAL-持久顺序节点
基本特性同持久节点，只是增加了顺序属性，节点名后边会追加一个由父节点维护的自增整型数字。

- EPHEMERAL_SEQUENTIAL-临时顺序节点 
基本特性同临时节点，增加了顺序属性，节点名后边会追加一个由父节点维护的自增整型数字。  


## Zookeeper Watcher机制–数据变更通知
Zookeeper允许客户端向服务端的某个Znode注册一个Watcher监听，当服务端的一些指定事件触发了这个Watcher，服务端会向指定客户端发送一个事件通知来实现分布式的通知功能，然后客户端根据Watcher通知状态和事件类型做出业务上的改变。

***工作机制：***
- 客户端注册watcher
- 服务端处理watcher
- 客户端回调watcher

***Watcher特性总结：***
1. 一次性
无论是服务端还是客户端，一旦一个Watcher被触发，Zookeeper都会将其从相应的存储中移除。这样的设计有效的减轻了服务端的压力，不然对于更新非常频繁的节点，服务端会不断的向客户端发送事件通知，无论对于网络还是服务端的压力都非常大。
2. 客户端串行执行
客户端Watcher回调的过程是一个串行同步的过程。
3. 轻量
    - Watcher通知非常简单，只会告诉客户端发生了事件，而不会说明事件的具体内容。
    - 客户端向服务端注册Watcher的时候，并不会把客户端真实的Watcher对象实体传递到服务端，仅仅是在客户端请求中使用boolean类型属性进行了标记。
4. watcher event异步发送watcher的通知事件从server发送到client是异步的，这就存在一个问题，不同的客户端和服务器之间通过socket进行通信，由于网络延迟或其他因素导致客户端在不通的时刻监听到事件，由于Zookeeper本身提供了ordering guarantee，即客户端监听事件后，才会感知它所监视znode发生了变化。所以我们使用Zookeeper不能期望能够监控到节点每次的变化。Zookeeper只能保证最终的一致性，而无法保证强一致性。
5. 注册watcher getData、exists、getChildren
6. 触发watcher create、delete、setData
7. 当一个客户端连接到一个新的服务器上时，watch将会被以任意会话事件触发。当与一个服务器失去连接的时候，是无法接收到watch的。而当client重新连接时，如果需要的话，所有先前注册过的watch，都会被重新注册。通常这是完全透明的。只有在一个特殊情况下，watch可能会丢失：对于一个未创建的znode的exist watch，如果在客户端断开连接期间被创建了，并且随后在客户端连接上之前又删除了，这种情况下，这个watch事件可能会被丢失。


## 客户端注册Watcher实现
- 调用getData()/getChildren()/exist()三个API，传入Watcher对象
- 标记请求request，封装Watcher到WatchRegistration
- 封装成Packet对象，发服务端发送request
- 收到服务端响应后，将Watcher注册到ZKWatcherManager中进行管理
- 请求返回，完成注册。

## 服务端处理Watcher实现
***服务端接收Watcher并存储***
接收到客户端请求，处理请求判断是否需要注册Watcher，需要的话将数据节点的节点路径和ServerCnxn（ServerCnxn代表一个客户端和服务端的连接，实现了Watcher的process接口，此时可以看成一个Watcher对象）存储在WatcherManager的WatchTable和watch2Paths中去。  

***Watcher触发***
以服务端接收到 setData() 事务请求触发NodeDataChanged事件为例：  

***封装WatchedEvent***
将通知状态（SyncConnected）、事件类型（NodeDataChanged）以及节点路径封装成一个WatchedEvent对象  

***查询Watcher***  
从WatchTable中根据节点路径查找Watcher
没找到；说明没有客户端在该数据节点上注册过Watcher
找到；提取并从WatchTable和Watch2Paths中删除对应Watcher（从这里可以看出Watcher在服务端是一次性的，触发一次就失效了）
调用process方法来触发Watcher
这里process主要就是通过ServerCnxn对应的TCP连接发送Watcher事件通知。

## 客户端回调Watcher
客户端SendThread线程接收事件通知，交由EventThread线程回调Watcher。客户端的Watcher机制同样是一次性的，一旦被触发后，该Watcher就失效了。