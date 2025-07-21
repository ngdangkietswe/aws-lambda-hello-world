.PHONY: docker-build zip deploy-bootstrap deploy-lambda deploy clean

# Step 1: Build Go binary
docker-build:
	docker build -f Dockerfile.build -t go-lambda-builder .
	docker create --name temp-build go-lambda-builder
	docker cp temp-build:/app/bootstrap ./bootstrap
	docker rm temp-build

# Step 2: Zip binary for Lambda
zip: docker-build
	zip -r main.zip bootstrap

# Step 3: Deploy IAM user & access key
deploy-bootstrap:
	cd terraform-bootstrap && terraform init && terraform apply -auto-approve

# Step 4: Deploy Lambda + API Gateway
deploy-lambda: zip
	cd terraform-lambda && terraform init && terraform apply -auto-approve

# Combine: deploy full
deploy: deploy-lambda

# Clean up build artifacts
clean:
	rm -f main main.zip
