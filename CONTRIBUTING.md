# 贡献指南

欢迎通过 Issue 或 Pull Request 改进这个开发环境。

## 报告问题

请提供操作系统、CPU 架构、Docker / VS Code 版本、复现步骤，以及相关的 Dev Containers 日志。请移除凭据、个人信息和研究数据。

## 修改与验证

1. 将运行依赖添加到 `.devcontainer/environment.yml`，将容器与编辑器设置放在 `.devcontainer/devcontainer.json`。
2. 保持默认环境通用；特定项目的大型工具链请先通过 Issue 讨论。
3. 在 VS Code 中执行 **Dev Containers: Rebuild Container**。
4. 在新容器中运行 `bash .devcontainer/smoke-test.sh`；修改初始化脚本时也应重新运行 `setup.sh`，确认已有环境可更新。
5. 更新 README 中对应的使用说明，在 PR 中说明变更原因与实际验证结果。

请勿提交数据集、分析结果、凭据或个人编辑器配置。依赖更新应说明平台兼容性和对现有分析的潜在影响。当前 CI 在 Linux x86_64 上执行完整初始化和主要包导入检查。
