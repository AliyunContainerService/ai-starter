### 介绍

基于阿里云强大计算能力和开源社区Kubeflow的深度学习解决方案，为您提供一个低门槛、开放、端到端的深度学习服务平台。方便数据科学家和算法工程师快速开始利用阿里云的资源（包括 ECS 云服务器、GPU 云服务器、分布式存储NAS、CPFS、 对象存储 OSS、Elastic MapReduce、负载均衡等服务）执行数据准备、模型开发、模型训练、评估和预测等任务。并能够方便地将深度学习能力转化为服务 API，加速与业务应用的集成。

具体而言，该深度学习解决方案具备以下特性：

-   简单：降低构建和管理深度学习平台的门槛。
-   高效：提升 CPU、GPU 等异构计算资源的使用效率，提供统一的用户体验。
-   开放：支持 TensorFlow、Keras、MXNet 等多种主流深度学习框架，同时用户也可使用定制的环境，另外所有方案中的工具全部开源。
-   全周期：提供基于阿里云强大服务体系构建端到端深度学习任务流程的最佳实践。
-   服务化：支持深度学习能力服务化，与云上应用的轻松集成。
-   多用户：支持数据科学家团队的协同合作。


## 开始使用

1.  环境准备
	* [创建集群](docs/setup/CREATE_CLUSTER.md)
	* [配置NAS作为共享存储](docs/setup/SETUP_NAS.md)
	* [安装机器学习基础架构Arena](docs/setup/INSTALL_NOTEBOOK.md)
	* [配置本地环境](docs/setup/SETUP_LOCAL.md) Deprecated

2.  入门体验
	* [如何部署notebook](docs/guide/ACCESS_NOTEBOOK.md)
	* [如何使用notebook](docs/guide/USE_NOTEBOOK.md)

3.  模型实践
	* [单机mnist](demo/1-start-with-mnist.ipynb)
	* [多机mnist](demo/2-distributed-mnist.ipynb)
	* [MPI分布式训练](demo/3-submit-mpi.ipynb)
	* [Resnet模型发布](docs/practice/RESNET.md)
	* [Bert模型](docs/practice/BERT.md)
