function install_arena() {
	HOST_NETWORK=${HOST_NETWORK:-"true"}
	PROMETHEUS=${PROMETHEUS:-"true"}

	cat <<EOF | kubectl apply -f > /dev/null -
apiVersion: v1
kind: Pod
metadata:
  name: arena-installer
  namespace: kube-system
spec:
  restartPolicy: Never
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
EOF
}

function install_notebook() {
  NAMESPACE=${NAMESPACE:-"default"}
  NOTEBOOK_NAME=arena-notebook
  NOTEBOOK_PASSWORD=${NOTEBOOK_PASSWORD:-`openssl rand -base64 8`}
  PVC_NAME=${PVC_NAME:-"training-data"}
  PVC_MOUNT_PATH=${PVC_MOUNT_PATH:-"/root"}
  SREVICE_TYPE=${SREVICE_TYPE:-"ClusterIP"}
  NOTEBOOK_IMAGE=${NOTEBOOK_IMAGE:-"registry.cn-beijing.aliyuncs.com/acs/arena-notebook:cpu"}

kubectl create secret generic $NOTEBOOK_NAME -n $NAMESPACE --from-literal password=$NOTEBOOK_PASSWORD

  cat <<EOF | kubectl apply -f > /dev/null -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $NOTEBOOK_NAME
  namespace: $NAMESPACE
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $NOTEBOOK_NAME
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - deployments
  - nodes
  - nodes/*
  - services/proxy
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $NOTEBOOK_NAME
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
  name: $NOTEBOOK_NAME-cluster-role
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $NOTEBOOK_NAME
subjects:
- kind: ServiceAccount
  name: $NOTEBOOK_NAME
  namespace: $NAMESPACE
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $NOTEBOOK_NAME-role
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $NOTEBOOK_NAME
subjects:
- kind: ServiceAccount
  name: $NOTEBOOK_NAME
  namespace: $NAMESPACE
---
# Define the arena notebook deployment
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: $NOTEBOOK_NAME
  namespace: $NAMESPACE
  labels:
    app: $NOTEBOOK_NAME
spec:
  selector: # define how the deployment finds the pods it mangages
    matchLabels:
      app: $NOTEBOOK_NAME
  serviceName: "$NOTEBOOK_NAME"
  template:
    metadata:
      labels:
        app: $NOTEBOOK_NAME
    spec:
      serviceAccountName: $NOTEBOOK_NAME
      containers:
      - name: $NOTEBOOK_NAME
        image: $NOTEBOOK_IMAGE
        imagePullPolicy: Always
        ports:
        - containerPort: 8888
        env:
          - name: PASSWORD
            valueFrom:
              secretKeyRef:
                name: $NOTEBOOK_NAME
                key: password
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

echo "Installing the notebook with password: $NOTEBOOK_PASSWORD"

# Define the arena notebook service
  cat <<EOF | kubectl apply -f > /dev/null -
apiVersion: v1
kind: Service
metadata:
  name: $NOTEBOOK_NAME
  namespace: $NAMESPACE
spec:
  ports:
  - port: 80
    targetPort: 8888
    name: notebook
  selector:
    app: $NOTEBOOK_NAME
  type: $SREVICE_TYPE
EOF
}

function install_ingress() {
if [[ "$INSTALL_INGRESS" != "true" ]]; then
  return 
fi
cat <<EOF | kubectl apply -f > /dev/null -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: notebook-ingress
  namespace: $NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: $INGRESS_HOST
    http:
      paths:
      - backend:
          serviceName: $NOTEBOOK_NAME
          servicePort: 80
EOF
}

function check_args() {
  # if [[ ! -n $USER_NAME ]]; then
  #   echo "USER_NAME can't be empty, please add -u <user name> params to specify"
  #   exit 1
  # fi
  if [[ -n $INSTALL_INGRESS ]]; then
    if [[ ! -n $INGRESS_HOST ]]; then
      echo "INGRESS_HOST can't be empty, please add --ingress-domain <user name> params to specify the ingress domain"
      exit 1
    fi
  fi
}

function clean_notebook() {
  NOTEBOOK_NAME=arena-notebook
  kubectl delete ingress notebook-ingress > /dev/null
  kubectl delete svc $NOTEBOOK_NAME > /dev/null
  kubectl delete sts $NOTEBOOK_NAME > /dev/null
  kubectl delete sa $NOTEBOOK_NAME > /dev/null
  kubectl delete role $NOTEBOOK_NAME > /dev/null
  kubectl delete secret $NOTEBOOK_NAME > /dev/null
  kubectl delete ClusterRole $NOTEBOOK_NAME > /dev/null
  kubectl delete ClusterRoleBinding $NOTEBOOK_NAME-cluster-role > /dev/null
  kubectl delete RoleBinding $NOTEBOOK_NAME-role > /dev/null
  echo "Clean notebook finish."
}

function install() {
  if [[ "$CLEAN" == "true" ]]; then
    clean_notebook
    return 
  fi
  check_args
  install_arena
  install_notebook
  install_ingress
  echo "Install successful"
}

function main() {
	while [ $# -gt 0 ];do
	    case $1 in
	        -p|--prometheus)
	            PROMETHEUS="true"
	            ;;
	        --host-network)
	            HOST_NETWORK="true"
	            ;;
          -n|--namespace)
              NAMESPACE=$2
              shift
              ;;
          -p|--password)
              NOTEBOOK_PASSWORD=$2
              shift
              ;;
          -b|--notebook)
              INSTALL_NOTEBOOK=$2
              shift
              ;;
          -i|--ingress)
              INSTALL_INGRESS="true"
              ;;
          --ingress-domain)
              INGRESS_HOST=$2
              shift
              ;;
          -u|--user)
              USER_NAME=$2
              shift
              ;;
          --clean)
              CLEAN="true"
              ;;
	        --debug)
	            set -x
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