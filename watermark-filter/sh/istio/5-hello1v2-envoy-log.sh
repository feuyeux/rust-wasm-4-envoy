#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
alias k="kubectl --kubeconfig ${HOME}/shop_config/ack_cd"

#k -n http-hello exec deployment/hello1-deploy-v2 -c istio-proxy -- ps aux
k -n http-hello logs -f deployment/hello1-deploy-v2 -c istio-proxy