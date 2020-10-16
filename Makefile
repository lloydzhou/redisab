all: init-redis

build:
	docker build -t ab -f docker/Dockerfile docker
	docker build -t ab-crontab -f docker/Dockerfile.crontab docker

build-js:
	yarn install && yarn run build

start: build build-js
	docker-compose up -d

init-redis: start
	docker-compose exec redis redis-cli script load "$$(cat lua/redis-aggregate.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/add-layer.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/add-test.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/add-target.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/layer-weight.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/test-weight.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/get-var.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/track.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/traffic.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/rate.lua)"
	docker-compose exec redis redis-cli script load "$$(cat lua/remove-test.lua)"


