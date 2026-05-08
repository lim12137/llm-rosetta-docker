# LLM-Rosetta 容器化部署方案

基于 [LLM-Rosetta](https://github.com/Oaklight/llm-rosetta) 网关的容器化部署方案，支持三大协议互转，并直接启用上游内置 `/admin/` 管理面板：
- **OpenAI Chat Completions**
- **OpenAI Responses**
- **Anthropic Messages**
- **Google GenAI**

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/your-username/llm-rosetta-docker.git
cd llm-rosetta-docker
```

### 2. 初始化配置

```bash
cp .env.example .env
mkdir -p config
cp config.jsonc.example config/config.jsonc
```

### 3. 启动服务

```bash
docker-compose up -d
```

服务将在 `http://localhost:8801` 启动。

默认 `docker-compose.yml` 会直接使用已发布镜像：

```bash
ghcr.io/lim12137/llm-rosetta-docker:latest
```

如果你要切换到别的已发布版本，可以在启动前覆盖：

```bash
LLM_ROSETTA_IMAGE=ghcr.io/lim12137/llm-rosetta-docker:latest docker-compose up -d
```

### 4. 在线配置

打开 `http://localhost:8801/admin/`，直接在页面中修改：

- Provider 的 `Base URL`
- Provider 的 `API Key`
- 模型到 Provider 的路由关系

修改会写入 `./config/config.jsonc`，按上游管理面板设计可直接生效，无需重启容器。

## 📋 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 512MB 可用内存
- 至少 1GB 可用磁盘空间

## 🔧 配置说明

### 环境变量

| 变量名 | 说明 | 必填 | 默认值 |
|--------|------|------|--------|
| `OPENAI_API_KEY` | OpenAI API 密钥 | 否 | - |
| `OPENAI_BASE_URL` | OpenAI API 基础 URL | 否 | `https://api.openai.com/v1` |
| `ANTHROPIC_API_KEY` | Anthropic API 密钥 | 否 | - |
| `GOOGLE_API_KEY` | Google GenAI API 密钥 | 否 | - |
| `GOOGLE_BASE_URL` | Google GenAI API 基础 URL | 否 | `https://generativelanguage.googleapis.com` |
这些环境变量不再作为运行期主配置来源；运行中的真实配置以后续 `/admin/` 保存到 `config/config.jsonc` 的内容为准。

### 配置文件

复制 `config.jsonc.example` 为 `config/config.jsonc`：

```bash
mkdir -p config
cp config.jsonc.example config/config.jsonc
```

该文件是上游网关原生配置文件，管理面板也会直接读写它。

## 📦 使用方法

### 通过 Docker Compose

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f llm-rosetta

# 停止服务
docker-compose down
```

说明：

- compose 默认走“已有镜像部署”，不依赖本地 `docker build`
- 如需替换镜像，可通过环境变量 `LLM_ROSETTA_IMAGE` 覆盖

### 直接使用 Docker

```bash
# 构建镜像
docker build -t llm-rosetta:latest .

# 运行容器
docker run -d \
  --name llm-rosetta \
  -p 8801:8000 \
  -v $(pwd)/config:/app/config \
  llm-rosetta:latest
```

如果你只是部署运行，优先使用已发布镜像而不是本地构建。

## 🔌 API 使用示例

### OpenAI 格式 → Anthropic 格式

```bash
curl -X POST http://localhost:8801/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-provider-target: anthropic" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### Anthropic 格式 → OpenAI 格式

```bash
curl -X POST http://localhost:8801/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "x-provider-target: openai" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

## 🏗️ CI/CD 流程

### GitHub Actions 工作流

项目包含完整的 CI/CD 流程：

1. **构建和推送 Docker 镜像**
   - 支持多架构（amd64, arm64）
   - 自动生成标签（版本号、latest）
   - 推送到 GitHub Container Registry

2. **安全扫描**
   - 使用 Trivy 扫描漏洞
   - 生成 SBOM（软件物料清单）
   - 上传到 GitHub Security

3. **自动部署**
   - 推送到 `main` 或 `master` 分支时触发
   - 可自定义部署逻辑

### 触发构建

```bash
# 推送代码触发构建
git push origin master

# 创建标签触发版本发布
git tag v1.0.0
git push origin v1.0.0

# 手动触发
# 在 GitHub Actions 页面点击 "Run workflow"
```

## 🔒 安全最佳实践

### 1. 使用环境变量管理密钥

```bash
# 不要在配置文件中硬编码密钥
# 使用 .env 文件（已加入 .gitignore）
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
```

### 2. 限制网络访问

```yaml
# docker-compose.yml 中配置
networks:
  llm-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### 3. 启用速率限制

在 `http://localhost:8801/admin/` 中配置：

```yaml
security:
  rate_limit:
    enabled: true
    requests_per_minute: 60
```

## 📊 监控和日志

### 查看日志

```bash
# 实时日志
docker-compose logs -f llm-rosetta

# 最近 100 行
docker-compose logs --tail=100 llm-rosetta

# 持久化日志
ls -la logs/llm-rosetta.log
```

### 健康检查

```bash
curl http://localhost:8801/health
```

### 指标监控

管理面板内置实时指标与请求日志视图。

## 🛠️ 故障排查

### 容器无法启动

```bash
# 查看详细日志
docker-compose logs llm-rosetta

# 检查端口占用
netstat -tuln | grep 8801
```

### API 请求失败

```bash
# 检查环境变量
docker-compose exec llm-rosetta cat /app/config/config.jsonc
```

### 性能问题

```bash
# 查看资源使用
docker stats llm-rosetta

# 调整资源限制
# 编辑 docker-compose.yml 中的 resources 部分
```

## 📝 开发和测试

### 本地开发

```bash
# 使用库模式
python -c "from llm_rosetta import *; print('Ready')"

# 运行测试
pytest tests/
```

### 运行测试容器

```bash
docker-compose run --rm llm-rosetta pytest
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🔗 相关资源

- [LLM-Rosetta 官方文档](https://llm-rosetta.readthedocs.io/)
- [LLM-Rosetta GitHub 仓库](https://github.com/Oaklight/llm-rosetta)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Container Registry](https://ghcr.io/)

## ⚠️ 免责声明

本项目仅供学习和研究使用。使用时请遵守相关 AI 提供商的服务条款。
