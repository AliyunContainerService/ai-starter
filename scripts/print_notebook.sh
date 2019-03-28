#!/usr/bin/env bash
set -e

function print_ingress() {
  NOTEBOOK_NAME=${NOTEBOOK_NAME:-"arena-notebook"}
  if [[ -n $NOTEBOOK_WORKSPACE_NAME ]];then
    NOTEBOOK_NAME="$NOTEBOOK_WORKSPACE_NAME-notebook"
  fi
	INGRESS_NAME="arena-notebook-ingress"
	if [[ -n $NOTEBOOK_NAME ]];then
		INGRESS_NAME="$NOTEBOOK_NAME-ingress"
	fi
  INGRESS_NAMESPACE=${INGRESS_NAMESPACE:-"default"}
	pod_ip=$(kubectl get pod $NOTEBOOK_NAME-0  -n $INGRESS_NAMESPACE -ojsonpath='{.status.podIP}')
	echo "Notebook pod ip is $pod_ip"

	token=$(kubectl logs $NOTEBOOK_NAME-0  -n $INGRESS_NAMESPACE | grep NotebookApp | grep 'token='  | awk -F 'token=' '{print $2}')
	if [[ $token != "" ]];then
		echo "Notebook access token is $token"
	fi

	service_type=$(kubectl get service $NOTEBOOK_NAME  -n $INGRESS_NAMESPACE -ojsonpath='{.spec.type}')
	if [[ "$service_type" == "NodePort" ]];then
		node_port=$(kubectl get service -oyaml $NOTEBOOK_NAME  -n $INGRESS_NAMESPACE -ojsonpath='{.spec.ports[0].nodePort}')
		node_ip=$(kubectl get no -ojsonpath='{.items[0].status.addresses[0].address}')
		echo "You can access By NodePort: $node_ip:$node_port"
	fi

  # if the notebook ingress is exist
  local ingress_exist=$(check_resource_exist ingress $INGRESS_NAME $INGRESS_NAMESPACE)
  if [[ "$ingress_exist" == "0" ]]; then
		ingress_host=$(kubectl get ingress $INGRESS_NAME -n $INGRESS_NAMESPACE -ojsonpath='{.spec.rules[0].host}')
		ingress_ip=$(kubectl get ingress $INGRESS_NAME -n $INGRESS_NAMESPACE -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
		echo "Ingress of notebook ip is $ingress_ip"
		echo "Ingress of notebook domain is $ingress_host"
  fi
}

function check_resource_exist() {
  resource_type=$1
  resource_name=$2
  namespace=${3:-"default"}
  kubectl get -n $namespace $resource_type $resource_name &> /dev/null
  echo $?
}


function main() {
	while [ $# -gt 0 ];do
	    case $1 in
	        -n|--namespace)
	            INGRESS_NAMESPACE=$2
              shift
	            ;;
            --notebook-name)
              NOTEBOOK_WORKSPACE_NAME=$2
              shift
              ;;
	        -h|--help)
	            exit 0
	            ;;
	        *)
	            echo "unknown option [$key]"
	            exit 1
	        ;;
	    esac
        shift
	done
	print_ingress
}

main "$@"
