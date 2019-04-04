### Kubernetes GPU环境
容器服务Kubernetes 集群支持管理GPU节点，并且支持GPU调度。管理GPU通过两个维度：
* 在GPU节点上安装nvidia-docker，它和普通的docker runtime不同，通过nvidia-docker2，我们可以在容器中通过目录挂载的方式访问ECS的Nvidia Driver，并且可以在容器中挂载指定的GPU设备。
* 在GPU节点上部署GPU DevicePlugin，它负责上报节点上的GPU信息。 这样我们可以通过在Kubernetes的Pod编排中声明request： `nvidia.com/gpu`   的方式指定容器是否需要挂载GPU以及个数。容器在调度节点的时候会被调度到满足条件的GPU节点，并根据数量映射GPU到容器中。

如何创建带GPU的Kubernetes集群可以参考文档 [https://help.aliyun.com/document_detail/86490.html](https://help.aliyun.com/document_detail/86490.html?spm=a2c4g.11186623.6.582.4fe64330JXBSuT) 。

### 创建集群步骤
1\. 进入容器服务控制台（[https://cs.console.aliyun.com](https://cs.console.aliyun.com/#/k8s/cluster/list) ），选择创建集群<br />![PNG](images/create_cluster.png)


2\. Worker实例规格选择GN系列（包含GN5，GN6以及GN5i等等）。具体配置可以查看  [ECS 实例规格族](https://help.aliyun.com/document_detail/25378.html#gn5)<br />![image.png](images/create_cluster_instance_type.png)


3\. 其他配置可以按需设置。如果想要了解更详细的Kubernetes集群配置， 请参考文档：[https://help.aliyun.com/document_detail/86488.html](https://help.aliyun.com/document_detail/86488.html)

这里需要关注的地方包括：
	a. 如果是事先购买的ECS，请注意选择和该ECS同一个vpc和vswitch创建K8S集群
	b. 创建集群时选择Pod ip和Service ip网段不能和ECS网段冲突。网段规划参考文档： [https://help.aliyun.com/document_detail/86500.html](https://help.aliyun.com/document_detail/86500.html)
	c. 如果用户事先购买的ECS请至少保证系统磁盘为100G以上


4\. 完成配置后，点击等待大概10-20分钟后，集群创建完毕。<br />![image.png](images/create_cluster_finish.png)


5\. 我们可以在集群节点列表查看节点，可以查看到包含GN实例规格的节点，这些节点会被用于被调度和启动GPU应用容器。<br />![image.png](images/create_cluster_gpu.png)
