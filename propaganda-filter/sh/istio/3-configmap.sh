#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"

echo "1 store wasm to configmap"
k delete configmap -n http-hello propaganda-filter >/dev/null 2>&1
cd ../..
k create configmap -n http-hello propaganda-filter --from-file=target/wasm32-unknown-unknown/release/propaganda-filter.wasm

echo "2 patch annotations to deployment"
cd "$SCRIPT_PATH"
patch_annotations=$(cat annotations/patch-annotations.yaml)

for i in {1..3}; do
  for j in {1..3}; do
    k -n http-hello patch deployment "hello$i-deploy-v$j" -p "$patch_annotations"
  done
done
echo "3 check..."
sleep 10s
for i in {1..3}; do
  for j in {1..3}; do
    echo "deployment/hello$i-deploy-v$j:"
    k -n http-hello exec -it deployment/hello"$i"-deploy-v"$j" -c istio-proxy -- ls -l /var/local/lib/wasm-filters/
  done
done