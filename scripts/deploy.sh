#!/bin/bash

# LLM-Rosetta 部署脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数：打印成功信息
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 函数：打印错误信息
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 函数：打印警告信息
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 函数：打印信息
print_info() {
    echo -e "ℹ️  $1"
}

echo "==================================="
echo "LLM-Rosetta 部署脚本"
echo "==================================="

# 检查配置文件
if [ ! -f .env ]; then
    print_error ".env 文件不存在，请先运行 ./scripts/init.sh"
    exit 1
fi

if [ ! -f config/config.yaml ]; then
    print_error "config/config.yaml 文件不存在，请先运行 ./scripts/init.sh"
    exit 1
fi

print_success "配置文件检查通过"

# 检查 .env 中是否配置了 API 密钥
source .env
if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$GOOGLE_API_KEY" ]; then
    print_warning "未检测到任何 API 密钥配置"
    print_info "请在 .env 文件中配置至少一个提供商的 API 密钥"
    read -p "是否继续部署? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 停止现有容器
print_info "停止现有容器..."
docker-compose down 2>/dev/null || true

# 构建镜像
print_info "构建 Docker 镜像..."
docker-compose build --no-cache

# 启动服务
print_info "启动服务..."
docker-compose up -d

# 等待服务启动
print_info "等待服务启动..."
sleep 5

# 健康检查
print_info "执行健康检查..."
for i in {1..30}; do
    if docker-compose exec -T llm-rosetta curl -f http://localhost:8000/health > /dev/null 2>&1; then
        print_success "服务启动成功！"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "服务启动失败，请查看日志"
        docker-compose logs llm-rosetta
        exit 1
    fi
    echo "等待中... ($i/30)"
    sleep 2
done

# 显示服务状态
echo ""
echo "==================================="
print_success "部署完成！"
echo "==================================="
echo ""
echo "服务信息："
echo "  - 网关地址: http://localhost:8000"
echo "  - 健康检查: http://localhost:8000/health"
echo ""
echo "常用命令："
echo "  查看日志:   docker-compose logs -f llm-rosetta"
echo "  停止服务:   docker-compose down"
echo "  重启服务:   docker-compose restart"
echo "  查看状态:   docker-compose ps"
echo ""

# 显示环境信息
print_info "容器信息："
docker-compose ps

echo ""
print_info "最近日志："
docker-compose logs --tail=20 llm-rosetta
