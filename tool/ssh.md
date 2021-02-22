**SSH(远程连接工具)连接原理：ssh服务是一个守护进程(demon)，系统后台监听客户端的连接，ssh服务端的进程名为sshd,负责实时监听客户端的请求(IP 22端口)，包括公共秘钥等交换等信息。**
**ssh服务端由2部分组成： openssh(提供ssh服务)    openssl(提供加密的程序)**
**ssh的客户端可以用 XSHELL，Securecrt, Mobaxterm等工具进行连接**

## SSH的工作机制 
> 服务器启动的时候自己产生一个密钥(768bit公钥)，本地的ssh客户端发送连接请求到ssh服务器，服务器检查连接点客户端发送的数据和IP地址，确认合法后发送密钥(768bits)给客户端，此时客户端将本地私钥(256bit)和服务器的公钥(768bit)结合成密钥对key(1024bit),发回给服务器端，建立连接通过key-pair数据传输。

## SSH知识小结  
1. SSH是安全的加密协议，用于远程连接Linux服务器               
2. SSH的默认端口是22，安全协议版本是SSH2               
3. SSH服务器端主要包含2个服务功能SSH连接和SFTP服务器               
4. SSH客户端包含ssh连接命令和远程拷贝scp命令等 

## ssh使用方法
>* 常见参数  
```markdown
usage: ssh [-1246AaCfgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
           [-D [bind_address:]port] [-e escape_char] [-F configfile]
           [-i identity_file] [-L [bind_address:]port:host:hostport]
           [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]
           [-R [bind_address:]port:host:hostport] [-S ctl_path]
           [-W host:port] [-w local_tun[:remote_tun]]
           [user@]hostname [command]
```

>* 常用功能  
```sheel
1.登录                   
    ssh -p22 omd@192.168.25.137               
2.直接执行命令  -->最好全路径                   
    ssh root@192.168.25.137 ls -ltr /backup/data                       
    ==>ssh root@192.168.25.137 /bin/ls -ltr /backup/data               
3.查看已知主机                    
    cat /root/.ssh/known_hosts
4.ssh远程执行sudo命令
    ssh -t omd@192.168.25.137 sudo rsync hosts /etc/
 
5.scp               
    1.功能   -->远程文件的安全(加密)拷贝                   
        scp -P22 -r -p /home/omd/h.txt omd@192.168.25.137:/home/omd/               
    2.scp知识小结                   
        scp是加密远程拷贝，cp为本地拷贝                   
        可以推送过去，也可以拉过来                   
        每次都是全量拷贝(效率不高，适合第一次)，增量拷贝用rsync
 
6.ssh自带的sftp功能               
    1.Window和Linux的传输工具                   
        wincp   filezip                   
        sftp  -->基于ssh的安全加密传输                   
        samba   
    2.sftp客户端连接                   
        sftp -oPort=22 root@192.168.25.137                   
        put /etc/hosts /tmp                   
        get /etc/hosts /home/omd   
    3.sftp小结：                   
        1.linux下使用命令： sftp -oPort=22 root@x.x.x.x                   
        2.put加客户端本地路径上传                  
        3.get下载服务器端内容到本地                   
        4.远程连接默认连接用户的家目录
```

>* 后台服务  
```sheel
# 查询openssl软件
    rpm -qa openssh openssl
# 查询sshd进程
    ps -ef | grep ssh
        --> /usr/sbin/sshd
# 查看ssh端口
    netstat -lntup | grep ssh  
    ss | grep ssh                (效果同上，同下，好用)
    netstat -a | grep ssh(记住这个)
    netstat -lnt | grep 22    ==>  查看22端口有没有开/ssh服务有没有开启
    技巧： netstat -lnt | grep ssh | wc -l -->只要大于2个就是ssh服务就是好的
# 查看ssh的秘钥目录
    ll /root/.ssh/known_hosts  # 当前用户家目录的.ssh目录下
# ssh的配置文件
    cat /etc/ssh/sshd_config   
# ssh服务的关闭
    service sshd stop
# ssh服务的开启：
    service sshd start
# ssh服务的重启
    service sshd reload    [停止进程后重启] ==> 推荐
    service sshd restart   [干掉进程后重启] ==> 不推荐
# ssh远程登录
    ssh 192.168.1.100      # 默认利用当前宿主用户的用户名登录
    ssh omd@192.168.1.100  # 利用远程机的用户登录
    ssh omd@192.168.1.100  -o stricthostkeychecking=no # 首次登陆免输yes登录
    ssh omd@192.168.1.100 "ls /home/omd"  # 当前服务器A远程登录服务器B后执行某个命令
    ssh omd@192.168.1.100 -t "sh /home/omd/ftl.sh"  # 当前服务器A远程登录服务器B后执行某个脚本

```

## ssh免密设置
1. 进入用户的家目录
```markdown
[root@localhost ~]# cd /root/.ssh/       【root用户就在root目录下的.ssh目录】
[root@localhost ~]# cd /home/omd/.ssh/   【普通用户就是在家目录下的.ssh目录】
```

2. 根据DSA算法生成私钥和公钥【默认建立在当前用户的家目录】
```markdown
[root@localhost .ssh]# ssh-keygen -t dsa     # 一路回车即可
                id_dsa         -->私钥(钥匙) 
                id_dsa.pub     -->公钥(锁)
```

3. 拷贝公钥给目标服务器
```markdown
[root@localhost .ssh]# ssh-copy-id -i id_dsa.pub omd@192.168.25.110          【使用ssh登录的默认端口22】
[root@localhost .ssh]# ssh-copy-id -i id_dsa.pub –p 666 omd@192.168.25.120   【使用ssh登录设置的端口666】
```

4. 查看目标服务器生成的文件
```markdown
[omd@localhost .ssh]$ ll /home/omd/.ssh/authorized_keys
```

5. 免密码登录目标服务器
```markdown
ssh omd@192.168.25.110
```

6. 总结一下钥匙和锁的关系  
```markdown
1.多个钥匙开一把锁
    把id_dsa.pub 复制给各个服务器
 
2.一个钥匙开duobasuo
    把id_dsa 传给各个服务器
    把id_dsa 传给自己  
```

> 参考:[https://www.cnblogs.com/machangwei-8/p/10352725.html](https://www.cnblogs.com/machangwei-8/p/10352725.html)