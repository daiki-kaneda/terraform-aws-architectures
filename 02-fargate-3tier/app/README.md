# fargate-3tier app

ECS のコンテナポート 80 向けの Hello World です。`GET /` が応答を返します。

## ローカル

Python 3.12 を使います。

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
./scripts/run.sh
pytest
```

コンテナとして確認する場合:

```bash
docker build -t fargate-3tier-app .
docker run --rm -p 8000:80 fargate-3tier-app
```

## CI/CD

- プルリクエスト: テストとイメージのビルドを行います。
- `main` への push: イメージを ECR `terraform-aws-architectures` へ `fargate-<コミットSHA>` で push し、dev の稼働中タスク定義へそのイメージだけを載せます。
- 本番: `02-fargate-3tier-app-prod CD` を手動実行すると、同じ手順で prod のサービスを更新します。

cpu と memory は Terraform が持ちます。CD はそこを書き換えません。Terraform の apply が ECS サービスを作ったあとで、この CD を実行します。
