#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../..

cd target/wasm32-unknown-unknown/release/
##
cat propaganda_filter.sha256
ipconfig getifaddr en0
##
python3 -m http.server

