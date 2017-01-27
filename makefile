

.PHONY: config
config:
	confd -onetime -backend env -confdir kubernetes

.PHONY: image
image:
	docker build . -t cedricgc/bots:$(shell git rev-parse HEAD)

.PHONY: dev_image
dev-image:
	docker build . -t bots-dev

.PHONY: test_image
test-image:
	docker build . -t bots-test --build-arg MIX_ENV=test

.PHONY: test
test:
	kubectl create -f kubernetes/generated/bots-test.yaml
	sleep 5
	kubectl exec -it bots-test mix test
	kubectl delete pod bots-test --now
