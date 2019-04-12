#!/usr/bin/env bash
set -e

function install_arena() {
  check_resource_exist "pod" "arena-installer" "kube-system"
  if [[ "$UPGRADE" != "true" && "$?" == "0" ]]; then
    echo "Arena has been installed."
    exit 0
  fi

  set -e

	HOST_NETWORK=${HOST_NETWORK:-"true"}
	PROMETHEUS=${PROMETHEUS:-"true"}

	cat <<EOF | kubectl apply -f > $LOG_PRINT -
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
    image: registry.cn-beijing.aliyuncs.com/acs/arena:0.2.0-f6b6188
    env:
    - name: useHostNetwork
      value: "$HOST_NETWORK"
    - name: usePrometheus
      value: "$PROMETHEUS"
    - name: platform
      value: ack
EOF
}

function check_resource_exist() {
  resource_type=$1
  resource_name=$2
  namespace=${3:-"default"}
  set +e
  kubectl get -n $namespace $resource_type $resource_name &> /dev/null
  return $?
}

function parse_args() {
  LOG_PRINT=${LOG_PRINT:-"/dev/null"}
}

function install() {
  parse_args
  install_arena
  echo "Install successful"
}

function main() {
	while [ $# -gt 0 ];do
	    case $1 in
	        -p|--prometheus)
	            PROMETHEUS="true"
	            ;;
          --upgrade)
              UPGRADE="true"
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