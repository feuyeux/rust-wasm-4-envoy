#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
alias k="kubectl --kubeconfig ${HOME}/shop_config/ack_cd"

ingressGatewayIp=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -H "version:v1" "http://$ingressGatewayIp:8001/hello/eric"
echo
curl -H "version:v2" "http://$ingressGatewayIp:8001/hello/eric"
echo
curl -H "version:v3" "http://$ingressGatewayIp:8001/hello/eric"


k -n http-hello logs -f deployment/hello1-deploy-v2 -c istio-proxy


k -n http-hello logs -f deployment/hello2-deploy-v1 -c hello-v1-deploy