# Stack 治理检查清单

更新时间：2026-03-10

1. 目录已纳入 Git 管理（main 分支）
2. 真实密钥不入库（`.gitignore` + `env.example`）
3. systemd 服务文件已备份到仓库
4. webhook 日志路径采用 `/apps/logs/webhook/iterlife-deploy-webhook.log`
5. 统一部署入口：`/hooks/app-deploy`
