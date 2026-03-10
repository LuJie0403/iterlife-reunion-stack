# Stack 治理检查清单

更新时间：2026-03-10

1. 目录已纳入 Git 管理（main 分支）
2. 真实密钥不入库（`.gitignore` + `env.example`）
3. 真实运行配置位于 `/apps/config/iterlife-reunion-stack/iterlife-deploy-webhook.env`
4. systemd 服务文件已备份到仓库，且 `EnvironmentFile` 指向 `/apps/config/...`
5. webhook 日志路径采用 `/apps/logs/webhook/iterlife-deploy-webhook.log`
6. 统一部署入口：`/hooks/app-deploy`
7. `DEPLOY_TARGETS_JSON` 使用对象结构：`service -> {deploy_script, image_env}`
8. 服务路由命名规范：
   - API 使用无后缀键：`iterlife-reunion`、`iterlife-expenses`
   - UI 使用 `-ui` 键：`iterlife-reunion-ui`、`iterlife-expenses-ui`
