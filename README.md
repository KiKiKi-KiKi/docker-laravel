# docker Laravel v.12

- Laravel: `12.*`
- PHP: `php:8.3-fpm-bookworm`
- MySQL: `8.0`
- node.js: `20.*`

## :triangular_ruler: ディレクトリ構成

```
/
├── docker/
│    ├── mysql/
│    │    ├── Dockerfile # MySQL コンテナの設定
│    │    ├── my.cnf     # MySQL の設定
│    │    └── data/      # Database の内容
│    ├── nginx/
│    │    └── default.conf
│    └── php/
│         ├── Dockerfile # PHP コンテナの設定
│         └── php.ini
├── .env.example         # Database のユーザー情報
├── docker-compose.yml
└── laravel/             # Laravel 関連のファイル
```

## :hammer_and_pick: Setup

```config
$ cp .env.example .env
```

### :whale2: Docker Laravel の作成

```sh
# コンテナのビルド
docker compose build --no-cache --force-rm
# Laravel のインストール
docker compose run --rm app sh -c "composer create-project laravel/laravel . 12.* --prefer-dist --no-interaction"
# コンテナの起動
docker compose up -d
# Laravel マイグレーション
docker compose exec app php artisan migrate --force
# Laravel ストレージリンク
docker compose exec app php artisan storage:link
docker compose exec app chmod -R 777 storage bootstrap/cache
```

<details>
<summary>:whale2: Docker コマンド</summary>

| 操作       | コマンド                      |
| ---------- | ----------------------------- |
| 起動       | `docker compose up -d`        |
| 停止       | `docker compose stop`         |
| 停止・削除 | `docker compose down`         |
| ビルドのみ | `docker compose build app db` |

</details>

---

## :computer: Local 環境での開発

```sh
# docker コンテナの起動
docker compose up -d
```

- Laravel: `localhost:80`
- phpmyadmin: `localhost:8888`
  - user: `DB_USER`
  - password: `DB_PASSWORD`

#### :no_entry: Local 環境の停止

```sh
docker compose stop
```

---

# :zap: Laravel コマンドの実行

`php artisan` コマンドは Laravel が動作している `app` コンテナの中で実行する必要があり、下記いずれかの方法で実行してください

1. `app` コンテナを指定して実行
2. `app` コンテナに入って実行
3. Makefile の artisan コマンドを使う

### 1. `app` コンテナを指定して実行

```sh
docker compose exec app php artisan <サブコマンド>
# migrate を実行する場合は docker compose exec app php artisan migrate
```

### 2. `app` コンテナに入って実行

```sh
# app コンテナに入る
docker compose exec app bash
# コマンドの実行
php artisan <サブコマンド>
# app コンテナから出る
exit
```

### 3. Makefile の artisan コマンドを使う

```sh
make artisan CMD="<サブコマンド>"
```

---

## :broom: Docker Laravel の全削除

```sh
# Docker コンテナ・ボリューム・イメージをすべて削除
docker compose down --rmi all -v
# MySQL のデータを削除
rm -rf ./docker/mysql/data
# ログ の削除
rm -rf ./docker/mysql/log
rm -rf ./docker/nginx/log
# Laravel の削除
rm -rf ./laravel
```

## :memo: よく使うコマンド

| 目的               | コマンド                                                                                  |
| ------------------ | ----------------------------------------------------------------------------------------- |
| app コンテナに入る | `docker compose exec app bash`（bash が無い場合は `sh`）                                  |
| マイグレーション   | `docker compose exec app php artisan migrate --force`                                     |
| artisan を実行     | `docker compose exec app php artisan <サブコマンド>`（例: `migrate:status`）              |
| ストレージリンク   | `docker compose exec app php artisan storage:link`                                        |
| MySQL に接続       | `docker compose exec db sh -c 'mysql -u$$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE'` |

---

## :mouse: Makefile を使ったセットアップ (mac)

`make` が使える環境（mac など）では、以下の手順でセットアップできます。

```sh
# make コマンドの確認
make -v
```

### 1. 環境変数の準備

```sh
cp .env.example .env
```

### 2. Docker Laravel の作成（一括セットアップ）

```sh
make setup-laravel
```

このコマンドで以下をまとめて実行します。

- イメージのビルド（`make build`）
- コンテナの起動（`make up`）
- マイグレーション・ストレージリンク・権限設定

完了すると 「 SUCCESS `Access: http://localhost:80`」 が表示されます。

### 3. 利用可能な make コマンド一覧

```sh
make help
```

| 目的                                            | コマンド                            |
| ----------------------------------------------- | ----------------------------------- |
| セットアップ一括実行 (空の状態から)             | `make setup-laravel`                |
| セットアップ一括実行 (既存の /laravel から)     | `make setup`                        |
| イメージのビルド                                | `make build`                        |
| コンテナの起動                                  | `make up`                           |
| コンテナの停止・削除                            | `make down`                         |
| コンテナの停止のみ                              | `make stop`                         |
| コンテナの再起動                                | `make restart`                      |
| マイグレーション                                | `make migrate`                      |
| ストレージリンク                                | `make storage-link`                 |
| artisan を実行                                  | `make artisan CMD="<サブコマンド>"` |
| app コンテナに入る                              | `make shell`                        |
| db コンテナの MySQL 接続                        | `make db-shell`                     |
| :rotating_light: コンテナ・ボリューム等の全削除 | `make destroy`（要確認）            |

