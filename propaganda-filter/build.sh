#!/usr/bin/env sh
rustup override set nightly
cargo clean
#cargo build -vv --target=wasm32-unknown-unknown --release
cargo build --target=wasm32-unknown-unknown --release
echo "built it ! it' here:"
ls -hl target/wasm32-unknown-unknown/release/propaganda_filter.wasm
