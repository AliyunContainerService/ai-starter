function install_arena() {
	HOST_NETWORK=${HOST_NETWORK:-"false"}
	PROMETHEUS=${PROMETHEUS:-"false"}

	cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: arena-installer
  namespace: kube-system
spec:
  restartPolicy: Never
  hostNetwork: true
  serviceAccountName: admin
  hostNetwork: true
  containers:
  - name: arena
    image: cheyang/arena:0.2.0
    env:
    - name: useHostNetwork
      value: "$HOST_NETWORK"
    - name: usePrometheus
      value: "$PROMETHEUS"
    - name: platform
      value: ack
  tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
    operator: Exists
EOF
}

function install_notebook() {
  NAMESPACE=${NAMESPACE:-"default"}
  NOTEBOOK_PASSWORD=${NOTEBOOK_PASSWORD:-`openssl rand -base64 8`}
  PVC_NAME=${PVC_NAME:-"training-data"}
  PVC_MOUNT_PATH=${PVC_MOUNT_PATH:-"/root"}
  SREVICE_TYPE=${SREVICE_TYPE:-"ClusterIP"}
  NOTEBOOK_IMAGE=${NOTEBOOK_IMAGE:-"registry.cn-beijing.aliyuncs.com/acs/arena-notebook:cpu"}

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: arena-notebook
  namespace: $NAMESPACE
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: arena-notebook
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - deployments
  - nodes
  - nodes/*
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: arena-notebook
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - services/proxy
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  - services
  verbs:
  - '*'
- apiGroups:
  - ""
  - apps
  - extensions
  resources:
  - deployments
  - replicasets
  verbs:
  - '*'
- apiGroups:
  - kubeflow.org
  resources:
  - '*'
  verbs:
  - '*'
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - '*'
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: arena-notebook-cluster-role
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: arena-notebook
subjects:
- kind: ServiceAccount
  name: arena-notebook
  namespace: $NAMESPACE
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: arena-notebook-role
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: arena-notebook
subjects:
- kind: ServiceAccount
  name: arena-notebook
  namespace: $NAMESPACE
---
# Define the arena notebook deployment
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: arena-notebook
  namespace: $NAMESPACE
  labels:
    app: arena-notebook
spec:
  selector: # define how the deployment finds the pods it mangages
    matchLabels:
      app: arena-notebook
  serviceName: "arena-notebook"
  template:
    metadata:
      labels:
        app: arena-notebook
    spec:
      serviceAccountName: arena-notebook
      containers:
      - name: arena-notebook
        image: $NOTEBOOK_IMAGE
        imagePullPolicy: Always
        ports:
        - containerPort: 8888
        env:
          - name: PASSWORD
            value: $NOTEBOOK_PASSWORD
        volumeMounts:
          - mountPath: "$PVC_MOUNT_PATH"
            name: workspace
      volumes:
        - name: workspace
          persistentVolumeClaim:
            claimName: $PVC_NAME
EOF

# Define the arena notebook service
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: arena-notebook
  namespace: $NAMESPACE
spec:
  ports:
  - port: 80
    targetPort: 8888
    name: notebook
  selector:
    app: arena-notebook
  type: $SREVICE_TYPE
EOF
}

function install() {
  # install_arena
  install_notebook
}

function main() {
	while [ $# -gt 0 ];do
	    case $1 in
	        -p|--prometheus)
	            PROMETHEUS="true"
	            ;;
	        -h|--host-network)
	            HOST_NETWORK="true"
	            ;;
          -n|--namespace)
              NAMESPACE=$2
              shift
              ;;
          -b|--notebook)
              INSTALL_NOTEBOOK=$2
              shift
              ;;
	        -u|--user)
	            USER_NAME=$2
	            shift
	            ;;
	        *)
	            echo "unknown option [$key]"
	            exit 1
	        ;;
	    esac
        shift
	done
	install
}

main "$@"