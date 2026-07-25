# Cloudflare公開設定

- Build command: `bash cloudflare-build.sh`
- Build output directory: `dist`
- Root directory: 空欄
- Production branch: `main`
- Environment variable: `NODE_VERSION=22.16.0`
- Deploy command: `npx wrangler deploy`

`cloudflare-build.sh`はv0.2ソースを展開し、v0.3差分をSHA-256検証後に適用して、型検査と静的ビルドを実行します。
