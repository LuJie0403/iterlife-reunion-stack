# 仓库文档索引

最后更新：2026-03-26

`/docs` 只承载当前仍然有效的治理规则、运维基线和共享资产说明，不记录已经下线的迁移过程，也不重复业务仓库自己的 README。

## 当前文档集合

- [directory-governance.md](./directory-governance.md)：仓库目录边界、准入规则和持续治理计划。
- [deployment-operations.md](./deployment-operations.md)：统一部署链路、服务器初始化、发布检查、回滚与排障。
- [frontend-theme-package.md](./frontend-theme-package.md)：共享前端主题包的目录、边界、发布和消费方式。
- [github-actions-secrets.md](./github-actions-secrets.md)：当前 GitHub Actions secrets 的事实清单和维护规则。

## 文档治理规则

- 文件名统一使用英文 `kebab-case`。
- 主标题和正文优先使用中文，直接描述当前状态和当前规则。
- 同一主题只保留一个事实源；如果某条规则已经写入专门文档，其它文档只链接，不重复抄写。
- `/docs` 只保留稳定资料；排查笔记、临时方案、迁移草稿不进入该目录。
- 涉及部署链路、共享包发布链路或目录结构的变更时，必须同步更新对应文档。

## 更新入口

- 调整顶层目录、目录职责或文档分层时，更新 [directory-governance.md](./directory-governance.md)。
- 调整 webhook、systemd、部署脚本、部署目标注册表或发布流程时，更新 [deployment-operations.md](./deployment-operations.md)。
- 调整 `packages/themes/dark-universe` 的目录、发布方式或接入方式时，更新 [frontend-theme-package.md](./frontend-theme-package.md)。
- 调整 workflow secret、仓库 secret 或发布凭证时，更新 [github-actions-secrets.md](./github-actions-secrets.md)。
