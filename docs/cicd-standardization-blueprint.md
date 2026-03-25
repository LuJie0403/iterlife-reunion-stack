# IterLife CI/CD 标准化落地蓝图

最后更新：2026-03-25

本文档描述已经落地的标准 CI/CD 结构，作为后续新增应用和持续治理的直接依据。

## 1. 目标状态

### 1.1 唯一生产发布流程

生产发布只允许：

1. 本地分支开发
2. 推送远端分支
3. 发起向 `main` 的 PR
4. 人工 review / 审批
5. merge 到 `main`
6. GitHub Actions 构建并推送 GHCR
7. GitHub Actions 回调统一 webhook
8. webhook 按 `service` 路由统一部署执行器
9. 统一部署执行器完成镜像部署与健康检查

### 1.2 仓库角色

- `iterlife-reunion-stack`: 唯一 CI/CD 控制面仓库
- `iterlife-reunion-api`, `iterlife-reunion-ui`, `iterlife-expenses-api`, `iterlife-expenses-ui`: 可部署单元仓库

### 1.3 命名规则

- API service key：`-api`
- UI service key：`-ui`
- webhook `service`、GHCR image name、compose service、部署注册表 key 必须一致

## 2. 当前问题清单

### 2.1 已完成的收口结果

- 生产源码部署链路已经从业务仓库清理
- `iterlife-reunion-stack` 不再保留跨应用源码部署入口
- release workflow 不再保留 `workflow_dispatch`

### 2.2 已完成的资产归属统一

- 控制面逻辑集中在 `iterlife-reunion-stack`
- 业务仓库不再保留生产部署 shell
- UI 仓库不再依赖后端仓库代管 UI 部署脚本

### 2.3 已完成的命名统一

- API service key 统一为 `*-api`
- UI service key 统一为 `*-ui`
- webhook 已不再保留 `*-api` / 无后缀兼容映射

### 2.4 已完成的文档收口

- 统一手册收敛到 `iterlife-reunion-stack/docs`
- 业务仓库只保留差异化说明
- 历史兼容脚本和重复手册已清理

## 3. 标准化设计

### 3.1 控制面标准目录

`iterlife-reunion-stack` 最终建议保留：

```text
docs/
  deployment-manual-unified-cicd-ghcr-webhook-aliyun.md
  cicd-standardization-blueprint.md
config/
  deploy-targets.json
scripts/
  deploy-service-from-ghcr.sh
  validate-webhook-config.sh
webhook/
  iterlife-deploy-webhook-server.py
  iterlife-deploy-webhook.env.example
systemd/
  iterlife-app-deploy-webhook.service
  iterlife-app-deploy-webhook.service.d/
.github/workflows/
  reusable-release-ghcr-webhook.yml
```

### 3.2 业务仓库标准目录

每个业务仓库最终建议保留：

```text
.github/workflows/
  <app>-pr-ci.yml
  <app>-release.yml
deploy/compose/
  <service>.yml
Dockerfile
README.md
```

只保留应用自身必要差异，不再保留跨应用控制逻辑。

## 4. 删除与迁移清单

### 4.1 `iterlife-reunion-stack`

已删除：
- `scripts/deploy-all-apps-from-github.sh`

已新增：
- `config/deploy-targets.json`
- `scripts/deploy-service-from-ghcr.sh`
- `reusable-release-ghcr-webhook.yml`

已改造：
- `webhook/iterlife-deploy-webhook-server.py`
  - 删除 API 无后缀兼容映射
  - 从注册表文件读取部署目标
  - 不再依赖超长环境变量路由表
- `webhook/iterlife-deploy-webhook.env.example`
  - 删除内联路由注册信息
  - 只保留私密和环境参数

### 4.2 `iterlife-reunion`

已保留：
- `deploy/compose/reunion-api.yml`

已删除：
- `deploy/scripts/deploy-reunion-from-ghcr.sh`
- 旧 webhook/systemd 示例

已调整：
- release workflow 使用标准 `service=iterlife-reunion-api`

### 4.3 `iterlife-reunion-ui`

已保留：
- UI compose 文件
- UI release / PR CI

已删除：
- `deploy/scripts/deploy-reunion-ui-from-ghcr.sh`

已调整：
- release workflow 迁到统一 reusable workflow
- 只保留本应用差异说明

### 4.4 `iterlife-expenses`

已保留：
- API compose 文件

已删除：
- `deploy-expenses-from-github.sh`
- `deploy-expenses-stack.sh`
- `deploy-expenses-api-from-ghcr.sh`
- `deploy-expenses-ui-from-ghcr.sh`
- `deploy/docker-compose.example.yml`
- `deploy-expenses-from-ghcr.sh`

已迁移：
- 任何仍指向源码部署的文档说明

### 4.5 `iterlife-expenses-ui`

已保留：
- UI compose 文件
- UI release / PR CI

已迁移：
- UI 部署入口已从“后端仓库代管”转为控制面统一执行器驱动

## 5. 长期维护规则

- 新应用必须先在控制面注册 `service`
- 业务仓库的 release workflow 只能是统一模板的 wrapper
- 不得在业务仓库重新引入生产部署 shell
- 不得重新引入 `workflow_dispatch` 作为生产发布入口
- 不得恢复 API 无后缀 service key

## 6. 新增应用接入模板

新增应用时只允许补这些差异项：

### 6.1 业务仓库侧

- `Dockerfile`
- `deploy/compose/<service>.yml`
- `PR CI`
- `release wrapper workflow`

### 6.2 控制面侧

在 `config/deploy-targets.json` 新增：
- `service`
- `compose_file`
- `compose_project_directory`
- `compose_service`
- `release_image_env`
- `local_image_env`
- `local_image_name`
- `healthcheck_url`

### 6.3 服务器侧

新增：
- `/apps/<repo>`
- `/apps/config/<app>/...`
- 运行时 env / runtime config

不允许新增新的 webhook 服务、新的 systemd 服务定义模式、或新的生产发布路线。

## 7. 验收清单

每一阶段完成后都应验证：

- `main` 无直接 push 发布
- release workflow 无 `workflow_dispatch`
- webhook 仅接受标准 `service`
- 部署日志包含 `service`, `image_ref`, `commit_sha`
- 所有生产部署均为 `docker compose up -d --no-build`
- 仓库内不再存在源码部署生产入口

## 8. 完成后的长期收益

- 发布路径唯一，便于审计
- 新增应用接入成本低
- 控制面统一演进，不必四处修 workflow
- 文档、脚本、路由和命名保持一致
- 删除历史兼容逻辑后，故障面更小、结构更规整
