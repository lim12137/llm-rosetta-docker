# 仓库必读

## 部署约束

- `docker-compose.yml` 必须基于已有镜像设计，禁止默认使用本地 `build`
- 默认镜像应优先使用已发布镜像，例如 `ghcr.io/lim12137/llm-rosetta-docker:latest`
- 如果需要本地构建，只能作为单独的开发命令或临时验证手段，不能作为 compose 默认部署路径

## 变更要求

- 修改部署方案时，必须同步更新 `README.md`
- 修改部署方案时，必须同步更新 `docs/admin-panel-smoke-test.md` 或其他相关验证文档
- 任何会影响后续代理判断的长期约束，都要同步写入本文件
