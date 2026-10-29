from app.handler import lambda_handler


def test_lambda_handler_returns_hello() -> None:
    response = lambda_handler({}, None)

    assert response["statusCode"] == 200
    assert response["headers"]["content-type"] == "application/json"
    assert response["body"] == '{ "message": "Hello from Lambda!" }'
