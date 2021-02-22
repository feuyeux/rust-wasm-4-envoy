#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "ingress v2:"
ingressGatewayIp=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl "http://$ingressGatewayIp:8001/hello/eric?route-v=v2"
echo
curl "http://$ingressGatewayIp:8001/hello/eric?route-v=v2"
echo
curl "http://$ingressGatewayIp:8001/hello/eric?route-v=v2"
