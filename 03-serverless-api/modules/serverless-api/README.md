## CloudFront + HTTP API + Lambda + DynamoDB

公開入口は CloudFront です。パスとメソッドは OpenAPI 仕様書で定義し、Terraform は `__LAMBDA_ARN__` だけを関数の ARN に置き換えます。Lambda は1つです。

統合 URI の例です。`httpMethod` は、クライアントのメソッドではなく、API Gateway が Lambda を呼ぶときの POST です。

```yaml
x-amazon-apigateway-integration:
  payloadFormatVersion: "2.0"
  type: aws_proxy
  httpMethod: POST
  uri: arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/__LAMBDA_ARN__/invocations
```

`handler_file` に `app/handler.py` を渡すと、Lambda の handler は `app.handler.lambda_handler` になります。初回の zip はこのパスに合わせたプレースホルダです。`ignore_source_code_hash` により、作成後のコードは CD が S3 経由で更新します。

キャッシュを切ると CloudFront はマネージドポリシー `CachingDisabled` を使います。入れると、クエリ文字列をキャッシュキーにしたポリシーを使い、キャッシュされるのは GET と HEAD だけです。
