#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
WASM_REGISTRY=wasm-repo-registry.cn-beijing.cr.aliyuncs.com/asm_wasm
WASM_IMAGE=propaganda-header-filter.wasm
cp ../../target/wasm32-unknown-unknown/release/$WASM_IMAGE .
oras push $WASM_REGISTRY/propagate_header:0.0.1 \
  --manifest-config \
  runtime-config.json:application/vnd.module.wasm.config.v1+json \
  ${WASM_IMAGE}:application/vnd.module.wasm.content.layer.v1+wasm
rm -f $WASM_IMAGE
