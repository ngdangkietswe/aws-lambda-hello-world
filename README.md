# AWS Lambda Go - Hello World (Serverless with HTTP API Gateway)

This project demonstrates how to build and deploy a Go-based AWS Lambda function behind an HTTP API Gateway v2 endpoint.

---

## 🚀 Features

- Written in Go
- AWS Lambda using custom runtime (`provided.al2`)
- Integrated with API Gateway (HTTP API v2)
- Supports query param `?name=...`
- Returns: `"Hello, <name>!"`

---

## 🛠️ Prerequisites

- AWS CLI v2
- Go 1.18+
- An AWS account with programmatic access
- IAM role for Lambda with basic execution permissions

---

## 📦 Project Structure

```
├── main.go          # Lambda function entry point
├── go.mod           # Go module file
├── go.sum           # Go dependencies
├── bootstrap        # Compiled binary for Lambda
├── function.zip     # Deployment package for Lambda
└── README.md        # Project documentation
```

## 📝 Setup Instructions

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
zip function.zip bootstrap
```

### 4. Create the Lambda function
```bash
aws lambda create-function \
  --function-name hello-go-lambda \
  --runtime provided.al2 \
  --role arn:aws:iam::<your-account-id>:role/<your-lambda-role> \
  --handler bootstrap \
  --zip-file fileb://function.zip
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

## 🔗 Testing the API
You can test the API using `curl` or any HTTP client:

```bash
curl "https://<api-id>.execute-api.<region>.amazonaws.com/prod/api/greet?name=Kiet"
```

## 🎉 Congratulations!