#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
alias k="kubectl --kubeconfig ${HOME}/shop_config/ack_cd"
timestamp=$(date "+%Y%m%d-%H%M%S")
hello1_v2_pod=$(k get pod -l app=hello1-deploy-v2 -n http-hello -o jsonpath={.items..metadata.name})
k -n http-hello exec "$hello1_v2_pod" -c istio-proxy \
-- curl -s "http://localhost:15000/config_dump?resource=dynamic_listeners" >dynamic_listeners-"$timestamp".json