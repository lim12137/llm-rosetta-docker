# LLM-Rosetta Dockerfile - 简化优化版本
FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONPATH="/app" \
    PATH="/app/.local/bin:${PATH}" \
    PATH="${PATH}"

# 安装运行时依赖
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir llm-rosetta

# 安装系统依赖（curl 用于健康检查）
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/* && \
    # 清理 Python 缓存
    find /app -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true && \
    find /app -type f -name '*.pyc' -delete 2>/dev/null || true && \
    # 清理临时文件
    rm -rf /tmp/* /var/tmp/*

# 创建必要的目录
RUN mkdir -p /app/config /app/logs /app/cache && \
    # 创建非 root 用户
    useradd -m -u 1000 -s /bin/bash llmrosetta && \
    chown -R llmrosetta:llmrosetta /app

USER llmrosetta

# 暴露端口（网关模式默认端口）
EXPOSE 8000

# 健康检查（使用 curl）
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 启动命令（网关模式）
CMD ["python", "-m", "llm_rosetta.gateway", "--host", "0.0.0.0", "--port", "8000"]
