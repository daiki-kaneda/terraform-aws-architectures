## CloudFront + S3

公開入口は CloudFront です。静的ファイルは非公開の S3 に置き、オリジンアクセスコントロールで CloudFront だけが読みます。バケットの公開ウェブサイト設定は使いません。

呼び出し側は、既定のプロバイダに加えて `aws.us_east_1` を渡します。ACM 証明書と CloudFront 用の WAF は us-east-1 に作ります。

`domain_config` のドメイン名とゾーン ID を両方書くと、証明書、CloudFront の別名、Route 53 の A と AAAA を作ります。書かないときは CloudFront のデフォルト証明書です。

`enable_waf` をfalseにすると Web ACL は作りません。入れると、共通ルール、既知の悪意ある入力、IP レピュテーションのマネージドルールを付けます。

キャッシュを切ると `CachingDisabled`、入れると `CachingOptimized` です。

S3 に無いパスは 403 になります。CloudFront はその中身を `/index.html` にし、ステータスは 200 にします。ブラウザのアドレスはそのままなので、画面が増えたとき TanStack Router は `/items/1` のようなパスを読めます。無い `.js` や `.css` も同じ応答になります。このディストリビューションに API は載せません。
