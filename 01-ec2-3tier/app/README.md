# ec2-3tier app

ALB のターゲットグループ（ポート 80）向けの Hello World です。`GET /` が応答を返します。

## ローカル

Python 3.12 を使います。

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
./scripts/run.sh
pytest
```

`http://127.0.0.1:8000/` で確認できます。AMI の中では systemd がポート 80 で起動します。

## CI/CD

- プルリクエスト: テストと `packer validate` を実行します。
- `main` への push: Packer で AMI を焼き、`/ec2-3tier-dev/app-ami` を更新してから dev の Auto Scaling グループを instance refresh します。
- 本番: `01-ec2-3tier-app-prod CD` を手動実行すると、同じ GitSha の AMI を `/ec2-3tier-prod/app-ami` に載せて refresh します。

デフォルト VPC がないアカウントでは、ビルド用のパブリックサブネット ID を GitHub 変数 `PACKER_SUBNET_ID` に設定します。Terraform の apply が SSM パラメータと Auto Scaling グループを作ったあとで、この CD を実行します。
