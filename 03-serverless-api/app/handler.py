# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
def lambda_handler(event, context):
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": '{ "message": "Hello from Lambda!" }',
        "headers": {"content-type": "application/json"},
    }
