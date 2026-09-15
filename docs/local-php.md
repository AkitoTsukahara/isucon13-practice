# 個人練習用 PHP 環境

## 前提

- OrbStackを起動し、`docker info` が成功すること。Docker Desktopは不要です。
- Git、Docker Compose、make、curlを利用します。ホストへのPHP・Composer・MySQLのインストールは不要です。
- localhostの8080・8443・13306・1053（TCP/UDP）・8081ポートを利用します。
- 本構成はPHP APIの練習用です。フロントエンドの配信、TLS、ベンチマークの実行環境は今回の確認範囲に含みません。

## 初回セットアップ

```sh
git clone git@github.com:AkitoTsukahara/isucon13-practice.git
cd isucon13-practice
git config user.name AkitoTsukahara
git config user.email 10906919+AkitoTsukahara@users.noreply.github.com
git config remote.pushDefault origin
docker context use orbstack
make up
make initialize
curl --fail http://127.0.0.1:8080/api/tag
```

`make initialize` の応答は `{"language":"php"}` です。初期データとDNSゾーンを投入します。**再実行すると練習で変更したアプリのデータを初期化します。**

MySQLは最初の起動時にスキーマを作成します。ビルドとDBの準備には数分かかります。

## 毎回の練習

```sh
make up
make status
# webapp/php/src、app、public を編集
curl --fail http://127.0.0.1:8080/api/tag
make logs
# 終了時（DBデータは保持）
make stop
```

PHPの`src`・`app`・`public`はホストからマウントしているため、通常のソース変更は直接反映されます。DockerfileやComposer依存関係を変更した場合は `make up` で再ビルドします。

- コンテナ内のシェル: `make shell`
- コンテナ削除（DBデータは保持）: `make down`
- アプリの初期データへのリセット: `make initialize`
- DBの完全な作り直し（データ削除）:

```sh
docker compose -f development/docker-compose-common.yml -f development/docker-compose-php.yml down --volumes
make up
make initialize
```

従来の `development` 内の `make down/php` は `--volumes` 付きでDBも削除するので、普段はルートのMakefileを利用してください。

API: http://127.0.0.1:8080/api/tag （8443もHTTPです）。`/`にフロント画面はありません。MySQLには `127.0.0.1:13306`、DB `isupipe`、ユーザー/パスワード `isucon` / `isucon` で接続できます。ローカル練習専用の認証情報です。

起動に失敗した場合は `make status` と `make logs` を確認します。ポート競合の場合は該当する別プロジェクトを停止するか、Composeのホスト側ポートとMakefileのURLを揃えて変更してください。

## 履歴とGitHubの活動記録

元リポジトリ: https://github.com/AkitoTsukahara/isucon13_RAM

個人用: https://github.com/AkitoTsukahara/isucon13-practice

元のmainの履歴（`40ea13059afa6dc4786182a04dd31dc1ae38f3c5`まで）は作者・コミットIDを維持しています。個人用はforkではない独立リポジトリです。新しい変更は本人に紐付く上記noreplyメールでコミットし、デフォルトブランチのmainへpushします。

```sh
git add <変更したファイル>
git commit -m '変更内容'
git push origin main
```

過去の他の作者のコミットは本人の活動にはなりません。また、履歴のコピーが今日の新規コミットとして数えられるわけではありません。今後の本人のコミットを活動として記録するための構成です。GitHubのグラフへの反映には最大24時間程度かかる場合があります。

このセットアップを実施した作業ディレクトリでは `upstream` を元リポジトリに向け、push URLを `DISABLED` に設定しています。新しくcloneした場合は `origin` のみで個人用に接続されます。元リポジトリを参照したい場合は次のように読み取り用途で登録できます。

```sh
git remote add upstream https://github.com/AkitoTsukahara/isucon13_RAM.git
git remote set-url --push upstream DISABLED
```

参考: [GitHubのcontribution条件](https://docs.github.com/en/account-and-profile/reference/profile-contributions-reference)、[反映されない場合](https://docs.github.com/en/account-and-profile/how-tos/contribution-settings/troubleshooting-missing-contributions)

## 動作確認結果

2026-09-16、OrbStack（Docker Server 29.4.0 / linux amd64）で確認:

- PHP 8.2.11 / PHP-FPMのビルド・起動
- `POST /api/initialize` → HTTP 200、`{"language":"php"}`
- `GET /api/tag` → HTTP 200、103件
- `GET /api/livestream/search?limit=1` → HTTP 200、1件
- `dig @127.0.0.1 -p 1053 pipe.u.isucon.dev A +short` → `127.0.0.1`
- `make stop` → `make up` 後もDBデータを保持

件数指定なしの配信検索は10秒以内に応答しなかったため、疎通確認には `?limit=1` を利用しています。性能改善とベンチマークの完走確認は今後の練習範囲です。

nginxとPowerDNSのイメージは、確認した内容を再利用できるようdigestで固定しています。Apple Siliconでの実行は未確認です。
