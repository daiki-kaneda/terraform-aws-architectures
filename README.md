# terraform-aws-architectures

Terraform で AWS の定番構成を作り、Github ActionsによるCICDワークフローを取り入れる学習用リポジトリ.

## Terraformプロジェクト一覧

### `global/`

- Github Actions用のIAMロール。Plan用(ReadOnly + stateロックファイルを書き込む権限のみ)とApply用(AdministratorAccess)。
- リモートバックエンド用のS3バケット(各プロジェクトでステートファイルのkeyだけかえて使用する。)
- 各プロジェクトで使いまわせるECRリポジトリ

### `01-ec2-3tier/`
- dev/,prod/で二つのTerraformプロジェクトで環境を分ける（共通モジュールを実装して共有する）
- ALB+EC2+RDSの定番構成
- アプリケーションはHello Worldを返すシンプルなFast API
- アプリケーションのCDはTerraformと独立させている。具体的には以下のステップ
  - Packerを使って、AMIをBuild
  - BuildしたAMIのIDをsystem manager parameter storeに書き込む(それぞれ、dev,prod用があり、Terraformで管理される。ASGの起動テンプレートは```resolve:ssm:xxx```でその値を読み取る。)
  - ASGをAWS CLIを使って、instance refreshさせる。

### `02-fargate-3tier/`
- dev/,prod/で二つのTerraformプロジェクトで環境を分ける（共通モジュールを実装して共有する）
- ALB+Fargate+RDSの定番構成
- アプリケーションはHello Worldを返すシンプルなFast API
- アプリケーションのCDはTerraformと独立させている。具体的には以下のステップ
  - コンテナイメージをビルド、commitのshaをつけたURIを作成
  - ECRにイメージをプッシュ
  - AWS CLIですでにECSサービスで動いているタスク定義をダウンロード
  - awsのGithub Actionでそのタスク定義を上のimage uriでimageの部分だけ書き換え（初回Terraform deployで設定されているcpu,memoryは固定）
  - awsのGithub Actionで、タスク定義をデプロイ

### `03-serverless-api/`
以下を追加予定
WIP

- dev/,prod/で二つのTerraformプロジェクトで環境を分ける（共通モジュールを実装して共有する）
- API Gateway + Lambda + DynamoDBの定番構成
- アプリケーションの CDはTerraformと独立させて、以下を行う
  - ラムダファイルを依存関係を含めてzip化
  - S3(Terraform管理)にアップロード
  - AWS CLIでラムダを置き換え(Terraformでの初めのLambdaではコードのハッシュをignore_changesに加える!)

### `04-spa-frontend/`
以下を追加予定
WIP

- CloudFront+S3の定番構成
- S3で配信する静的ウェブサイトでは03のAPIを使用する(?)
- フロントエンドのTerraformから独立させたCDは以下の様にする
  - aws s3 syncで配信用S３を上書き
  - CloudFrontのキャッシュをinvalidate
