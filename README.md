# iterlife-reunion-stack

IterLife 公共部署栈目录（阿里云单机）。

包含内容：
- `webhook/iterlife-deploy-webhook-server.py`：统一部署回调服务
- `docker-compose.yml`：基础编排文件（保留）
- `systemd/`：systemd 服务与 drop-in 备份
- `docs/`：运维说明

安全约束：
- 真实配置文件 `webhook/iterlife-deploy-webhook.env` 不入库
- 仅提交 `webhook/iterlife-deploy-webhook.env.example`

恢复流程（简版）：
1. 拉取仓库到 `/apps/iterlife-reunion-stack`
2. 用 `webhook/iterlife-deploy-webhook.env.example` 生成真实 `.env`
3. 将 `systemd/iterlife-app-deploy-webhook.service*` 同步到 `/etc/systemd/system/`
4. `sudo systemctl daemon-reload && sudo systemctl enable --now iterlife-app-deploy-webhook.service`
