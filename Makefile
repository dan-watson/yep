build:
	docker-compose build
spec:
	docker-compose run ruby test/test_yep.rb
lint:
	docker-compose run ruby rubocop
sh:
	docker-compose run ruby bash
release:
