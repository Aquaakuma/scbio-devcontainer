# scBio Dev Container

用于 Python / R 生物信息分析的可复用 VS Code 开发容器，提供 Scanpy、Seurat 和双语言 Jupyter 内核。将 `.devcontainer/` 复制到分析项目，即可使用同一套环境定义。

## 环境内容

| 用途 | 工具 |
| --- | --- |
| Python 分析 | Python 3.12、NumPy、pandas、Matplotlib、Seaborn |
| 单细胞分析 | Scanpy、AnnData、Seurat |
| R 分析 | R、dplyr、ggplot2、languageserver |
| Notebook | ipykernel、IRkernel |
| 环境管理 | Conda，conda-forge → bioconda，严格频道优先级 |

容器以 `vscode` 用户运行，环境名为 `scbio`，位于 `/opt/conda/envs/scbio`。首次创建会下载并求解依赖，耗时取决于网络和机器资源。建议为单细胞分析分配至少 4 个 CPU、16 GB 内存和充足磁盘；实际需求随数据规模增长。本仓库不包含分析数据或 GPU/CUDA 配置。

## 快速开始

1. 安装 [VS Code](https://code.visualstudio.com/)、[Docker](https://docs.docker.com/get-started/get-docker/) 和 [Dev Containers 扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)。确保 Docker 已启动；Windows 建议使用 WSL 2 后端。
2. 克隆并打开仓库：

   ```bash
   git clone https://github.com/Aquaakuma/scbio-devcontainer.git
   code scbio-devcontainer
   ```

3. 在命令面板执行 **Dev Containers: Reopen in Container**，等待初始化完成。
4. 打开 `.ipynb`，选择 **Python (scbio)** 或 **R (scbio)** 内核。Python 脚本使用 `/opt/conda/envs/scbio/bin/python`；R 脚本通过 **R: Create R terminal** 启动对应环境的 R。

VS Code 直接连接容器中的内核，无须手动启动 Jupyter 服务，因此不预设 8888 端口转发。需要浏览器服务时，可在 VS Code 的 **Ports** 面板手动转发所需端口。

终端中显式激活环境，或使用 `conda run`：

```bash
conda activate scbio
python -c 'import scanpy as sc; print(sc.__version__)'
Rscript -e 'packageVersion("Seurat")'
```

## 在其他项目中复用

将完整的 `.devcontainer/` 目录（包括隐藏的 `.condarc` 和 Feature 锁文件）复制到项目根目录，再执行 **Dev Containers: Reopen in Container**。可选复制 `.editorconfig`；本仓库的文档、CI 和许可证无需作为运行配置复制。

工作区文件通过挂载保存在宿主机，容器重建后仍保留；仅安装在容器内、未写入环境定义的依赖可能丢失。请将原始数据和结果存放在工作区或明确配置的外部挂载中。

## VS Code 扩展与设置

| 扩展 | 用途 |
| --- | --- |
| Python、Pylance、Python Debugger | 解释器选择、补全、基础类型检查和调试 |
| Jupyter、Jupyter Notebook Renderers | Notebook 编辑、执行和输出渲染 |
| R | R 终端、语言服务和会话查看 |
| Ruff | Python 检查和保存时格式化 |
| YAML、ShellCheck、EditorConfig | 环境文件、Shell 脚本检查和基础排版 |

扩展由 `customizations.vscode` 安装到容器中。Python 和 R 路径均指向 `scbio`；R 创建独立终端，避免将代码误发到其他活动终端，且不自动保存或恢复 `.RData`。R 默认使用两个空格缩进。配置只对 Python 启用保存时格式化，Notebook 输出保留由用户控制。

设置来源：[Dev Containers 配置规范](https://containers.dev/supporting) 和 [R 扩展配置定义](https://github.com/REditorSupport/vscode-R/blob/master/package.json)。

## 修改依赖与可复现性

编辑 `.devcontainer/environment.yml` 后，在容器中运行：

```bash
bash .devcontainer/setup.sh
```

脚本会创建或更新 `scbio`（使用 `--prune` 移除不再声明的 Conda 依赖），并重新注册两个 Notebook 内核；环境更新后重启运行中的内核和 R 会话。修改基础镜像、Feature 或扩展配置后，执行 **Dev Containers: Rebuild Container**。

优先将所需依赖写入 YAML，而非只在交互式会话中安装。`.devcontainer/devcontainer-lock.json` 只锁定 Dev Container Feature，不锁定基础镜像和 Python/R 依赖。当前多数分析包未固定版本，因此这是可复用环境定义，并不保证不同日期构建得到完全相同的软件版本。正式分析应额外固定镜像 digest、依赖版本或平台锁文件，并记录实际环境：

```bash
conda env export -n scbio > environment.resolved.yml
conda list -n scbio --explicit > conda-explicit.txt
conda run -n scbio Rscript -e 'sessionInfo()' > R-sessionInfo.txt
```

`conda-explicit.txt` 通常仅适用于相同平台。请随分析结果保存这些记录，提交前检查导出文件中的本地路径。

## 验证与排错

容器初始化后运行：

```bash
bash .devcontainer/smoke-test.sh
```

该检查导入主要 Python/R 分析包，并确认两个内核已注册。GitHub Actions 使用同一脚本构建并检查容器；检查通过仅说明环境可启动，不代表具体分析方法已经验证。

- **创建失败**：查看 **Dev Containers: Show Container Log**，检查镜像仓库、Conda 频道的网络访问及可用磁盘；修复后重新构建。
- **内核缺失**：重新运行 `setup.sh`，刷新内核选择器，并确认已经进入容器。
- **解释器选错**：执行 **Python: Select Interpreter**，选择 `/opt/conda/envs/scbio/bin/python`；Notebook 的内核需单独选择。
- **R 补全不可用**：确认 `scbio` 环境创建成功，重新启动 R 终端或重新加载窗口。
- **Apple Silicon / ARM**：依赖是否可用取决于各 Conda 频道的平台支持；当前 CI 仅覆盖 Linux x86_64，未承诺 ARM 兼容性。

## 仓库结构

```text
.devcontainer/
  devcontainer.json       # 镜像、Feature 和 VS Code 设置
  devcontainer-lock.json  # Feature 锁文件
  environment.yml        # Python / R 依赖
  .condarc               # Conda 频道配置
  setup.sh               # 环境创建/更新与内核注册
  smoke-test.sh          # 运行时检查
.github/workflows/       # 容器构建检查
```

## 贡献与许可证

问题与改进建议请提交到 [Issues](https://github.com/Aquaakuma/scbio-devcontainer/issues)。贡献流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。本仓库代码与配置使用 [MIT License](LICENSE)；镜像、软件包和 VS Code 扩展仍适用各自的许可证。
