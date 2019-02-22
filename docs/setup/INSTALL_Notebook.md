## 安装Notebook
为了简化安装，我们提供了安装脚本。 由于安装脚本需要和集群交互，我们需要在安装kubectl并配置好kubeconfig的环境中运行安装命令。 <br />
您可以选择通过CloudShell 执行命令， 也可以登录到Master上执行命令。

##### 登录到master
我们可以选择登录到master机器上运行安装命令， 在控制台上查看Master节点SSH登录地址：<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550497957036-403a6b99-f28b-42a9-a91c-14edf7844ebb.png#align=left&display=inline&height=168&linkTarget=_blank&name=image.png&originHeight=415&originWidth=1107&size=92074&width=448)

通过SSH登录到Master节点

##### CloudShell
如果您未开放master的ssh端口，也可以通过cloudShell执行安装命令，[参考文档](https://help.aliyun.com/document_detail/100650.html)<br />
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550559633066-5adbbe84-e0aa-4197-a4ab-4956c228cf90.png#align=left&display=inline&height=167&linkTarget=_blank&name=image.png&originHeight=611&originWidth=1462&size=192881&width=399)

##### 笔记本上运行
您也可以在本地运行，需要安装kubectl，并下载集群凭证。 (安装Kubectl)[https://kubernetes.io/docs/tasks/tools/install-kubectl/]
在控制台集群详情中获取Kubeconfig。
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550559838022-51236fc3-27dc-40fc-91e8-5b5af951f363.png#align=left&display=inline&height=157&linkTarget=_blank&name=image.png&originHeight=513&originWidth=1426&size=334486&width=438)

### 安装Arena
运行安装命令：
```
curl -s //kubeflow.oss-cn-beijing.aliyuncs.com/bootstrap/install.sh | bash -s --
```

安装完成后，检查安装结果：

```
# 查看arena 依赖
# kubectl -n arena-system get po
NAME                                      READY   STATUS    RESTARTS   AGE
mpi-operator-5f89ddc9bf-5mw4c             1/1     Running   0          4d
tf-job-dashboard-7dc786b7fb-t57wx         1/1     Running   0          4d
tf-job-operator-v1alpha2-98bfbfc4-9d66t   1/1     Running   0          4d

# 查看notebook
# kubectl get po
NAME                              READY   STATUS      RESTARTS   AGE
arena-notebook-5bd4d8c5f7-jc7vf   1/1     Running     0          4d
```

### 访问Notebook

如果您本地是MAC或者LInux电脑，在笔记本上执行：
```
# curl -s http://xiaoyuan-dev.oss-cn-beijing.aliyuncs.com/access_notebook.sh | bash -s --
Forwarding pod: default/arena-notebook-c4474d566-wxhx2, port: 8081
Open http://localhost:8081 in browser
Forwarding from [::1]:8081 -> 8888
Forwarding from 127.0.0.1:8081 -> 8888
```

访问notebook [http://localhost:8081](http://localhost:8081)， 输入密码，即可访问notebook（默认密码为  `mypassw0rd`  ）<br />
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550129380688-b5561907-8e4c-40e6-9c39-4d9cc1339d08.png#align=left&display=inline&height=115&linkTarget=_blank&name=image.png&originHeight=229&originWidth=551&size=14036&width=276)<br />
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2019/png/25353/1550498023638-252d966c-75e8-4bc3-bc42-0825d30632b4.png#align=left&display=inline&height=215&linkTarget=_blank&name=image.png&originHeight=974&originWidth=2866&size=278853&width=634)

您可以开始机器学习之旅了！