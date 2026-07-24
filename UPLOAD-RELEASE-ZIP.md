# 正しいリリースZIPへの置き換え

`releases/project-sovereign-v0.2.0-source.zip` はコネクタ経由のバイナリ登録時に破損しています。

1. GitHubで既存の `releases/project-sovereign-v0.2.0-source.zip` を削除する
2. ChatGPTから取得した同名のソースZIPをGitHub画面の Upload files からアップロードする
3. Cloudflare Pagesで Retry deployment を実行する

CloudflareのBuild commandは `bash cloudflare-build.sh` のままで構いません。
