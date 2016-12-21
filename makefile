

.PHONY: dev_image
dev_image:
	docker build . -t bots-dev

.PHONY: test_image
test_image:
	docker build . -t bots-test --build-arg MIX_ENV=test

.PHONY: test
test:
	kubectl create -f kubernetes/bots-test.yaml
	sleep 5
	kubectl exec -it bots-test mix test
	kubectl delete pod bots-test --now
