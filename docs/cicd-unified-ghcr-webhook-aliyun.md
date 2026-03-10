# IterLife 统一 CI/CD 方案（GHCR + Webhook + 阿里云）

最后更新：2026-03-10  
适用范围：
- iterlife-reunion（backend）
- iterlife-reunion-ui（frontend）
- iterlife-expenses（backend）
- iterlife-expenses-ui（frontend）
- 以及后续新增子应用

## 1. 统一目标流程

1. 本地分支开发并提交
2. Push 分支到 GitHub
3. 发起 PR 并审核
4. PR 合并到 `main`
5. GitHub Actions 构建镜像并推送 GHCR 私有仓库
6. GitHub Actions 回调统一 Webhook 接口
7. 阿里云按 `service` 参数路由到目标部署脚本
8. 服务器执行 `docker compose up -d --no-build`（不在生产机本地构建）
9. 健康检查与域名回归

## 2. 架构原则

1. 镜像私有存储：GHCR Private Packages
2. 配置与代码隔离：生产真实配置仅存于 `/apps/config/...`
3. 单接口复用：同一个 webhook 路径支持多服务路由
4. 安全校验：HMAC-SHA256 验签 + 服务白名单
5. 部署最小化：生产机只拉镜像和重启容器，不做 Maven/NPM 构建

## 3. 统一 Webhook 协议

回调 payload 约定：

```json
{
  "service": "iterlife-reunion",
  "environment": "production",
  "repository": "LuJie0403/iterlife-reunion",
  "commit_sha": "<git-sha>",
  "image_ref": "ghcr.io/<owner>/<image>:sha-<git-sha>",
  "image_digest": "sha256:<digest>"
}
```

字段说明：
- `service`：必填，路由关键字段
- `image_ref`：必填，部署镜像
- 其他字段：用于审计追踪

## 4. 路由命名规范与配置

标准命名（推荐）：
- API 服务：无后缀键（`iterlife-reunion`、`iterlife-expenses`）
- UI 服务：`-ui` 键（`iterlife-reunion-ui`、`iterlife-expenses-ui`）

兼容规则：
- 回调传 `*-api` 时，服务端可自动回退到无后缀键
- 建议新流程统一按“无后缀 API 键”发送

生产配置文件位置：
- `/apps/config/iterlife-reunion-stack/iterlife-deploy-webhook.env`

`DEPLOY_TARGETS_JSON` 示例（对象结构）：

```env
DEPLOY_TARGETS_JSON={"iterlife-reunion":{"deploy_script":"/apps/iterlife-reunion/deploy-reunion-from-ghcr.sh","image_env":"API_IMAGE_REF"},"iterlife-reunion-ui":{"deploy_script":"/apps/iterlife-reunion/deploy-reunion-ui-from-ghcr.sh","image_env":"UI_IMAGE_REF"},"iterlife-expenses":{"deploy_script":"/apps/iterlife-expenses/deploy-expenses-api-from-ghcr.sh","image_env":"API_IMAGE_REF"},"iterlife-expenses-ui":{"deploy_script":"/apps/iterlife-expenses/deploy-expenses-ui-from-ghcr.sh","image_env":"UI_IMAGE_REF"}}
```

说明：
- `service` 必须命中白名单，否则返回 `400`
- 每个目标脚本负责该应用的镜像部署和健康检查

## 5. GitHub Actions 标准职责

每个子应用仓库遵循相同职责拆分：

1. `PR CI`：对 PR 到 `main` 做测试/构建校验，不触发生产部署
2. `Release Deploy`：仅在 `main` push（即 PR 合并后）触发
   - 构建镜像并 push GHCR
   - 计算签名并回调阿里云统一 webhook

## 6. 安全边界

1. GitHub Secrets 仅存：Webhook URL/Secret、构建所需令牌
2. 阿里云本地配置存：GHCR 只读令牌、业务配置、路由映射
3. Nginx 仅开放 HTTPS webhook 入口，webhook 进程监听 `127.0.0.1`
4. 禁止通过 IP:Port 直接暴露 webhook

## 7. 验证清单（上线一次性打通）

1. PR 合并后，确认对应 `Release Deploy` workflow 执行成功
2. webhook 日志出现对应 `service` 成功记录
3. `docker ps` 显示目标服务已切换到新镜像
4. 健康检查通过
5. 域名访问回归通过

## 8. 配置变更校验

路由配置改动后建议执行：

```bash
bash scripts/validate-webhook-config.sh webhook/iterlife-deploy-webhook.env.example
```

## 9. 子应用引用规范

各子应用仓库不再复制完整 CI/CD 细节，仅保留“引用文档”并链接本文件。

建议子应用文档模板：

```md
本应用 CI/CD 统一规范见：
- ../../iterlife-reunion-stack/docs/cicd-unified-ghcr-webhook-aliyun.md

本应用特有差异：
- 镜像名：...
- service 路由键：...
- 健康检查地址：...
```
