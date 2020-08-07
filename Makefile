up:
	docker-compose up -d
down:
	docker-compose down --rmi all --volumes
create-project:
	mkdir laravel
	docker-compose build --no-cache --force-rm
	@make up
	docker-compose exec app rm -rf *
	docker-compose exec app rm -rf .DS_Store
	docker-compose exec app composer create-project --prefer-dist laravel/laravel .
	docker-compose exec app chmod -R 777 storage bootstrap/cache
migrate:
	docker-compose exec app php artisan migrate
migrate-fresh:
	docker-compose exec app php artisan migrate:fresh --seed
