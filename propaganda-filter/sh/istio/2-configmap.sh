#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../..

alias k="kubectl --kubeconfig ${HOME}/shop_config/ack_cd"

k delete configmap -n http-hello propaganda-filter
k create configmap -n http-hello propaganda-filter --from-file=target/wasm32-unknown-unknown/release/propaganda-filter.wasm

k -n http-hello patch deployment hello3-deploy-v1 -p "$(cat patch-annotations.yaml)"
k -n http-hello exec -it deployment/hello3-deploy-v1 -c istio-proxy -- ls -l /var/local/lib/wasm-filters/