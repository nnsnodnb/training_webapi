# training_webapi

何かを新しい技術を学習したいというお気持ちがあるけど、 API 作るの面倒だしちょっと使えそうなものだけでも作っておくかと思って作った Web API です。

## 動作確認及び開発環境

- macOS Taho (26.6.1)
  - M2 Ultra
- Docker version 29.7.2
- Container 1.2.2

## 始め方

### macOS

<details>

<summary>開く</summary>

1. ダウンロード

[Releases](https://github.com/nnsnodnb/training_webapi/releases/latest) から CPU アーキテクチャを選択して、 `training-macOS-<your-arch>.zip` をダウンロード・展開する

2. データベースをマイグレーション

```shell
cd /path/to/download_dir
./Training migrate --yes
```

上記コマンドを実行してデータベースをマイグレーションします。  
この操作は、基本的には初回のみ必要です。

```shell
Migrate Command: Prepare
The following migration(s) will be prepared:
+ Training.InitialMigrations on <default>
+ Training.AddUserFieldInCommentMigrations on <default>
Would you like to continue?
y/n> yes
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
Migration successful
```

3. 立ち上げます

```shell
./Training serve --env production --hostname 0.0.0.0 --port 8080
```

上記コマンドを実行して以下のように立ち上がっていたらアプリケーションは起動しています。

```
[ NOTICE ] Server started on http://0.0.0.0:8080
```

`http://127.0.0.1:8080` でアクセス可能です。  
それではがんばりましょう！

</details>

### Docker

<details>

<summary>開く</summary>

1. Docker をインストールしてください

```shell
brew install --cask docker
```

2. 立ち上げます

```shell
docker pull ghcr.io/nnsnodnb/training_webapi:latest
docker run -d -p 8080:8080 --name training-webapi ghcr.io/nnsnodnb/training_webapi:latest
```

3. データベースをマイグレーション

```shell
docker exec -t training-webapi /app/Training migrate --yes
```

上記コマンドを実行してデータベースをマイグレーションします。  
この操作は、基本的には初回のみ必要です。

```shell
Migrate Command: Prepare
The following migration(s) will be prepared:
+ Training.InitialMigrations on <default>
+ Training.AddUserFieldInCommentMigrations on <default>
Would you like to continue?
y/n> yes
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
Migration successful
```

4. 確認

```shell
docker logs training-webapi
```

上記コマンドを実行して以下のように立ち上がっていたらアプリケーションは起動しています。

```
[ NOTICE ] Server started on http://0.0.0.0:8080
```

`http://127.0.0.1:8080` でアクセス可能です。  
それではがんばりましょう！

</details>

### container

<details>

<summary>開く</summary>

1. container をインストールしてください

https://github.com/apple/container#initial-install

2. 立ち上げます

```shell
container i pull ghcr.io/nnsnodnb/training_webapi:latest
container run -d --rm --name training-webapi ghcr.io/nnsnodnb/training_webapi:latest
```

3. データベースをマイグレーション

```shell
container exec -t training-webapi /app/Training migrate --yes
```

上記コマンドを実行してデータベースをマイグレーションします。  
この操作は、基本的には初回のみ必要です。

```shell
Migrate Command: Prepare
The following migration(s) will be prepared:
+ Training.InitialMigrations on <default>
+ Training.AddUserFieldInCommentMigrations on <default>
Would you like to continue?
y/n> yes
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
Migration successful
```

4. 確認

```shell
container logs training-webapi
```

上記コマンドを実行して以下のように立ち上がっていたらアプリケーションは起動しています。

```
[ NOTICE ] Server started on http://0.0.0.0:8080
```

コンテナの IP アドレスは以下のように確認ができます。

```shell
container ls
ID               IMAGE                                                OS     ARCH   STATE    IP               CPUS  MEMORY   STARTED
training-webapi  training_webapi:latest                               linux  arm64  running  192.168.64.9/24  4     1024 MB  2026-08-19T05:50:10Z
```

上記の例であれば `http://192.168.64.9:8080` でアクセス可能です。  
それではがんばりましょう！

</details>

## API 仕様

### ドキュメント

ユーザーがタスクを作って、それぞれのタスクに対してコメントをすることが可能です。  
またユーザーが作ったリソースについては作ったユーザーのみがアクセス可能です。

詳細なドキュメントについては、上記セクションでサーバーを起動して `http://{{ WebAPI の IPv4 アドレス }}/docs/swagger/index.html` にアクセスして確認してください。

### 認可

JWT を使用した認可を行います。

`POST /v1/users/sign-in/` に対してユーザ名とパスワードを投げるとリフレッシュトークン(`refresh`) とアクセストークン(`access`) が取得できます。

<details>
<summary>Example</summary>

```shell
curl -X POST http://127.0.0.1:8080/v1/users/sign-in/ \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{\"username\": \"sample-username\", \"password\": \"super-secret-password\"}"
```
</details>

#### 有効期限

- `refresh` : 1週間
- `access` : 1時間

アクセストークンの有効期限が切れた場合は `/v1/users/refresh/` に `refresh` をキーにリフレッシュトークンを送信してください。

### 画像リソースの配信

この Web API では画像を扱うことが可能になっています。ストレージについてはディレクトリに保存しています。  
コンテナ内の `/app/Public` に配置されています。  
また、容量制限については1回につき **15MB** としています。

- `/v1/tasks/`
- `/v1/tasks/{id}/`
- `/v1/tasks/{id}/comments/`
- `/v1/tasks/{id}/comments/{comment_id}/`

画像の ID として Web API からのレスポンスでキーが取得できます。このキーとホスト情報を組み合わせて URL を生成してください。

<details>
<summary>Example</summary>

Web API から以下のように返ってきたら

```text
/images/1B50BE9A-6D64-4F58-8287-267F873B7370/3E224D7F-9682-4156-AD53-8F77268F3C32.png
```

Web API が起動しているマシンの IP アドレスが `127.0.0.1` であるなら

```text
http://127.0.0.1:8080/images/1B50BE9A-6D64-4F58-8287-267F873B7370/3E224D7F-9682-4156-AD53-8F77268F3C32.png
```

上記のようにしてください。

</details>

## オリジン間リソース共有について

リクエスト内の Origin ヘッダーの値を許可しています。

## メンテナンスモード

下記コマンドでメンテナンスモードを切り替えることができます。

1. Docker

```shell
docker exec -t training-webapi /app/Training maintenance on  # メンテナンスモードに入る
Maintenance mode is set to on
docker exec -t training-webapi /app/Training maintenance off # メンテナンスモードから抜ける
Maintenance mode is set to off
```

2. Container

```shell
container exec -t training-webapi /app/Training maintenance on  # メンテナンスモードに入る
Maintenance mode is set to on
container exec -t training-webapi /app/Training maintenance off # メンテナンスモードから抜ける
Maintenance mode is set to off
```

任意のエンドポイントへのアクセスで以下のようなレスポンスが返ってきます。

```json
{
  "error_detail": {
    "title": "現在サービスはメンテナンス中です。",
    "body": "終了は2021年11月28日 2時00分を予定しています。"
  }
}
```

## アクセストークンの取得

デバッグ用途としてコマンドを実装しています。  
以下のコマンドを実行するとアクセストークンが取得されます。

1. Docker

```shell
docker exec -t training-webapi /app/Training access-token -u <your-user-id>
```

2. Container

```shell
container exec -t training-webapi /app/Training access-token -u <your-user-id>
```

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).
