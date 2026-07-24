# Cloudflare Pages公開手順

## GitHub連携で公開する場合

1. Cloudflare Dashboardで `Workers & Pages` を開く
2. `Create application` → `Pages` → `Connect to Git`
3. `TI-06/project-sovereig`を選択
4. 以下を設定する

| 設定 | 値 |
|---|---|
| Framework preset | None |
| Build command | `bash cloudflare-build.sh` |
| Build output directory | `dist` |
| Root directory | 空欄または`/` |
| Production branch | `main` |
| Environment variable | `NODE_VERSION=22.16.0` |

## 以前のZIPエラーについて

GitHub連携経由で登録した`releases/project-sovereign-v0.2.0-source.zip`は、実バイナリではなくBase64テキストとして保持されています。そのまま`unzip`すると`End-of-central-directory signature not found`になります。

`cloudflare-build.sh`は次を自動実行します。

1. 通常のZIPかBase64テキストかを判定
2. 必要な場合だけBase64デコード
3. ソースを展開
4. 依存関係をインストール
5. 34件のテスト、型検査、ビルドを実行
6. 公開対象をルートの`dist`へ配置

Cloudflareの既存プロジェクトでは、Build commandだけを`bash cloudflare-build.sh`へ変更し、`Save`後に`Retry deployment`を実行してください。
