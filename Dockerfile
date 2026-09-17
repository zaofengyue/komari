FROM alpine:3.21

WORKDIR /app

# Docker buildx 会在构建时自动填充这些变量
ARG TARGETOS
ARG TARGETARCH

# 安装运行所需的基础证书、curl（用于健康检查）与时区数据
RUN apk add --no-cache ca-certificates curl tzdata && \
    mkdir -p /app/data

# 复制对应架构编译出的可执行文件
COPY --chmod=755 komari-${TARGETOS}-${TARGETARCH} /app/komari

# 环境变量设置
ENV GIN_MODE=release \
    PORT=25774 \
    TZ=Asia/Shanghai

# 持久化数据目录
VOLUME ["/app/data"]

# 暴露服务端口
EXPOSE 25774

# 健康检查探针
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f "http://localhost:${PORT:-25774}/api/version" || exit 1

# 启动服务器
CMD ["/app/komari", "server"]

