#!/usr/bin/env sh
set -e
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit
cd ../..
rustup override set nightly
cargo clean
cargo fmt
#cargo build -vv --target=wasm32-unknown-unknown --release
cargo build --target=wasm32-unknown-unknown --release
echo "built it !"
echo "file path and size:"
ls -hl target/wasm32-unknown-unknown/release/watermark_filter.wasm

#cargo install wasm-gc
wasm-gc ./target/wasm32-unknown-unknown/release/watermark_filter.wasm ./target/wasm32-unknown-unknown/release/watermark-filter.wasm
ls -hl target/wasm32-unknown-unknown/release/watermark-filter.wasm