# 如何访问notebook

### 前提
集群管理员请按照 [如何部署Notebook](../setup/SETUP_NOTEBOOK.md) 这章成功部署Notebook，将Notebook的访问地址和token交给数据科学家。

#### 通过SSH Shuttle访问Notebook



#### 通过Ingress访问Notebook
如果您有自己的DNS解析，可以将ingress的域名解析到对应的Ingress IP。 您也可以通过修改本地host文件的方式，将Ingress的域名解析Ingress的IP。通过Ingress域名访问Notebook。
```
47.101.xx.xxx  foo.bar.com
<IP>         <你的Notebook域名>
```

通过从集群管理员得到的Token，可以直接登录到Notebook中，也可以重置密码 <br />
![image.png](./images/access_notebook_password.png)<br />

登录完成后，进入Notebook界面。
![image.png](./images/access_notebook.png)

您可以开始机器学习之旅了！