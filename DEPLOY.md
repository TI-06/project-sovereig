# Cloudflare公開設定

- Build command: `bash cloudflare-build.sh`
- Build output directory: `dist`
- Root directory: 空欄
- Production branch: `main`
- Environment variable: `NODE_VERSION=22.16.0`
- Deploy command: `npx wrangler deploy`
- Release: `v0.3.0`
- Source commit: `5bd63269`

`cloudflare-build.sh`はv0.2ソースを展開し、Git管理されたv0.3分割データを復元します。復元後はZIP整合性、必須ファイル、TypeScript型検査、静的ビルド、公開成果物を検証します。
