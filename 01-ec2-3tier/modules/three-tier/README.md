## ALB + EC2 + RDSの三層アーキテクチャのモジュール

起動テンプレートの AMI は SSM パラメータ `/${project_name}/app-ami` を参照します。初期値は Amazon Linux 2023 です。アプリの配置は Packer が AMI を焼き、CD がこのパラメータを上書きしてから instance refresh します。パラメータの値は apply で戻しません。

