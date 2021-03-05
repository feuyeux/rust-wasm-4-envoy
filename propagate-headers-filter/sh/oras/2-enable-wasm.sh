#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"

MESH_ID=cf1c81c59d8dd49e394696c1d63956262

aliyun servicemesh UpdateMeshFeature \
  --ServiceMeshId $MESH_ID \
  --WebAssemblyFilterEnabled=true

aliyun servicemesh DescribeServiceMeshDetail \
  --ServiceMeshId $MESH_ID |
  jq '.ServiceMesh.Spec.MeshConfig.WebAssemblyFilterDeployment'

echo "Check DaemonSet"
k get daemonset -n istio-system
