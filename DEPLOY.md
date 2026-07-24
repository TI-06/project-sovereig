# Cloudflare Pages公開手順

## GitHub連携で公開する場合

1. Cloudflare Dashboardで Workers & Pages を開く
2. Create application → Pages → Connect to Git
3. `TI-06/project-sovereig`を選択
4. 以下を設定する

| 設定 | 値 |
|---|---|
| Framework preset | None |
| Build command | `npm install --no-audit --no-fund && npm run build` |
| Build output directory | `dist` |
| Root directory | `/` |
| Production branch | `main` |
| Node.js version | `22` |

## 現在のリポジトリ構成について

完全なソース一式は`releases/project-sovereign-v0.2.0-source.zip`に格納されています。ZIPを展開してリポジトリ直下へ配置すると、上記のGit連携ビルドが利用できます。

すぐに公開確認する場合は、チャットで提供した`project-sovereign-v0.2.0-static.zip`をCloudflare PagesのDirect Uploadへ展開・アップロードしてください。
