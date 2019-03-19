#!/usr/bin/env bash
set -e
ACCESS_TYPE="PORT_FORWARD"
LABEL="app=arena-notebook"
DEPLOYMENT_NAME="arena-notebook"

function access_notebook() {
	if [[ "$ACCESS_TYPE" == "SERVICE" ]];then
		expose_service
	else
		port_forward
	fi
}

function port_forward() {
	local NAMESPACE=${NAMESPACE:-default}
	local PORT=${PORT:-8081}
	local PODNAME=${PODNAME:-"arena-notebook-0"}
    if [[ -n $USER_NAME ]];then
      PODNAME="$USER_NAME-arena-notebook-0"
    fi
	# local PODNAME=`kubectl get po -n $NAMESPACE -l $LABEL | grep -v NAME| head -1| awk '{print $1}'`
	echo "Forwarding pod: $NAMESPACE/$PODNAME, port: $PORT"
	echo "Open http://localhost:$PORT in browser"
	kubectl port-forward ${PODNAME} -n ${NAMESPACE} $PORT:8888
}

function expose_service() {
	local NAMESPACE=${NAMESPACE:-default}
	local PODNAME=${PODNAME:-"arena-notebook-0"}
	local SERVICE_TYPE=${SERVICE_TYPE:-LoadBalancer}
	local SERVICE_NAME="arena-notebook"
	local SERVICE_URL=$(get_service_url $SERVICE_NAME)
	if [[ "$SERVICE_URL" != "" ]]; then
		echo "Service $SERVICE_NAME is exist."
		echo "If you want to delete the service, please exec \"kubectl delete svc -n $NAMESPACE $SERVICE_NAME\" "
		echo "If you want to get service detail, please exec \"kubectl get svc -n $NAMESPACE $SERVICE_NAME\" "
		echo "You can access notebook by open http://$SERVICE_URL in bowser"
		exit 0
	fi

	kubectl expose pod $PODNAME -n $NAMESPACE --type=$SERVICE_TYPE --name=$SERVICE_NAME
	echo "Expose notebook by $SERVICE_TYPE type service"
	echo "If you want to delete the service, please exec \"kubectl delete svc -n $NAMESPACE $SERVICE_NAME\" "
	echo "If you want to get service detail, please exec \"kubectl get svc -n $NAMESPACE $SERVICE_NAME\" "
	if [[ "$SERVICE_TYPE" == "LoadBalancer" ]]; then
		echo "Wait for loadbalancer ready..."
	fi
	SERVICE_URL=$(get_service_url $SERVICE_NAME)
	while [[ $SERVICE_URL == "" ]];do
		sleep 3
		SERVICE_URL=$(get_service_url $SERVICE_NAME)
	done
	echo "You can access notebook by open http://$SERVICE_URL in bowser"
}

function get_service_url() {
	local SERVICE_NAME=$1
	local NAMESPACE=${2:-default}
	set +e
	kubectl get svc -n $NAMESPACE $SERVICE_NAME &> /dev/null
	local exist=$?
	set -e
	if [[ $exist == 1 ]]; then
		echo ""
	else
		SERVICE_TYPE=$(kubectl get svc -n $NAMESPACE $SERVICE_NAME -ojsonpath='{.spec.type}')
		SERVICE_PORT=$(kubectl get svc -n $NAMESPACE $SERVICE_NAME -ojsonpath='{.spec.ports[0].port}')
		SERVICE_IP=""
		if [[ "$SERVICE_TYPE" == "NodePort" ]];then
			SERVICE_IP=$(kubectl get no -ojsonpath='{.items[0].status.addresses[0].address}')
		elif [[ "$SERVICE_TYPE" == "LoadBalancer" ]]; then
			SERVICE_IP=$(kubectl get svc -n $NAMESPACE $SERVICE_NAME -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
		else
			SERVICE_IP=$(kubectl get svc -n default $SERVICE_NAME -ojsonpath='{.spec.clusterIP}')
		fi
		
		if [[ $SERVICE_IP == "" ]];then
			echo ""
			exit 0
		fi
		echo "$SERVICE_IP:$SERVICE_PORT"
	fi
}

usage() {
    echo "Usage:"
    echo "  access_notebook.sh [-s] [-p] [-t SERVICE_TYPE]"
    echo "Options:"
    echo "    -p, use port forward to access notebook.[default]"
    echo "    -s, use service to access notebook."
    echo "    -t, the type of service. LoadBalancer/NodePort/ClusterIP"
    exit -1
}

function main() {
	while [ $# -gt 0 ];do
	    case $1 in
	        -p|--port-forward)
	            ACCESS_TYPE="PORT_FORWARD"
	            ;;
	        -s|--service)
	            ACCESS_TYPE="SERVICE"
	            ;;
	        -t|--service-type)
	            SERVICE_TYPE=$2
	            shift
	            ;;
            -u|--user)
              USER_NAME=$2
              shift
              ;;
	        -h|--help)
	            usage
	            exit 0
	            ;;
	        *)
	            echo "unknown option [$key]"
	            exit 1
	        ;;
	    esac
        shift
	done
	access_notebook
}

main "$@"