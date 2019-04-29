# 部署数据科学家工作环境（Notebook）

### 前提
* 请按照 [配置本地环境](../setup/SETUP_LOCAL.md) 这章配置本地环境。
* 请按照 [安装机器学习基础架构Arena](../setup/INSTALL_ARENA.md) 这章安装基础架构Arena
* 请按照 [配置共享存储](../setup/SETUP_PUBLIC_STORAGE.md) 这章配置共享数据的存储声明
* 请按照 [配置Notebook存储](../setup/SETUP_USER_STORAGE.md) 这章配置用于存放Notebook数据的存储声明


#### 部署Notebook
安装Notebook时支持配置Ingress， 支持TLS为您的访问提供安全防护。
1. 准备您的服务证书。如果您没有证书，可以通过以下命令配置
```
# foo.bar.com 可以替换为您自己的域名
# domain="foo.bar.com"
# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=$domain/O=$domain"
```

上述步骤中的命令会生成一个证书文件 tls.crt、一个私钥文件tls.key。

2. 用该证书和私钥创建一个名为 notebook-secret 的 Kubernetes Secret。
```
# kubectl create secret tls notebook-secret --key tls.key --cert tls.crt
```

3. 部署Notebook

在部署时，您可以为Notebook选择不同的提供服务方式：
* 通过sshuttle访问： 您需要有一个和集群网络联通的跳板机, 如果此跳板机为阿里云上的ECS，需要在此ECS的安全组打开ssh端口(通常为22)，具体配置可以参考[文档](https://www.alibabacloud.com/help/zh/doc-detail/25471.htm).数据科学家通过sshuttle，将对Notebook的请求代理到跳板机中，保证数据科学家和Notebook的网络访问联通。部署时无需额外参数配置
* 通过Ingress访问： 将Notebook通过Ingress的方式提供公网服务能力。部署Notebook时，指定Ingress参数`--ingress`， 以及声明Ingress的域名和TLS证书。

部署命令如下： 

```
# foo.bar.com 可以替换为您自己的域名
# curl -s https://raw.githubusercontent.com/AliyunContainerService/ai-starter/master/scripts/install_notebook.sh | \
bash -s -- \
--notebook-name susan \
--ingress --ingress-domain foo.bar.com --ingress-secret notebook-secret \
--pvc-name training-data
```

上述安装执行中，可以通过以下参数定制部署的依赖组件：

```
--namespace         指定部署的Notebook所在Namespace
--notebook-name     指定部署的Notebook标识名称
--ingress           指定是否为Notebook配置Ingress
--ingress-domain    指定为Notebook配置的Ingress域名，仅在指定--ingress时生效
--ingress-secret    指定为Notebook配置的Ingress，HTTPS使用的证书Secret，仅在指定--ingress时生效
--pvc-name          指定Notebook用于挂载的存储声明，将Notebook的/root目录挂载为这个存储声明，默认值为training-data
--public-pvc-name   指定用于挂载共享数据的存储声明，将Notebook的/root/public 目录挂载为这个存储声明
--notebook-image    指定Notebook的使用镜像，默认是registry.cn-beijing.aliyuncs.com/acs/arena-notebook:cpu
--clean             如果指定了--clean参数，会清理之前通过脚本部署的Notebook应用
```

4. 安装完成后，检查安装结果：

```
# 查看notebook安装结果
# kubectl get po
NAME                              READY   STATUS      RESTARTS   AGE
arena-notebook-5bd4d8c5f7-jc7vf   1/1     Running     0          4d
```

### 获取Notebook的访问地址
执行以下脚本，获取Notebook的IP地址和Ingress域名地址：

```
# curl -s https://raw.githubusercontent.com/AliyunContainerService/ai-starter/master/scripts/print_notebook.sh | bash -s -- --notebook-name susan
Notebook pod ip is 172.16.1.103
Notebook access token is <your token>
Ingress of notebook ip is 39.104.xx.xx
Ingress of notebook domain is foo.bar.com
```

至此集群管理员完成环境配置工作，并为数据科学家分配了一个深度学习环境。
集群管理员将密码和Tokenn交给数据科学家，数据科学家在Notebook中即可开始自己的深度学习工作。