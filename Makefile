up:
	docker-compose up -d
down:
	docker-compose down
down-all:
	docker-compose down --rmi all --volumes
create-laravel:
	docker-compose exec app composer create-project --prefer-dist laravel/laravel . 6.*
setup-laravel:
	docker-compose exec app php artisan key:generate
	docker-compose exec app php artisan storage:link
	docker-compose exec app chmod -R 777 storage bootstrap/cache
create-project:
	rm -rf ./laravel
	mkdir laravel
	docker-compose build --no-cache --force-rm
	@make up
	docker-compose exec app rm -rf *
	docker-compose exec app rm -rf .DS_Store
	@make create-laravel
	@make setup-laravel
migrate:
	docker-compose exec app php artisan migrate
migrate-fresh:
	docker-compose exec app php artisan migrate:fresh --seed
destroy:
	@make down-all
	rm -rf ./docker/mysql/data
	rm -rf ./laravel
