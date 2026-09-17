# Komari

Komari 是一款轻量级的自托管服务器性能监控工具，支持 Web 界面查看服务器状态并通过 Agent 收集数据。

本项目已集成 GitHub Actions 自动化流水线，推送到主分支后将自动编译并发布多架构（amd64 / arm64）Docker 镜像。

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

## ⚙️ 环境变量说明

| 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `TZ` | `Asia/Shanghai` | 容器时区设置。确保监控指标时间与日志时间显示正确。 |
| `GIN_MODE` | `release` | Web 框架运行模式。可选 `release`（生产推荐）或 `debug`（详细调试日志）。 |
| `KOMARI_LISTEN` | `0.0.0.0:25774` | 服务端监听绑定的 IP 与端口。容器内一般保持 `0.0.0.0:25774`。 |
| `KOMARI_WS_DISABLE_ORIGIN` | `false` | 是否禁用 WebSocket 连接的 Origin 跨域检查。设为 `true` 可解决通过复杂反向代理、CDN 或内网穿透访问时的 WebSocket 连接 403 跨域阻断问题。 |

## 🛠️ 项目结构

- `cmd/`: 命令行与服务器启动入口
- `database/`: 数据库存储核心（SQLite / MetricStore）
- `internal/`: 业务逻辑与服务器控制
- `web/`: Web 路由、API 与前端静态资源嵌入定义
- `Dockerfile`: 针对轻量生产运行优化的 Alpine 镜像定义
- `.github/workflows/docker-publish.yml`: 自动化构建发布流水线（自动拉取并构建前端、Zig 交叉编译 Linux amd64/arm64 静态二进制并推送到 Docker Hub / GHCR）

## 📝 自动化构建说明

每次推送代码到 `main` 分支时，GitHub Actions 会自动触发构建并推送到：
- Docker Hub: `zaofengyue/komari:latest`
- GHCR: `ghcr.io/zaofengyue/komari:latest`
