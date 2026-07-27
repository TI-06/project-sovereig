# v0.7.0 Reconstruction Package

`chunks/` contains the Base64-encoded XZ patch that upgrades the verified v0.6.2 reconstructed source to PROJECT SOVEREIGN v0.7.0.

The root `cloudflare-build.sh` performs these checks before applying it:

1. Exactly 13 chunks are present in lexical order.
2. The concatenated Base64 payload matches `SHA256SUMS`.
3. The decoded XZ archive passes `xz -t` and its checksum.
4. The decompressed patch matches its checksum and applies cleanly to v0.6.2.
5. The reconstructed source reports package version `0.7.0`.
6. Tests, type checking, static build and deployment marker checks pass.

The v0.7 release is new-game-only. Saves from v0.5 through v0.6.2 are not migrated.
