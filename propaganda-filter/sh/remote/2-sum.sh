#!/usr/bin/env sh
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../..

#https://www.baeldung.com/linux/sha-256-from-command-line
#brew install coreutils
#crypto_util.getSha256Digest
set -e
sha256sum target/wasm32-unknown-unknown/release/propaganda_filter.wasm | awk '{print $1}' \
> target/wasm32-unknown-unknown/release/propaganda_filter.sha256

#SECRET="0123456789abcdef"
#| openssl dgst -sha256 -hmac $SECRET -binary | base64 \
