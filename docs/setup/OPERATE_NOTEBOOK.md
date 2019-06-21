# 运维数据科学家工作环境（Notebook）

### 前提
* 已经按照 [部署数据科学家工作环境](../setup/SETUP_NOTEBOOK.md) 安装了Notebook


#### 升级Notebook版本
如果您希望更新使用的Notebook，可以通过类似以下命令进行更新。注意：具体参数与你之前安装的Notebook相关。 

```
# curl -s https://raw.githubusercontent.com/AliyunContainerService/ai-starter/master/scripts/upgrade_notebook.sh | \
bash -s -- \
--notebook-name susan \
--image registry.cn-hangzhou.aliyuncs.com/acs/arena-notebook:0.2.0-20190617081324-7af0024-cpu
```

#### 删除Notebook


```
# curl -s https://raw.githubusercontent.com/AliyunContainerService/ai-starter/master/scripts/delete_notebook.sh | \
bash -s -- \
--notebook-name susan \
--namespace kubeflow
```