## 配置共享存储
运行机器学习模型训练需要训练代码，数据以及训练结果的输出，需要通过共享存储进行管理，并在模型训练程序中共享。<br />Kubernetes中提供了PV（数据卷）和PVC（数据卷声明）作为共享存储的描述对象。阿里云在此之上提供CPFS, NAS和OSS的Flexvolume Driver ，可以轻松将阿里云的CPFS, NAS和OSS 等存储服务对接到Kubernetes集群。

### NAS
阿里云文件存储（Network Attached Storage，简称 NAS）是面向阿里云 ECS 实例、E-HPC 和容器服务等计算节点的文件存储服务。阿里云NAS服务具有无缝集成，共享访问，安全控制等特性，非常适合跨多个 ECS、E-HPC 或容器服务实例部署的应用程序访问相同数据来源的应用场景。

#### 创建NAS实例，配置挂载点

1\. 进入阿里云NAS服务控制台([https://nas.console.aliyun.com/#/ofs/list](https://nas.console.aliyun.com/#/ofs/list))。选择和Kubernetes集群对应的地域<br />

2\. 选择对应创建文件系统，地域和可用区和Kubernetes集群选择一致。<br />![image.png](images/nas_create_fs.png)


3\. 创建挂载点，同样选择和集群一致的VPC和VSwitch<br />![image.png](images/nas_add_mount.png)

4\. 创建成功后，在控制台详情中能够查看NAS实例的挂载地址<br />![image.png](images/nas_get_mount.png)

#### 配置Kubernetes中的存储卷和存储声明

1\. 回到容器服务控制台([https://cs.console.aliyun.com/](https://cs.console.aliyun.com/))，我们在容器集群中创建存储卷，将来源设置为NAS。<br />

2\. 在容器控制台中选择 集群 -> 存储卷 -> 创建<br />![image.png](images/nas_create_pv.png)

3\. 创建存储卷完成，继续创建存储声明（PVC），名称我们约定设置为 `training-data`， 并且需要选择之前的存储卷。 <br />![image.png](images/nas_create_pvc.png)
