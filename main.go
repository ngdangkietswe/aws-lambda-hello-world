/**
 * Author : ngdangkietswe
 * Since  : 7/20/2025
 */

package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/samber/lo"
)

func handler(_ context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	name := request.QueryStringParameters["name"]
	fmt.Println("Received request with name:", name)

	message := fmt.Sprintf("Hello, %s!", lo.Ternary(name == "", "World", name))
	fmt.Println("Response message:", message)

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       message,
	}, nil
}

func main() {
	fmt.Println("Lambda function is ready to handle requests.")
	lambda.Start(handler)
}
