

.PHONY: build_dev
build_dev:
	docker build . -t bots-dev

.PHONY: build_test
build_test:
	docker build . -t bots-test --build-arg MIX_ENV=test

.PHONY: test
test:
	kubectl create -f kubernetes/test.yaml
	sleep 5
	kubectl exec -it bots-test mix test
	kubectl delete pod bots-test --now
