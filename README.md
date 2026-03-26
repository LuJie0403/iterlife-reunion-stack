# iterlife-reunion-stack

IterLife 控制面与共享前端资产仓。

## 当前职责

- 统一 webhook 部署控制面。
- 部署目标注册表与通用部署脚本。
- webhook 的 systemd 运行资产。
- 跨前端共享主题包 `@iterlife/theme-dark-universe`。
- 仓库级治理、运维和 secrets 文档。

## 当前目录

```text
.github/workflows/    GitHub Actions 工作流
config/               部署目标注册表
docs/                 治理、运维与共享包文档
packages/themes/      前端共享主题包
scripts/              通用部署与校验脚本
systemd/              webhook 服务 unit 与 drop-in
webhook/              webhook 服务源码与示例 env
```

## 文档入口

- [docs/README.md](./docs/README.md)
- [docs/directory-governance.md](./docs/directory-governance.md)
- [docs/deployment-operations.md](./docs/deployment-operations.md)
- [docs/frontend-theme-package.md](./docs/frontend-theme-package.md)
- [docs/github-actions-secrets.md](./docs/github-actions-secrets.md)

## 运行约束

- 真实配置文件 `/apps/config/iterlife-reunion-stack/iterlife-deploy-webhook.env` 不入库。
- 仓库只保留 `webhook/iterlife-deploy-webhook.env.example`。
- 仓库内不存放任何真实 token、secret 或 password。

## 常用校验

```bash
bash scripts/validate-webhook-config.sh webhook/iterlife-deploy-webhook.env.example
cd packages/themes/dark-universe && npm run build
```
