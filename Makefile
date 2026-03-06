.PHONY: help build up down stop restart migrate artisan shell storage-link install-laravel destroy

help:
	@echo "Docker Laravel ローカル開発"
	@echo ""
	@echo "セットアップ・起動:"
	@echo "  make build         - app, db イメージをビルド"
	@echo "  make up            - コンテナをバックグラウンドで起動"
	@echo "  make down          - コンテナを停止・削除（ボリュームは残す）"
	@echo "  make stop          - コンテナを停止のみ"
	@echo "  make restart       - コンテナを再起動"
	@echo ""
	@echo "Laravel:"
	@echo "  make setup         - Docker Laravel のセットアップ (/laravel が存在する場合)"	
	@echo "  make setup-laravel - Docker Laravel の新規作成（要確認）"
	@echo "  make migrate       - php artisan migrate を実行"
	@echo "  make storage-link  - php artisan storage:link を実行"
	@echo "  make artisan CMD=\"...\" - php artisan を実行（例: make artisan CMD=\"migrate:status\"）"
	@echo ""
	@echo "シェル・その他:"
	@echo "  make shell         - app コンテナに bash で入る"
	@echo "  make db-shell      - db コンテナの MySQL に接続"
	@echo "  make destroy       - コンテナ・ボリューム・app を削除（要確認）"


# イメージビルド
build:
	docker compose build --no-cache --force-rm app db

# 起動
up:
	docker compose up -d

# 停止・削除（ボリュームは残す）
down:
	docker compose down

# 停止のみ
stop:
	docker compose stop

# Docker コンテナの 再起動
restart: stop up


# マイグレーション
migrate:
	docker compose exec app php artisan migrate --force

# ストレージリンク
storage-link:
	docker compose exec app php artisan storage:link
	docker compose exec app chmod -R 777 storage bootstrap/cache

# Docker Laravel のセットアップ
setup:
	@make build
	@make up
	@if [ ! -f ./laravel/.env ]; then cp ./laravel/.env.example ./laravel/.env; fi
	@docker compose exec app php artisan key:generate --force
	@make migrate
	@make storage-link
	@echo "\033[42m\033[30m SUCCESS \033[0m"
	@echo "Access: http://localhost:80"

# artisan コマンド（例: make artisan CMD="migrate:status"）
artisan:
	docker compose exec app php artisan $(CMD)

# app コンテナにシェルで入る
shell:
	docker compose exec app bash

# MySQL に接続（コンテナの MYSQL_* を使用）
db-shell:
	docker compose exec db sh -c 'mysql -u$$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE'

# Laravel を /app に新規インストール（空の app で初回のみ）
install-laravel:
	docker compose run --rm app sh -c "rm -f .gitkeep 2>/dev/null; composer create-project laravel/laravel . 12.* --prefer-dist --no-interaction"	

# Docker Laravel の新規作成
setup-laravel:
	@bash -c 'if [ -d ./laravel ]; then echo "既に ./laravel ディレクトリが存在します。削除して続行します。"; read -p "続行しますか? [y/N] " ans; [[ "$$ans" =~ ^[yY]$$ ]] || (echo "中止しました"; exit 1); fi'
	rm -rf ./laravel
	@make build
	@make up
	@make install-laravel
	@make migrate
	@make storage-link
	@echo "\033[42m\033[30m SUCCESS \033[0m"
	@echo "Access: http://localhost:80"

# コンテナ・ボリューム・app を削除（Laravel 再作成時に使用）
destroy:
	@echo "以下を削除します: コンテナ、ボリューム、/laravel ディレクトリ、Database"
	@bash -c 'read -p "続行しますか? [y/N] " ans; [[ "$$ans" =~ ^[yY]$$ ]] || (echo "中止しました"; exit 1)'
	docker compose down --rmi all -v
	rm -rf ./docker/mysql/data
	rm -rf ./docker/mysql/log
	rm -rf ./docker/nginx/log
	rm -rf ./laravel
	@echo "laravel/ を空にしました。make build && make setup-laravel で Laravel を再インストールできます。"
