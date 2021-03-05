#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

source config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

echo "Deploy ASMFilterDeployment"
m apply -f afd/ -n "$NS"
m get envoyfilter -n "$NS"
m get asmfilterdeployment -n "$NS"