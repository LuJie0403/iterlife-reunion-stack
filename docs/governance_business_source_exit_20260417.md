# 业务源码退出生产机治理

最后更新：2026-04-17

本文档记录第五阶段“业务源码退出生产机治理”的目标、依赖项、实施结果与验证机制。

## 1. 治理目标

第五阶段的目标不是立刻删除服务器上的业务源码目录，而是先消除生产部署对这些目录的运行时依赖。

完成后的目标状态：

- 生产部署仅依赖控制面仓 `iterlife-stack` 名下的 compose 定义。
- 部署脚本不再要求业务仓目录作为 deploy target 必填字段。
- 业务服务运行仅依赖：
  - GHCR 镜像
  - `/apps/iterlife-stack` 控制面资产
  - `/apps/config/*` 真实配置
  - `/apps/data/*` 运行数据
  - `/apps/logs/*` 日志目录
  - `/apps/static/*` 静态资源

## 2. 治理前的依赖问题

治理前，控制面仍然直接依赖业务源码目录：

- `config/deploy-targets.json` 的 `compose_file` 与 `compose_project_directory` 指向 `/apps/iterlife-reunion*`、`/apps/iterlife-expenses*`
- Expenses API/UI 的生产 compose 中仍然保留 `build.context`
- `deploy-service-from-ghcr.sh` 与 `validate-webhook-config.sh` 仍把 `repo_dir` 视为 deploy target 必填字段

这会导致：

- 服务器上的业务源码 checkout 仍被视为生产部署依赖
- 运维侧无法明确判定哪些源码目录只是历史遗留，哪些仍不可删除
- 生产控制面与业务仓边界不清

## 3. 本阶段治理动作

### 3.1 控制面新增生产 compose 事实源

在控制面仓新增以下生产 compose 文件：

- `deploy/compose/reunion-api.yml`
- `deploy/compose/reunion-ui.yml`
- `deploy/compose/expenses-api.yml`
- `deploy/compose/expenses-ui.yml`
- `deploy/compose/idaas-api.yml`
- `deploy/compose/idaas-ui.yml`

这些文件全部位于 `/apps/iterlife-stack/deploy/compose/*`，用于承载生产运行定义。

### 3.2 deploy target 切换到控制面路径

`config/deploy-targets.json` 统一切换为：

- `compose_file -> /apps/iterlife-stack/deploy/compose/*.yml`
- `compose_project_directory -> /apps/iterlife-stack`

并补齐：

- `iterlife-idaas-api`
- `iterlife-idaas-ui`

### 3.3 去除对业务源码目录字段的显式依赖

部署脚本和校验脚本不再要求 `repo_dir`：

- `scripts/deploy-service-from-ghcr.sh`
- `scripts/validate-webhook-config.sh`

这一步的意义是让 deploy target 本身就明确表达：

- 生产部署不再依赖业务源码 checkout

### 3.4 移除生产 compose 中的源码构建依赖

Expenses API/UI 新控制面 compose 已移除：

- `build.context`
- `dockerfile` 源码构建路径

现在生产 compose 仅使用镜像、env、端口和必要 volume。

## 4. 依赖项清单与验证结果

### 4.1 deploy target 依赖

验证项：

- 所有 `compose_file`
- 所有 `compose_project_directory`

结果：

- `通过`

说明：

- 已全部切换到 `/apps/iterlife-stack`
- 不再指向 `/apps/iterlife-reunion*`、`/apps/iterlife-expenses*`、`/apps/iterlife-idaas*`

### 4.2 生产 compose 事实源

验证项：

- 控制面仓是否具备 6 个服务的独立生产 compose

结果：

- `通过`

说明：

- `deploy/compose/*.yml` 已覆盖 reunion、expenses、idaas 的 API/UI

### 4.3 源码构建依赖

验证项：

- 生产 compose 中是否仍包含 `build:`

结果：

- `通过`

说明：

- 新控制面 compose 已全部不再包含业务源码构建上下文

### 4.4 脚本字段依赖

验证项：

- `deploy-service-from-ghcr.sh`
- `validate-webhook-config.sh`

结果：

- `通过`

说明：

- `repo_dir` 已不再是必填字段
- 脚本仍能根据 `compose_file`、`compose_project_directory`、`compose_service` 完成部署逻辑

### 4.5 控制面文档一致性

验证项：

- README
- 统一运维文档

结果：

- `通过`

说明：

- 控制面 README 和运维文档已更新为“生产 compose 由 `iterlife-stack` 承载”的口径

## 5. 本阶段完成后的验证机制

### 5.1 结构验证

执行以下检查：

```bash
find deploy/compose -maxdepth 1 -type f | sort
rg -n '"/apps/iterlife-(reunion|expenses|idaas)(-ui)?' config scripts docs README.md
```

预期：

- `deploy/compose` 下存在 6 个生产 compose 文件
- 控制面事实源文件中不再出现业务源码目录作为 deploy target 运行依赖

### 5.2 配置校验

执行：

```bash
bash scripts/validate-webhook-config.sh webhook/iterlife-deploy-webhook.env.example config/deploy-targets.json
```

预期：

- 成功解析 6 个服务
- 无字段缺失

### 5.3 脚本校验

执行：

```bash
bash -n scripts/deploy-service-from-ghcr.sh
```

预期：

- shell 语法通过

### 5.4 风险边界确认

本阶段完成后，可以得出以下结论：

- 业务源码目录已不再是生产部署链路的直接依赖
- 但服务器上这些目录是否立即删除，仍需后续进行一次环境侧发布验证后再决定

## 6. 当前结论

第五阶段已经完成“解除生产部署对业务源码目录的直接依赖”这一步。

当前仍未执行、也不应在本阶段直接执行的动作：

- 删除服务器上的业务源码目录
- 改动服务器运行环境
- 手工调整生产 compose 或容器

这些动作应在后续基于标准 PR + CI/CD 的环境验证通过后，再进入最终清理。
