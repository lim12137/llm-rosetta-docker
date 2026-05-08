# 项目记忆

## 2026-05-09

- 当前项目的 `docker-compose.yml` 必须采用“已有镜像部署”模式，不能把本地 `build` 作为默认方案
- compose 默认镜像基线应指向已发布镜像，推荐使用 `ghcr.io/lim12137/llm-rosetta-docker:latest`
- 对外默认访问端口使用 `8801`
- 上游 `/admin/` 管理面板已接入，运行期配置以 `config/config.jsonc` 为准
