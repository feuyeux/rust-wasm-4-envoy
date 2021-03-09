#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"

#### secret ####
# asmwasm-cache
# wasm-repo-registry.cn-beijing.cr.aliyuncs.com
# feuyeux@126.com

# aliyun servicemesh UpdateMeshFeature \
#   --ServiceMeshId $MESH_ID \
#   --WebAssemblyFilterEnabled=false

# aliyun servicemesh UpdateMeshFeature \
#   --ServiceMeshId $MESH_ID \
#   --WebAssemblyFilterEnabled=true
# sleep 5s

aliyun servicemesh DescribeServiceMeshDetail \
  --ServiceMeshId $MESH_ID |
  jq '.ServiceMesh.Spec.MeshConfig.WebAssemblyFilterDeployment'

echo "Check DaemonSet"
k get daemonset -n istio-system
