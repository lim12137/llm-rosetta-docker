# 仓库约束

## 部署约束

- `docker-compose.yml` 必须默认使用已发布镜像，不能把本地 `build` 作为默认部署路径。
- 当前发布镜像基于官方镜像 `oaklight/llm-rosetta-gateway:latest`。
- 默认部署不要求宿主机预先提供 `config.jsonc`。
- 镜像内部必须自带一份默认 `config.jsonc`，并在首次启动时写入 `/config/config.jsonc`。
- 默认 compose 部署必须把 `/config` 挂到宿主机 `./config`，让首次生成的 `config.jsonc` 落盘到宿主机。
- 允许通过挂载 `/config/config.jsonc` 的方式覆盖默认配置。

## 变更要求

- 修改部署方式时，必须同步更新 `README.md`。
- 修改部署方式时，必须同步更新 `docs/admin-panel-smoke-test.md`。
- 影响长期判断的约束要同步写入本文件和 `docs/memory.md`。
