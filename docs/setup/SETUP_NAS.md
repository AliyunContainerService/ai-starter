## 配置共享存储
运行机器学习训练需要训练代码和数据，我们可以使用NAS作为共享存储，将代码和数据存储到NAS上，并在pod中共享。<br />Kubernetes中提供了PV（数据卷）和PVC（数据卷声明）作为共享存储的描述对象。阿里云在此之上提供NAS和OSS的Flexvolume Driver ，可以轻松将阿里云的NAS和OSS 等存储服务对接到Kubernetes。
### NAS
阿里云文件存储（Network Attached Storage，简称 NAS）是面向阿里云 ECS 实例、E-HPC 和容器服务等计算节点的文件存储服务。阿里云NAS服务具有无缝集成，共享访问，安全控制等特性，非常适合跨多个 ECS、E-HPC 或容器服务实例部署的应用程序访问相同数据来源的应用场景。

#### 创建NAS实例，配置挂载点

1\. 进入阿里云NAS服务控制台([https://nas.console.aliyun.com/#/ofs/list](https://nas.console.aliyun.com/#/ofs/list))。选择和Kubernetes集群对应的地域<br />

2\. 选择对应创建文件系统，地域和可用区和Kubernetes集群选择一致。<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550126691481-1dca2e6b-9e65-4e13-b840-4c604ff38b9f.png#align=left&display=inline&height=241&linkTarget=_blank&name=image.png&originHeight=756&originWidth=1684&size=293006&width=537)


2\. 创建挂载点，同样选择和集群一致的VPC和VSwitch<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550126621235-11ec8953-684b-41ed-ad40-65ef23f6b26b.png#align=left&display=inline&height=246&linkTarget=_blank&name=image.png&originHeight=655&originWidth=1159&size=218025&width=436)

3\. 创建成功后，在控制台详情中能够查看NAS实例的挂载地址<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550126834685-a5730809-20ff-41f3-a140-1f2b3171c36f.png#align=left&display=inline&height=187&linkTarget=_blank&name=image.png&originHeight=658&originWidth=1664&size=160315&width=474)

#### 配置Kubernetes中的存储卷和存储声明

1\. 回到容器服务控制台([https://cs.console.aliyun.com/](https://cs.console.aliyun.com/))，我们在容器集群中创建存储卷，将来源设置为NAS。<br />

2\. 在容器控制台中选择 集群 -> 存储卷 -> 创建<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550142718374-a757491e-dc93-46cf-9240-8d187e2b971e.png#align=left&display=inline&height=266&linkTarget=_blank&name=image.png&originHeight=699&originWidth=1205&size=94725&width=459)

3\. 创建存储卷完成，继续创建存储声明（PVC），名称我们约定设置为 `training-data`， 并且需要选择之前的存储卷。 <br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550142707275-64fdb0c6-19f9-4223-ad03-811282e8e500.png#align=left&display=inline&height=273&linkTarget=_blank&name=image.png&originHeight=699&originWidth=1205&size=94725&width=471)