function print_ingress() {
	ingress_host=$(kubectl get ingress notebook-ingress -ojsonpath='{.spec.rules[0].host}')
	ingress_ip=$(kubectl get ingress notebook-ingress -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
	echo "Ingress of notebook ip is $ingress_ip"
	echo "Ingress of notebook domain is $ingress_host"
}

print_ingress