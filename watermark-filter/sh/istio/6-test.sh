#!/usr/bin/env sh
# shellcheck disable=SC2028
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
alias k="kubectl --kubeconfig ${HOME}/shop_config/ack_cd"

echo "ingress v2:"
ingressGatewayIp=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -H "route-v:v2" "http://$ingressGatewayIp:8001/hello/eric"
echo
curl -H "route-v:v2" "http://$ingressGatewayIp:8001/hello/eric"
echo
curl -H "route-v:v2" "http://$ingressGatewayIp:8001/hello/eric"

mesh_inside_test() {
  hello3_v2_pod=$(k get pod -l app=hello3-deploy-v2 -n http-hello -o jsonpath={.items..metadata.name})

  echo "\n hello1 v2:"
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello1-svc:8001/hello/eric
  echo
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello1-svc:8001/hello/eric
  echo
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello1-svc:8001/hello/eric
  echo "\n hello2 v2:"
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello2-svc:8001/hello/eric
  echo
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello2-svc:8001/hello/eric
  echo
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello2-svc:8001/hello/eric
  echo "\n hello3 v2:"
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello3-svc:8001/hello/eric
  echo
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello3-svc:8001/hello/eric
  echo
  k -n http-hello exec "$hello3_v2_pod" -c hello-v2-deploy -- curl -s -H "route-v:v2" hello3-svc:8001/hello/eric
}
