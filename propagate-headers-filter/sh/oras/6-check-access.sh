#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello2_v1_pod=$(k get pod -l app=hello2-deploy-v1 -n "$NS" -o jsonpath={.items..metadata.name})

#k logs $hello2_v1_pod -n "$NS" -c istio-proxy

echo " checking from $hello2_v1_pod:"
k exec "$hello2_v1_pod" -c hello-v1-deploy -n "$NS" -- curl -s localhost:8001/hello/eric
echo
k exec "$hello2_v1_pod" -c hello-v1-deploy -n "$NS" -- curl -s http://hello2-svc:8001/hello/eric
echo
k exec "$hello2_v1_pod" -c hello-v1-deploy -n "$NS" -- curl -s http://hello1-svc:8001/hello/eric
echo
