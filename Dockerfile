# LLM-Rosetta Dockerfile
FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 从源码安装 LLM-Rosetta（更安全，避免 PyPI 供应链风险）
RUN pip install --no-cache-dir git+https://github.com/Oaklight/llm-rosetta.git

# 创建配置目录
RUN mkdir -p /app/config

# 复制配置文件（如果存在）
COPY config.yaml /app/config/ 2>/dev/null || true

# 创建非 root 用户
RUN useradd -m -u 1000 llmrosetta && \
    chown -R llmrosetta:llmrosetta /app

USER llmrosetta

# 暴露端口（网关模式默认端口）
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health', timeout=5)" || exit 1

# 启动命令（根据需要选择库模式或网关模式）
# 默认启动网关模式
CMD ["llm-rosetta-gateway", "--host", "0.0.0.0", "--port", "8000"]

# 如果需要使用库模式，可以修改 CMD 为：
# CMD ["python", "-c", "from llm_rosetta import *; print('LLM-Rosetta library mode ready')"]
