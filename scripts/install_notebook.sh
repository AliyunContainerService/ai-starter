#!/usr/bin/env bash
set -e

function install_notebook() {

kubectl create secret generic $NOTEBOOK_NAME -n $NAMESPACE --from-literal password=$NOTEBOOK_PASSWORD

  cat <<EOF | kubectl apply -f > $LOG_PRINT -
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
  cat <<EOF | kubectl apply -f > $LOG_PRINT -
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

cat <<EOF | kubectl apply -f > $LOG_PRINT -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: $NOTEBOOK_NAME-ingress
  namespace: $NAMESPACE
spec:
  tls:
  - hosts:
    - $INGRESS_HOST
    secretName: $INGRESS_SECRET_NAME
  rules:
  - host: $INGRESS_HOST
    http:
      paths:
      - backend:
          serviceName: $NOTEBOOK_NAME
          servicePort: 80
EOF
}

function parse_args() {
  NAMESPACE=${NAMESPACE:-"default"}
  NOTEBOOK_PASSWORD=${NOTEBOOK_PASSWORD:-`openssl rand -base64 8`}
  PVC_NAME=${PVC_NAME:-"training-data"}
  PVC_MOUNT_PATH=${PVC_MOUNT_PATH:-"/root"}
  SREVICE_TYPE=${SREVICE_TYPE:-"ClusterIP"}
  NOTEBOOK_IMAGE=${NOTEBOOK_IMAGE:-"registry.cn-beijing.aliyuncs.com/acs/arena-notebook:cpu"}
  NOTEBOOK_NAME=${NOTEBOOK_NAME:-"arena-notebook"}
  if [[ -n $USER_NAME ]];then
    NOTEBOOK_NAME="$USER_NAME-arena-notebook"
  fi
  LOG_PRINT=${LOG_PRINT:-"/dev/null"}
}

function check_args() {
  # if [[ ! -n $USER_NAME ]]; then
  #   echo "USER_NAME can't be empty, please add -u <user name> params to specify"
  #   exit 1
  # fi
  if [[ -n $INSTALL_INGRESS ]]; then
    if [[ ! -n $INGRESS_HOST ]]; then
      echo "INGRESS_HOST can't be empty, please add --ingress-domain <user name> to specify the ingress domain"
      exit 1
    fi
    if [[ ! -n $INGRESS_SECRET_NAME ]]; then
      echo "INGRESS_HOST can't be empty, please add --ingress-secret <secret name> to specify the ingress tls secret"
      exit 1
    fi
    check_resource_exist secret $INGRESS_SECRET_NAME $NAMESPACE || \
    echo "Secret \"$INGRESS_SECRET_NAME\" is not exist, please check the secret specify by --ingress-secret" && \
    exit 1
  fi
  # if the notebook sts is exist
  check_resource_exist sts $NOTEBOOK_NAME $NAMESPACE
  if [[ "$CLEAN" != "true" && "$?" == "0" ]]; then
    echo "This  notebook \"$NOTEBOOK_NAME\" is installed, if you want to reinstall notebook, please specify --clean to uninstall"
    echo "If you want to install notebook for another user, please specify --user <user-name> for user, or specify -n <namespace-name> for different namespace"
    exit 0
  fi
}

function check_resource_exist() {
  resource_type=$1
  resource_name=$2
  namespace=${3:-"default"}
  kubectl get -n $namespace $resource_type $resource_name &> /dev/null
  return $?
}

function delete_resource() {
  resource_type=$1
  resource_name=$2
  namespace=${3:-"default"}
  
  check_resource_exist $resource_type $resource_name $namespace && \
    kubectl delete -n $namespace $resource_type $resource_name
  return $?
}

function clean_notebook() {
  delete_resource svc $NOTEBOOK_NAME $NAMESPACE
  delete_resource sts $NOTEBOOK_NAME $NAMESPACE
  delete_resource sa $NOTEBOOK_NAME $NAMESPACE
  delete_resource secret $NOTEBOOK_NAME $NAMESPACE
  delete_resource clusterRole $NOTEBOOK_NAME $NAMESPACE
  delete_resource clusterRoleBinding "$NOTEBOOK_NAME-cluster-role" $NAMESPACE
  delete_resource role $NOTEBOOK_NAME $NAMESPACE
  delete_resource roleBinding "$NOTEBOOK_NAME-role" $NAMESPACE
  delete_resource ingress "$NOTEBOOK_NAME-ingress" $NAMESPACE

  echo "Clean notebook finish."
}

function install() {
  parse_args
  check_args
  if [[ "$CLEAN" == "true" ]]; then
    clean_notebook
    return 
  fi
  install_notebook
  install_ingress
  echo "Install successful"
}

function main() {
	while [ $# -gt 0 ];do
	    case $1 in
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
          --ingress)
              INSTALL_INGRESS="true"
              ;;
          --ingress-domain)
              INGRESS_HOST=$2
              shift
              ;;
          --ingress-secret)
              INGRESS_SECRET_NAME=$2
              shift
              ;;
          -u|--user)
              USER_NAME=$2
              shift
              ;;
          --pvc-name)
              PVC_NAME=$2
              shift
              ;;
          --notebook-image)
              NOTEBOOK_IMAGE=$2
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