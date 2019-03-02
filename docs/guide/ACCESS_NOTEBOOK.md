# 访问Notebook
出于安全考虑，默认部署的Jupyter Notebook 只暴露集群的内网IP。在公有云里，公网环境无法直接访问Kubernetes集群内网，如果我们想要通过笔记本访问Notebook，需要进行网络打通。
我们提供访问脚本，帮助您通过Kubectl PortForward方式建立转发。 我们通过kubectl将localhost某个端口的访问转发到Notebook，您可以通过直接访问本地端口访问线上Notebook。使用结束后关闭转发。

### 前提
请按照 [配置本地环境](../setup/SETUP_LOCAL.md) 这章配置本地环境。

#### Port-forward方式访问Notebook
###### 如果您是MAC/Linux的用户
执行命令
```
# curl -s http://kubeflow.oss-cn-beijing.aliyuncs.com/bootstrap/access_notebook.sh | bash -s --
Forwarding pod: default/arena-notebook-c4474d566-wxhx2, port: 8081
Open http://localhost:8081 in browser
Forwarding from 127.0.0.1:8081 -> 8888
Forwarding from [::1]:8081 -> 8888
```

您可以通过访问 `http://localhost:8081` 访问并使用Notebook

###### 如果您是Windows用户

```'
# 设置转发， PODNAME替换为您的PodName
# kubectl port-forward arena-notebook-0 8001:8888
```