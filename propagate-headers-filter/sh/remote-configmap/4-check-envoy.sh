#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
check() {
  pod=$1
  timestamp=$(date "+%Y%m%d-%H%M%S")
  echo "==== Check from $pod ===="
  k -n http-hello exec "$pod" -c istio-proxy \
    -- curl -s "http://localhost:15000/config_dump?resource=dynamic_listeners" >dynamic_listeners-"$timestamp".json
  #grep "head_tag_name" dynamic_listeners-"$timestamp".json
  grep "propaganda-header-filter.wasm" dynamic_listeners-"$timestamp".json
  grep "envoy.lua" dynamic_listeners-"$timestamp".json
  echo "..."
}

k get pod -n http-hello
echo
for i in {1..3}; do
  for j in {1..2}; do
    check $(k get pod -l app=hello$i-deploy-v$j -n http-hello -o jsonpath={.items..metadata.name})
  done
done

rm -f d*.json
