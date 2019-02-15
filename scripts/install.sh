function install() {
	HOST_NETWORK=${HOST_NETWORK:-"false"}
	PROMETHEUS=${PROMETHEUS:-"false"}
	NAMESPACE=${NAMESPACE:-"default"}

	cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: arena-installer
  namespace: $NAMESPACE
  labels:
    app: arena-installer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arena-installer
  template:
    metadata:
      labels:
        app: arena-installer
    spec:
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
        - name: KUBECONFIG
          value: /root/.kube/config
        volumeMounts:
        - mountPath: /root/.kube/config
          name: kube-config
      volumes:
        - name: kube-config
          hostPath:
            path: /root/.kube/config
            type: File
EOF
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
	            NAMESPACE=$2
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