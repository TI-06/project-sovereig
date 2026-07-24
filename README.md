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

## ソース構成

完全なソース一式は`releases/project-sovereign-v0.2.0-source.zip`へ格納されています。GitHub連携で登録したZIPがBase64テキストとして保持される場合があるため、`cloudflare-build.sh`が形式を判定してデコード・展開します。

## Cloudflare Pagesへの無料公開

GitHubリポジトリをCloudflare Pagesへ接続し、以下を設定します。

| 設定 | 値 |
|---|---|
| Framework preset | None |
| Build command | `bash cloudflare-build.sh` |
| Build output directory | `dist` |
| Root directory | 空欄または`/` |
| Production branch | `main` |
| Environment variable | `NODE_VERSION=22.16.0` |

ビルドスクリプト内でソース展開、`npm install`、34件のテスト、型検査、静的ビルドを実行します。

## 設計上の制約

- シミュレーション内では`Math.random()`を使用しません。
- 全状態はJSONへシリアライズ可能です。
- UIに国家計算式を置かず、シミュレーションエンジンと分離します。
- セーブデータはチェックサムで破損を検出します。
- `main`ブランチを公開版の正本とします。

## ドキュメント

- `DEPLOY.md`
- `docs/superpowers/specs/2026-07-24-project-sovereign-master-design.md`
- `docs/superpowers/plans/2026-07-24-project-sovereign-foundation.md`
- `docs/superpowers/plans/2026-07-24-project-sovereign-expanded-systems.md`
- `docs/implementation-notes/0001-zero-dependency-browser-stack.md`
