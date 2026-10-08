## ALB + ECS Fargate + RDSの三層アーキテクチャのモジュール

タスク定義の初期イメージは `public.ecr.aws/docker/library/httpd:2.4` です。cpu と memory は Terraform が持ちます。`ignore_task_definition_changes` により、作成後のタスク定義はアプリCDが更新します。

