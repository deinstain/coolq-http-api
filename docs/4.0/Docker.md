# Docker

酷 Q 目前可以在 Wine 中运行，见 [酷Q Air / Pro on Wine](https://cqp.cc/t/30966)，因此也就自然而然有了相应的 Docker 镜像 [coolq/wine-coolq](https://hub.docker.com/r/coolq/wine-coolq/)。

要在 Docker 中使用本插件，你可以使用酷 Q 官方的 Docker 镜像，然后在其中安装本插件（下载 cpk、编辑配置文件、启用插件），也可以使用我维护的已安装并启用了插件的镜像 [richardchien/cqhttp](https://hub.docker.com/r/richardchien/cqhttp/)（基于酷 Q 官方的镜像修改）。下面介绍这个镜像的用法。

## 基本用法

```bash
$ docker pull richardchien/cqhttp:latest
$ mkdir coolq  # 用于存储酷 Q 的程序文件
$ docker run -ti --rm --name cqhttp-test \
             -v $(pwd)/coolq:/home/user/coolq \  # 将宿主目录挂载到容器内用于持久化酷 Q 的程序文件
             -p 9000:9000 \  # noVNC 端口，用于从浏览器控制酷 Q
             -p 5700:5700 \  # HTTP API 插件开放的端口
             -e COOLQ_ACCOUNT=123456 \ # 要登录的 QQ 账号，可选但建议填
             -e CQHTTP_POST_URL=http://example.com:8080 \  # 事件上报地址
             -e CQHTTP_SERVE_DATA_FILES=yes \  # 允许通过 HTTP 接口访问酷 Q 数据文件
             richardchien/cqhttp:latest
```

其中，`CQHTTP_POST_URL`、`CQHTTP_SERVE_DATA_FILES` 是用于配置插件运行的，格式为「`CQHTTP_` + 插件配置项的大写」，具体的配置项，见 [配置](/Configuration)。

然后访问 `http://<你的IP>:9000/` 进入 noVNC（默认密码 `MAX8char`），登录酷 Q，即可开始使用（插件已自动启用，配置文件也根据启动命令的环境变量自动生成了）。一般情况下，你不太需要关注插件是如何存在于容器中的。

注意，默认情况下，容器启动时会将 `CQHTTP_` 开头的环境变量写入到配置文件中（整个覆盖已有的配置文件），**因此，尽管你可以在酷 Q 运行时修改配置文件并重启插件以使用修改后的配置，但容器重启后配置文件将再次被覆盖**。如果你打算手动编辑和管理配置文件，可以设置环境变量 `CONFIG_MANUALLY` 的值为 `true`（默认 `false`），插件将不会把 `CQHTTP_` 开头的环境变量写入（覆盖）到配置文件中。

## 通过环境变量配置容器的运行

| 环境变量名 | 说明 |
| -------- | ---- |
| `VNC_PASSWD` | 继承自官方镜像，noVNC 的密码（官方说不能超过 8 个字符，但实测可以超过） |
| `COOLQ_ACCOUNT` | 继承自官方镜像，设置要登录酷 Q 的 QQ 号。在第一次手动登录后，你可以勾选「快速登录」功能以启用自动登录，此后，容器启动或酷 Q 异常退出时，会自动登录该帐号。 |
| `COOLQ_URL` | 继承自官方镜像，设置下载酷 Q 的地址，默认为 `http://dlsec.cqp.me/cqa-tuling`，即酷 Q Air 图灵版。请确保下载后的文件能解压出 `酷Q Air/CQA.exe` 或 `酷Q Pro/CQP.exe` |
| `CONFIG_MANUALLY` | 设置是否手动编辑配置文件，设置为 `true` 时（默认为 `false`）容器将不会自动把 `CQHTTP_` 开头的环境变量写入配置文件 |
| `CQHTTP_POST_URL`<br>`CQHTTP_SERVE_DATA_FILES`<br>`CQHTTP_USE_WS`<br>等形如 `CQHTTP_*` 的 | 当 `CONFIG_MANUALLY` 未设置或设置为 `false` 时，可通过「`CQHTTP_` + 插件配置项的大写」来配置插件的运行，容器会将这些项的值自动写入配置文件 |

## 更换／升级插件版本

Docker 镜像使用 tag 来标记版本，插件版本 3.0.0 之后的 richardchien/cqhttp 镜像遵循了这一点（旧版本没有，已移至镜像的 `legacy` 标签）。

上一节的示例给出的命令拉取了 `richardchien/cqhttp:latest`，即当前最新版本（稳定版），如果你需要更新插件到最新版本，重新拉取一次 `latest` 标签即可，如果你需要使用指定版本的插件，如 `3.0.0` 版本，则使用镜像 `richardchien/cqhttp:3.0.0`。插件的 GitHub 仓库中的每个 release 对应 docker 镜像的一个 tag，**注意，release 的标题中的版本号有 `v` 开头，docker 镜像的 tag 没有**。

此外，Docker 容器在每次运行时，会将相应版本的 cpk 文件复制到酷 Q 的 app 目录，并覆盖已有的文件（假设有的话）。这意味着，**当使用某个版本的 docker 镜像时，如果你自行更换了 cpk 文件，那么下次容器重启时将会重新覆盖它**。并且，无法使用插件的检查更新功能来更新。如果你不要这个行为，可以删除 `app\io.github.richardchien.coolqhttpapi\version.lock` 文件以解除版本锁；如果要恢复默认行为，重新创建这个文件即可。
