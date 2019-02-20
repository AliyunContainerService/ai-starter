### 环境准备
搭建基于GPU的Kubernetes机器学习环境，我们需要
* 创建一个阿里云容器服务Kubernetes集群，通过Kubernetes管理GPU节点。 [如何创建集群](CREATE_CLUSTER.md)
* 配置NAS共享存储 [如何配置NAS](SETUP_NAS.md)
* 安装Arena的依赖组件，arena-notebook [如何安装Arena](INSTALL_ARENA.md)
* 配置化本地环境 [如何配置本地环境](SETUP_LOCAL.md)

> Arena 是一个机器学习基础架构工具，可供数据科学家轻而易举地运行和监控机器学习训练作业，并便捷地检查结果。目前，它支持单机/分布式深度学习模型训练。在实现层面，它基于 Kubernetes、helm 和 Kubeflow。但数据科学家可能对于 kubernetes 知之甚少。

与此同时，用户需要 GPU 资源和节点管理。Arena 还提供了 top 命令，用于检查 Kubernetes 集群内的可用 GPU 资源。

简而言之，Arena 的目标是让数据科学家感觉自己就像是在一台机器上工作，而实际上还可以享受到 GPU 集群的强大力量。
