#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

init() {
  echo "Clean namespace..."
  k delete namespace "$NS" >/dev/null 2>&1
  m delete namespace "$NS" >/dev/null 2>&1
  echo "Create namespace"
  k create ns "$NS"
  m create ns "$NS"
  m label ns "$NS" istio-injection=enabled
}

init

echo "Deploy data plane"
cd ../..
k -n "$NS" apply -f config/kube/
echo " waiting for hello2-deploy-v1"
k -n "$NS" wait --for=condition=ready pod -l app=hello2-deploy-v2
k -n "$NS" wait --for=condition=ready pod -l app=hello1-deploy-v1
k get svc -n "$NS"
k get pods -n "$NS"

echo "Deploy mesh"
m -n "$NS" apply -f config/mesh/
