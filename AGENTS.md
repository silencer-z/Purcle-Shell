# AGENTS.md

PurcleShell — 基于 Quickshell 的 Hyprland 桌面 shell。入口 `shell.qml`（GlobalShortcut + Drawers + 通知/OSD 弹层），启动 `qs -p .`。README 的功能清单已过时，以代码为准。

## 目录

- `modules/drawers/` — 单窗口 shell 主体。`Panels.qml` 用通用 `PanelWrapper` 挂四个面板；`Backgrounds.qml` 画面板表面；`Drawers.qml` 内挂通知弹层与 OSD 浮层
- `modules/bar/` — 顶栏部件；`popouts/` — 托盘等紧贴 bar 的弹出层
- `modules/panels/{launcher,clipboard,wallpaper,sidebar,task}/` — 每个面板只放 Content（布局与交互）。`task` 为底部任务视图（工作区预览）。动画/懒加载在 `components/PanelWrapper.qml`，背景在 drawers
- `services/` — 领域数据单例（Audio/Battery/Theme/Visibilities/Paths/...）。搜索词、高亮、隐藏应用列表等 UI 状态不放这里
- `Configs/` — FileView + JsonAdapter 持久化到根目录 `configurations.json`（watchChanges 热更新）。字号走 `Config.appearance.fonts.size`
- `themes/` — 预设调色板；`components/` — `Styled*` 主题化控件 / `XxxAnim` 动画预设 / `PanelWrapper`；`assets/` — matugen 配置与应用图标
- `modules/osd/OSDOverlay.qml` — 音量/亮度 OSD 浮层；调度在 `services/OSD.qml`
- `services/ShellIPC.qml` — `qs ipc call` 入口（panels / volume / brightness / wallpaper / player）
