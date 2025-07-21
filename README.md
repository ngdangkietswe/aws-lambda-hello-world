# AWS Lambda Go - Hello World (Serverless with HTTP API Gateway)

This project demonstrates how to build and deploy a Go-based AWS Lambda function behind an HTTP API Gateway v2
endpoint — using a **custom runtime** (`provided.al2`) and **infrastructure managed by Terraform**.

---

## Features

- Written in Go
- Uses **AWS Lambda with custom runtime** (`provided.al2`)
- Integrated with **API Gateway (HTTP API v2)**
- Uses **Terraform** to deploy Lambda, API Gateway, IAM Role, Permissions
- Supports query param `?name=...`
- Returns: `"Hello, <name>!"`

---

## Prerequisites

- [Go](https://go.dev/dl/) 1.18+
- [Docker](https://docs.docker.com/get-docker/) (for consistent Lambda build)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- An AWS account with programmatic access (`aws configure`)

---

## Project Structure

```
├── main.go             # Lambda function entry point
├── go.mod              # Go module file
├── go.sum              # Go dependencies
├── bootstrap           # Compiled binary for Lambda
├── main.zip            # Deployment package for Lambda
├── terraform-bootstrap # Terraform configuration for IAM role and permissions
├   ├── main.tf
├── terraform-lambda    # Terraform configuration for Lambda function and API Gateway
├   ├── main.tf
├   ├── variables.tf
├   ├── outputs.tf
├── Makefile            # Makefile for building and deploying
├── Dockerfile.build    # Dockerfile for building the Lambda binary
└── README.md           # Project documentation
```

## Setup Instructions (Manual Deployment)

### 1. Clone the repository

```bash
git clone https://github.com/ngdangkietswe/aws-lambda-hello-world
cd aws-lambda-hello-world
```

### 2. Build the Go Lambda binary

```bash
GOOS=linux GOARCH=amd64 go build -o bootstrap main.go
```

### 3. Create the deployment package

```bash
zip -r main.zip bootstrap
```

### 4. Create the Lambda function

```bash
aws lambda create-function \
  --function-name hello-go-lambda \
  --runtime provided.al2 \
  --role arn:aws:iam::<your-account-id>:role/<your-lambda-role> \
  --handler bootstrap \
  --zip-file fileb://main.zip
```

### 5. Create the API Gateway HTTP API

```bash
aws apigatewayv2 create-api \
  --name hello-api \
  --protocol-type HTTP \
  --target arn:aws:lambda:<your-region>:<your-account-id>:function:hello-go-lambda
```

Save the API ID and API endpoint URL from the output.

### 6. Create integration manually (optional, if not auto-linked)

```bash
aws apigatewayv2 create-integration \
  --api-id <api-id> \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:lambda:<region>:<account-id>:function:hello-go-lambda \
  --integration-method POST \
  --payload-format-version 2.0
```

### 7. Create route for the API

```bash
aws apigatewayv2 create-route \
  --api-id <api-id> \
  --route-key "GET /api/greet" \
  --target integrations/<integration-id>
```

### 8. Grant API Gateway permission to invoke the Lambda function

```bash
aws lambda add-permission \
  --function-name hello-go-lambda \
  --principal apigateway.amazonaws.com \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --source-arn arn:aws:execute-api:<region>:<account-id>:<api-id>/*/GET/api/greet
```

### 9. Deploy the API

```bash
aws apigatewayv2 create-deployment \
  --api-id <api-id> \
  --stage-name prod
```

## Using Terraform for Deployment

If you prefer to use Terraform for managing the infrastructure, follow these steps:

### 1. Deploy the IAM Role and Permissions

```bash
make deploy-bootstrap
```

### 2. Deploy the Lambda Function and API Gateway

```bash
make deploy
```

### 3. Clean up resources

To clean up the resources created by Terraform, run:

```bash
make clean
```

## Testing the API

You can test the API using `curl` or any HTTP client:

```bash
curl "https://<api-id>.execute-api.<region>.amazonaws.com/prod/api/greet?name=Kiet"
```

## Congratulations!