# Komari (自用开发与部署版本)

Komari 是一款轻量级的自托管服务器性能监控工具，支持 Web 界面查看服务器状态并通过 Agent 收集数据。

本项目用于个人自用、功能修改与测试，已集成 GitHub Actions 自动化流水线，推送到主分支后将自动编译并发布双架构 Docker 镜像。

## 🚀 部署方式 (Docker Compose)

在服务器上创建目录并保存以下 `docker-compose.yml`：

```yaml
services:
  komari:
    image: zaofengyue/komari:latest # 或 ghcr.io/zaofengyue/komari:latest
    container_name: komari
    restart: unless-stopped
    ports:
      - "25774:25774"
    volumes:
      - ./data:/app/data
    environment:
      - TZ=Asia/Shanghai
      - GIN_MODE=release
      - KOMARI_LISTEN=0.0.0.0:25774
```

启动命令：

```bash
docker compose pull
docker compose up -d
```

启动后访问 `http://<服务器IP>:25774` 进行初始化配置。

## 🛠️ 项目结构

- `cmd/`: 命令行与服务器入口
- `database/`: 数据库存储核心（SQLite / MetricStore）
- `internal/`: 业务逻辑与服务器控制
- `web/`: Web 路由、API 与前端静态资源嵌入定义
- `Dockerfile`: 针对自用优化的多架构轻量镜像定义
- `.github/workflows/docker-publish.yml`: 自动化构建发布流水线（构建前端、Zig交叉编译Linux amd64/arm64静态二进制并推送到Docker Hub/GHCR）

## 📝 自动化构建说明

每次推送代码到 `main` 分支时，GitHub Actions 会自动触发构建并推送到：
- Docker Hub: `zaofengyue/komari:latest`
- GHCR: `ghcr.io/zaofengyue/komari:latest`
