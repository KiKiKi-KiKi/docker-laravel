# docker Laravel v.7

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

```config
$ make create-project
```

`/laravel` 内に laravel のプロジェクトを作成します。  
作成し直す場合は `/laravel` と `/docker/mysql/data/` ディレクトリ内を空にしてください。

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
$ docker-compose exec app php artisan make:migration <file name> -create=<table name>
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
$ docker-compose exec db bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE'
```

##### MySQL のデータを作成し直す

```config
$ docker-compose down --rmi all --volumes
$ rm -rf ./docker/mysql/data
$ docker-compose build
```

#### MySQLAdmin

localhost:8888

## Laravel サーバー要件

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
