# terraform-aws-architectures
TerraformでAWSの基本アーキテクチャの実装をする学習用リポジトリです

## ✅ TODO

### 01-ec2-3tier
- [ ] three-tierモジュールに以下のバリデーション追加
  - [x] CIDRブロックチェック
  - [x] AZの有効性チェック
  - [ ] prodでカスタムドメインを作れる様にする
  - [ ] prodでWAFを追加できる様にする
  - [ ] prodでCloudWatchAgentを追加して、
### 02-fargate-3tier

### 03-serverless-api

### 04-spa-frontend


### CICD
- ./terraformのキャッシュを行うアクションを作成・使用
- CIのTerraform init,fmt check,validate,plan,planをprにcommentをアクション化する(DRY)
 