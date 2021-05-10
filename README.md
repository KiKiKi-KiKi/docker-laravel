# docker Laravel v.8

- PHP: `php:8.0-fpm-buster`
- MySQL: `8.0`
- node.js: `14.*`
- Laravel: `8.*`

構成
```
/-- docker-compose.yaml
 |- /docker
 |    |- /php
 |    |   |- Dockerfile
 |    |   |- php.ini
 |    |- /nginx
 |    |   |- default.conf
 |    |- /mysql
 |        |- Dockerfile
 |        |- my.conf
 |        |- /data
 |- /laravel # laravel アプリがインストールされるディレクトリ
```

## SETUP

```config
$ cp .env.sample .env
```

#### Create new Laravel project

[mac]
```config
$ make create-project
```

[Windows]
```sh
$ mkdir laravel
$ docker-compose build --no-cache --force-rm
$ docker-compose up -d
$ docker-compose exec app composer create-project --prefer-dist laravel/laravel . 8.*
$ docker-compose exec app php artisan key:generate
$ docker-compose exec app php artisan storage:link
$ docker-compose exec app chmod -R 777 storage bootstrap/cache
```

`/laravel` 内に laravel のプロジェクトを作成されます  
作成し直す場合は `/laravel` と `/docker/mysql/data/` ディレクトリ内を空にしてください。  

MAC の場合下記コマンドで初期化が可能です

[mac]
```sh
$ make destroy
```

#### Start server

```config
$ docker-compose up -d
```
access: `localhost:80`

#### Stop server

```config
$ docker-compose stop
```

### Tips

#### Laravel のバージョンを変更したい

`make create-project` では `Makefile` にかかれてあるコマンドを実行しています。  
Laravel のプロジェクトを作成している下記コマンド部分を変更してください。

e.g. Laravel v6 系を使いたい場合
`Makefile`
```diff
create-laravel:
- docker-compose exec app composer create-project --prefer-dist laravel/laravel . 8.*
+ docker-compose exec app composer create-project --prefer-dist laravel/laravel . 6.*
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
DB_ROOT_USER=<root user name>
DB_ROOT_PASSWORD=<root user passdord>
```

##### 自動的に作られるデータベース名を変更したい

`make create-project` or `docker-compose build` をすると自動的に `laravel_local` というデータベースが作成されますがこれを変更したい場合は下記を変更してください。

1. `.env` の `DB_DATABASE` を作成したいデータベース名に変更  
  ```config
  DB_DATABASE={datanase name}
  ```
1. `/docker/mysql//init/1_dd.sql` 内のSQL を上記の `.env` で指定したデータベース名に変更  
  ```sql
  CREATE DATABASE IF NOT EXISTS {datanase name};
  ```

上記を変更して `/laravel` ディレクトリ, `/docker/mysql/data` ディレクトリを削除の上改めて `make create-project` or `docker-compose build` でプロジェクトを作成し直してください。  
`make destroy` で docker コンテナと上記ディレクトリをまるっと削除することも出来ます。

---

# Laravel

## Database migration

テーブル名は **複数形** で指定する

```config
$ docker-compose exec app php artisan make:migration <file name> --create=<table name>
```

##### app コンテナに入って実行する

```config
$ docker-compose exec app bash
> php artisan make:migration <file name> --create=<table name>
```

`/database/migrations` ディレクトリ内に migrate ファイルが作成されるので、テーブルのカラムを設定する

### migration の実行

##### make コマンドを使う

```config
$ make migrate
```

##### docker 経由で実行

```config
$ docker-compose exec app php artisan migrate
```

##### app コンテナに入って実行する

```config
$ docker-compose exec app bash
> php artisan migrate
```

## Model

Model は**大文字から始まる単数形**で指定する

```config
$ docker-compose exec app php artisan make:model <model name>
```

##### app コンテナに入って実行する

```config
$ docker-compose exec app bash
> php artisan make:model <model name>
```

## Controller

```config
$ docker-compose exec app php artisan make:controller <controller name>
```

---

### app (PHP)

app コンテナに入る
```config
$ docker-compose exec app bash
```

### Mysql

db コンテナ内の MySQL に接続
```config
$ docker-compose exec db bash -c 'mysql -u $MYSQL_USER -p $MYSQL_PASSWORD $MYSQL_DATABASE'
```

##### MySQL のデータを作成し直す

```config
$ docker-compose down --rmi all --volumes
$ rm -rf ./docker/mysql/data
$ docker-compose build
```

#### MySQLAdmin

access: `localhost:8888`

--- 

## Laravel v8 サーバ要件

https://readouble.com/laravel/8.x/ja/deployment.html#server-requirements

- PHP7.3以上
- BCMath PHP 拡張
- Ctype PHP 拡張
- Fileinfo PHP 拡張
- JSON PHP 拡張
- Mbstring PHP 拡張
- OpenSSL PHP 拡張
- PDO PHP 拡張
- Tokenizer PHP 拡張
- XML PHP 拡張


## Laravel v7 サーバー要件

https://readouble.com/laravel/7.x/ja/installation.html#server-requirements

- PHP >= 7.2.5
- BCMath PHP拡張
- Ctype PHP拡張
- Fileinfo PHP extension
- JSON PHP拡張
- Mbstring PHP拡張
- OpenSSL PHP拡張
- PDO PHP拡張
- Tokenizer PHP拡張
- XML PHP拡張
