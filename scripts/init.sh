#!/bin/bash

# LLM-Rosetta 初始化脚本
# 用于首次部署时的环境设置

set -e

echo "==================================="
echo "LLM-Rosetta 初始化脚本"
echo "==================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

echo "✅ Docker 环境检查通过"

# 创建必要的目录
echo "📁 创建目录结构..."
mkdir -p config logs ssl

# 复制示例配置文件
if [ ! -f .env ]; then
    echo "📝 创建 .env 文件..."
    cp .env.example .env
    echo "⚠️  请编辑 .env 文件并填入你的 API 密钥"
else
    echo "✅ .env 文件已存在"
fi

if [ ! -f config/config.yaml ]; then
    echo "📝 创建 config.yaml 文件..."
    cp config.yaml.example config/config.yaml
    echo "⚠️  请编辑 config/config.yaml 文件进行配置"
else
    echo "✅ config.yaml 文件已存在"
fi

# 设置权限
echo "🔒 设置文件权限..."
chmod 600 .env 2>/dev/null || true
chmod 644 config/config.yaml 2>/dev/null || true
chmod 755 config logs ssl 2>/dev/null || true

# 提示用户配置
echo ""
echo "==================================="
echo "初始化完成！"
echo "==================================="
echo ""
echo "下一步操作："
echo "1. 编辑 .env 文件，填入 API 密钥"
echo "2. 编辑 config/config.yaml，配置提供商"
echo "3. 运行部署脚本: ./scripts/deploy.sh"
echo ""
echo "快速启动:"
echo "  docker-compose up -d"
echo ""
