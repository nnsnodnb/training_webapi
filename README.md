# training_webapi

何かを新しい技術を学習したいというお気持ちがあるけど、 API 作るの面倒だしちょっと使えそうなものだけでも作っておくかと思って作った Web API です。

## 動作確認及び開発環境

- macOS Monterey (12.0.1)
  - M1 Max
- Docker version 20.10.10, build b485636
  - Docker Compose version v2.1.1

## 始め方

<details>

<summary>開く</summary>

1. Docker をインストールしてください

```shell
softwareupdate --install-rosetta  # Apple Silicon を搭載した Mac の場合のみ
brew install --cask docker
```

2. 立ち上げます

すでにこのリポジトリがローカルにクローンもしくはダウンロードされているとします。

```shell
make setup
```

しばらくするとプロンプトが現れるので

```shell
docker compose logs -f backend
```

と入力して

```text
training_backend  | 184 static files copied to '/app/staticfiles'.
training_backend  | [2021-11-23 14:51:07 +0000] [52] [INFO] Starting gunicorn 20.1.0
training_backend  | [2021-11-23 14:51:07 +0000] [52] [INFO] Listening at: unix:tmp/gunicorn.sock (52)
training_backend  | [2021-11-23 14:51:07 +0000] [52] [INFO] Using worker: gevent
training_backend  | [2021-11-23 14:51:07 +0000] [55] [INFO] Booting worker with pid: 55
```

上記のような表示が出るまで待ってください。上記のような表示が出たら control + C で抜け出して大丈夫です！

`http://127.0.0.1` でアクセス可能です。  
それではがんばりましょう！

</details>

## API 仕様

- [ドキュメント](ドキュメント)
- [認可](認可)
  - [有効期限](有効期限)
- [画像リソースの配信](画像リソースの配信)
- [オリジン間リソース共有について](オリジン間リソース共有について)
- [メンテナンスモード](メンテナンスモード)

### ドキュメント

ユーザがタスクを作って、それぞれのタスクに対してコメントをすることが可能です。  
またユーザが作ったリソースについては作ったユーザのみがアクセス可能です。

詳細なドキュメントについては、上記セクションでサーバを起動して `http://127.0.0.1/docs/swagger` にアクセスして確認してください。

### 認可

JWT を使用した認可を行います。  

`POST /v1/users/sign-in` に対してユーザ名とパスワードを投げるとリフレッシュトークン(`refresh`) とアクセストークン(`access`) が取得できます。

<details>
<summary>Example</summary>

```shell
curl -X POST http://127.0.0.1/v1/users/sign-in \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{\"username\": \"sample-username\", \"password\": \"super-secret-password\"}"
```
</details>

#### 有効期限

- `refresh` : 1週間
- `access` : 1時間

アクセストークンの有効期限が切れた場合は `/v1/users/refresh` に `refresh` をキーにリフレッシュトークンを送信してください。

### 画像リソースの配信

この Web API では画像を扱うことが可能になっています。ストレージについては AWS S3 互換の MinIO を使用しています。  
容量制限については1回につき [15MB](dockerfiles/files/default.config#L9) としています。

- `/v1/tasks`
- `/v1/tasks/{id}`
- `/v1/tasks/{id}/comments`
- `/v1/tasks/{id}/comments/{comment_id}`

画像の ID として Web API からのレスポンスでキーが取得できます。このキーとホスト情報を組み合わせて URL を生成してください。

<details>
<summary>Example</summary>

Web API から以下のように返ってきたら

```text
training-store/images/e0b92214/8b69/4281/bcf6/67a7c4e88c90/83d34abb1fb5c77c0855ccae94fca4a9d74d4129.png
```

Web API が起動しているマシンの IP アドレスが `192.168.100.32` であるなら

```text
http://192.168.100.32:9000/training-store/images/e0b92214/8b69/4281/bcf6/67a7c4e88c90/83d34abb1fb5c77c0855ccae94fca4a9d74d4129.png
```

上記のようにしてください。

</details>

### オリジン間リソース共有について

`^http(|s)://(localhost|127.0.0.1):\d+$` に一致するホストの場合、許可しています。

- `http://localhost:3000`
- `https://127.0.0.1:3000`

などが該当します。

```shell
docker compose exec backend pipenv run check_cors --url http://127.0.0.1:3000
```

で確認できます。

### メンテナンスモード

下記コマンドでメンテナンスモードを切り替えることができます。

```shell
make maintenance_on
make maintenance_off
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

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).
