# `/admin/` 管理面板接入验证报告

日期：2026-05-09

## 目标

- 将当前 Docker 封装切换到上游 `llm-rosetta` 网关原生 `config.jsonc`
- 暴露并使用内置 `/admin/` 管理面板
- 让 API URL / API Key 支持在线修改并直接生效
- 在 GitHub Actions 中补充基础烟测

## 本次改动后的关键命令

```bash
./scripts/init.sh
docker compose up -d --build
curl http://localhost:8801/health
curl -I http://localhost:8801/admin/
```

## GitHub Actions 烟测命令

```bash
docker build -t llm-rosetta-gateway:test .
docker run -d --name llm-rosetta-smoke -p 8801:8000 \
  -v "$PWD/config:/app/config" \
  llm-rosetta-gateway:test

curl --retry 15 --retry-delay 2 --retry-connrefused http://127.0.0.1:8801/health
curl --fail http://127.0.0.1:8801/admin/
curl --fail http://127.0.0.1:8801/v1/models
```

## 结果摘要

- 本地未执行容器级验证。
- 阻塞原因：当前工作机 Docker Desktop Linux Engine 不可用，无法实际启动容器。
- 已将可执行烟测固化到 GitHub Actions，后续可通过 PR / push 自动验证：
  - 镜像可构建
  - `/health` 可访问
  - `/admin/` 可访问
  - `/v1/models` 可访问
- `deploy` job 已支持 `main` 和 `master`

## 预期验收标准

- 打开 `http://localhost:8801/admin/` 可进入上游管理面板
- 在面板中修改 Provider 的 `Base URL` 与 `API Key` 后无需重启容器
- 修改内容会写入 `./config/config.jsonc`
- 容器重启后配置仍保留
