# AGENTS.md

PurcleShell — 基于 Quickshell 的 Hyprland 桌面 shell。入口 `shell.qml`（GlobalShortcut + Drawers + 通知弹窗），启动 `qs -p .`。README 的功能清单已过时（通知系统已实现、OSD 仍是空文件），以代码为准。

## 目录

- `modules/drawers/` — 单窗口 shell 主体（见架构约定）
- `modules/bar/` — 顶栏部件；`popouts/` — 托盘等紧贴 bar 的弹出层
- `modules/panels/{launcher,clipboard,wallpaper,sidebar}/` — 每个面板统一 Wrapper（动画/懒加载）/Content/Background 三件套
- `modules/popups/` — 通知弹窗（独立窗口）
- `services/` — 领域名词命名的单例（Audio/Battery/Theme/Visibilities/Paths/...），跨打开周期的状态都归这里
- `Configs/` — FileView + JsonAdapter 持久化到根目录 `configurations.json`（watchChanges 热更新）
- `themes/` — 预设调色板；`components/` — `Styled*` 主题化控件 / `XxxAnim` 动画预设 / 语义组件；`assets/` — matugen 配置与应用图标
- `modules/osd/*.qml` — 0 字节死代码，qmllint 报错属预期
