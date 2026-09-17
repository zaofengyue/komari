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
      - "25774:25774" # 若想使用 3000 端口，可修改为 "3000:3000" 并配合下方 PORT=3000
    volumes:
      - ./data:/app/data
    environment:
      - PORT=25774 # 监听端口，只需输入端口数字
      - TZ=Asia/Shanghai
      - GIN_MODE=release
```

启动命令：

```bash
docker compose pull
docker compose up -d
```

启动后访问 `http://<服务器IP>:25774` 进行初始化配置（首次进入会自动打开 `/install` 引导页设置管理员账号与密码）。

## 💻 虚拟机 / 免 Docker 环境部署 (CT8 / Alwaysdata / Serv00 / 虚拟主机)

针对无法运行 Docker 的虚拟主机或无 Root 权限环境（如 **Alwaysdata**、**CT8**、**Serv00**），可直接使用 GitHub Releases 发布的免安装单二进制压缩包：

### 1. 下载并解压

```bash
# 创建并进入目录
mkdir -p ~/komari && cd ~/komari

# Alwaysdata / 普通 Linux 64位主机下载：
wget https://github.com/zaofengyue/komari/releases/download/latest/komari-linux-amd64.tar.gz
tar -zxvf komari-linux-amd64.tar.gz

# CT8 / Serv00 (FreeBSD 环境) 下载：
# wget https://github.com/zaofengyue/komari/releases/download/latest/komari-freebsd-amd64.tar.gz
# tar -zxvf komari-freebsd-amd64.tar.gz

# 赋予执行权限
chmod +x komari
```

### 2. 启动服务（指定主机分配的端口）

```bash
# 测试前台运行（例如分配给你的端口是 8100 或 3000）
PORT=8100 ./komari server

# 确认无误后，使用 nohup 挂载到后台长期运行：
nohup env PORT=8100 ./komari server > komari.log 2>&1 &
```

> **提示**：Alwaysdata 可在面板后台的 **Sites** 中添加一个 `User program`，程序路径填 `/home/你的用户名/komari/komari`，参数填 `server`，环境变量填 `PORT=8100`。

## ⚙️ 环境变量说明

| 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `PORT` | `25774` | **服务端监听端口**。支持只输入纯端口（如 `3000`），程序会自动监听 `0.0.0.0:<PORT>`，适配主流容器及 PaaS 云平台。 |
| `TZ` | `Asia/Shanghai` | 容器时区设置。确保监控指标时间与日志时间显示正确。 |
| `GIN_MODE` | `release` | Web 框架运行模式。可选 `release`（生产推荐）或 `debug`（详细调试日志）。 |
| `KOMARI_WS_DISABLE_ORIGIN` | `false` | 是否禁用 WebSocket 连接的 Origin 跨域检查。设为 `true` 可解决通过复杂反向代理、CDN 或内网穿透访问时的 WebSocket 连接 403 跨域阻断问题。 |
| `KOMARI_LISTEN` | - | （已兼容）完整监听地址格式，如 `0.0.0.0:25774`。通常使用更简洁的 `PORT` 即可。 |

## 💡 常用维护命令

- **重置后台管理员密码**：
  ```bash
  docker exec -it komari /app/komari chpasswd -p 你的新密码
  docker compose restart
  ```
- **解绑 2FA（双重身份验证）**：
  ```bash
  docker exec -it komari /app/komari disable2FA
  ```
- **更换主题**：
  登录后台管理页面（`/admin`） -> 系统设置 -> 主题设置/主题市场，支持一键安装社区主题、上传主题包或直接将主题放入宿主机 `./data/theme/` 目录。

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

**特性机制**：
- **仅保留最新镜像**：固定打 `latest` 标签，自动覆盖更新，避免产生冗余的散碎 Tag；
- **自动清理运行记录**：每次流水线执行完成后，会自动清空历史的工作流运行记录。