---

### :potato: Tips

#### Laravel のバージョンを変更したい

`make setup-laravel` では `Makefile` にかかれてあるコマンドを実行しています。  
Laravel のプロジェクトを作成している下記コマンド部分を変更してください。

e.g. Laravel v11 系を使いたい場合
`Makefile`

```diff
install-laravel:
- docker compose run --rm app sh -c "rm -f .gitkeep 2>/dev/null; composer create-project laravel/laravel . 12.* --prefer-dist --no-interaction"
+ docker compose run --rm app sh -c "rm -f .gitkeep 2>/dev/null; composer create-project laravel/laravel . 11.* --prefer-dist --no-interaction"
```

##### MySQL のユーザーとパスワードを変更したい

デフォルトでは下記のように設定されています。

- root user name: `root`
- root user password: `root`
- service user name: `phper`
- service user password: `secret`

これを変更したい場合は `.env` を編集してください

```config
DB_USER=<service user name>
DB_PASSWORD=<service user password>
DB_ROOT_PASSWORD=<root user password>
```

:bulb: root user name は MySQL公式イメージが `root` に固定されているので変更できない仕様としています

##### 自動的に作られるデータベース名を変更したい

`make setup-laravel` or `docker compose build` をすると自動的に `laravel_local` というデータベースが作成されますがこれを変更したい場合は下記を変更してください。

`.env` の `DB_DATABASE` を作成したいデータベース名に変更

```config
DB_DATABASE={database name}
```

上記を変更して `/laravel` ディレクトリ, `/docker/mysql/data` ディレクトリを削除の上改めて `make setup-laravel` or `docker compose build` でプロジェクトを作成し直してください  
`make destroy` で docker コンテナと上記ディレクトリをまるっと削除することもできます

---

# Laravel

## :rabbit: Model / Controller / View の作り方の例

ここでは `Task` を例に、**モデル・コントローラ・ビュー** を作る手順を 3 とおりの方法で示します。

| 作りたいもの                 | artisan コマンド例                                           |
| ---------------------------- | ------------------------------------------------------------ |
| モデル（＋マイグレーション） | `make:model Task -m`                                         |
| コントローラ（リソース）     | `make:controller TaskController --resource`                  |
| ビュー                       | コマンドなし。`resources/views/` に Blade ファイルを配置する |

### 方法 1: コンテナを指定してコマンドを実行する

- Model は**大文字から始まる単数形**で指定する

```sh
# モデル（マイグレーション付き）
docker compose exec app php artisan make:model Task -m

# コントローラ（リソース）
docker compose exec app php artisan make:controller TaskController --resource

# ビューは手動で作成（例: resources/views/tasks/index.blade.php）
# ファイルは ./laravel/resources/views/tasks/ に配置
```

### 方法 2: コンテナに入ってコマンドを実行する

```sh
# app コンテナに入る
docker compose exec app bash

# コンテナ内で実行
php artisan make:model Task -m
php artisan make:controller TaskController --resource
# ビューは resources/views/tasks/ に .blade.php ファイルを作成

exit
```

### 方法 3: Makefile の artisan を使う

```sh
make artisan CMD="make:model Task -m"
make artisan CMD="make:controller TaskController --resource"
# ビューは ./laravel/resources/views/tasks/ に Blade ファイルを追加
```

> **ビューについて**  
> Laravel には `make:view` はありません。`resources/views/` 配下（例: `tasks/index.blade.php`）に Blade ファイルを手動で作成してください。

## :dragon: Database migration

テーブル名は **複数形** で指定する

```sh
$ docker compose exec app php artisan make:migration <file name> --create=<table name>
```

#### app コンテナに入って実行する

```sh
$ docker compose exec app bash
> php artisan make:migration <file name> --create=<table name>
```

### migration の実行

#### 方法 1: コンテナを指定してコマンドを実行する

```sh
$ docker compose exec app php artisan migrate
```

#### 方法 2: コンテナに入ってコマンドを実行する

```sh
$ docker compose exec app bash
> php artisan migrate
```

#### 方法 3: Makefile のコマンドを使う

```sh
$ make migrate
```

---

### app (PHP)

app コンテナに入る

```config
$ docker compose exec app bash
```

### Mysql

db コンテナ内の MySQL に接続

```config
$ docker compose exec db bash -c 'mysql -u $MYSQL_USER -p $MYSQL_PASSWORD $MYSQL_DATABASE'
```

##### MySQL のデータを作成し直す

```config
$ docker compose down --rmi all --volumes
$ rm -rf ./docker/mysql/data
$ docker compose build
```

#### MySQLAdmin

access: `localhost:8888`

---

## Laravel v12 サーバ要件

https://readouble.com/laravel/12.x/ja/deployment.html#server-requirements

- PHP8.2以上
- Ctype PHP拡張
- cURL PHP拡張
- DOM PHP拡張
- Fileinfo PHP拡張
- Filter PHP拡張
- Hash PHP拡張
- Mbstring PHP拡張
- OpenSSL PHP拡張
- PCRE PHP拡張
- PDO PHP拡張
- Session PHP拡張
- Tokenizer PHP拡張
- XML PHP拡張
