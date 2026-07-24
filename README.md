# PROJECT SOVEREIGN

**Public Alpha v0.2.0**

経済・企業・国民・政治・外交が月次で相互作用する、PCブラウザ向けの本格国家運営シミュレーションです。

## 現在の実装範囲

- 4国家、12地域、8商品、24企業、36人口コホート
- 1ターン1か月、1・3・6・12か月の一括進行
- 税率、政策金利、教育・医療・産業予算の変更
- GDP、物価、雇用、財政、貿易、為替、支持率、安定度
- 企業の生産・雇用・利益・経営危機・倒産
- 所得階層別の幸福度・怒り・雇用
- 国家間の信頼・脅威・依存・貿易協定と基礎AI
- 政治・議会：4政党、200議席、連立政権、選挙、法律、政治資本
- 研究・公共事業：6研究分野、技術解放、交通・電力・大学・医療・デジタル整備
- 国家危機：洪水、地震、感染症、エネルギー危機、金融不安と3段階の対応
- 軍事・戦争：国防予算、動員、兵站、戦線、損耗、戦争疲弊、講和
- 情報・諜報：偵察、世論工作、産業破壊、防諜、露見時の外交悪化
- 実績：長期運営、技術立国、外交網、健全財政、繁栄国家
- 指標変化の原因説明と危機発生時の自動停止
- Web Workerによるシミュレーション実行
- IndexedDBへの10世代保存、破損世代のスキップ、JSON入出力
- 同じシードと命令で同じ結果を返す決定論的処理

## 必要環境

- Node.js 22以上
- npm
- 最新版のChrome、Edge、Firefox、Safariのいずれか

外部の有料API、サーバー、画像素材は不要です。

## 開発コマンド

```bash
npm install
npm run verify
npm run serve
```

`npm run serve`後、`http://localhost:4173`をPCブラウザで開きます。

| コマンド | 内容 |
|---|---|
| `npm test` | 単体・再現性・1,200ターン耐久・構成テスト |
| `npm run typecheck` | TypeScript厳格チェック |
| `npm run build` | `dist/`へ静的ファイルを生成 |
| `npm run verify` | テスト、型検査、ビルドを一括実行 |
| `npm run serve` | `dist/`をローカル配信 |

## Cloudflare Pagesへの無料公開

GitHubリポジトリをCloudflare Pagesへ接続し、以下を設定します。

| 設定 | 値 |
|---|---|
| Framework preset | None |
| Build command | `npm install --no-audit --no-fund && npm run build` |
| Build output directory | `dist` |
| Root directory | `/` |
| Production branch | `main` |
| Node.js version | `22` |

`public/_headers`と`public/_redirects`はビルド時に`dist/`へコピーされます。

## 設計上の制約

- シミュレーション内では`Math.random()`を使用しません。
- 全状態はJSONへシリアライズ可能です。
- UIに国家計算式を置かず、シミュレーションエンジンと分離します。
- セーブデータはチェックサムで破損を検出します。
- 現時点の正本はローカル実装です。GitHubの空リポジトリ作成後にブランチと履歴を投入します。

## ドキュメント

- `docs/superpowers/specs/2026-07-24-project-sovereign-master-design.md`
- `docs/superpowers/plans/2026-07-24-project-sovereign-foundation.md`
- `docs/superpowers/plans/2026-07-24-project-sovereign-expanded-systems.md`
- `docs/implementation-notes/0001-zero-dependency-browser-stack.md`
