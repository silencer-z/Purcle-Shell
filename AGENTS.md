# AGENTS.md

PurcleShell — 基于 Quickshell 的 Hyprland 桌面 shell。入口 `shell.qml`（GlobalShortcut + Drawers + 通知弹窗），启动 `qs -p .`。README 的功能清单已过时（通知系统已实现、OSD 仍是空文件），以代码为准。

## 目录

- `modules/drawers/` — 单窗口 shell 主体。`Panels.qml` 用通用 `PanelWrapper` 挂四个面板；`Backgrounds.qml` 画面板表面；`NotificationPopups.qml` 右上角通知弹层（与 bar popout 同构）
- `modules/bar/` — 顶栏部件；`popouts/` — 托盘等紧贴 bar 的弹出层
- `modules/panels/{launcher,clipboard,wallpaper,sidebar}/` — 每个面板只放 Content（布局与交互）。动画/懒加载在 `components/PanelWrapper.qml`，背景在 drawers
- `services/` — 领域数据单例（Audio/Battery/Theme/Visibilities/Paths/...）。搜索词、高亮、隐藏应用列表等 UI 状态不放这里
- `Configs/` — FileView + JsonAdapter 持久化到根目录 `configurations.json`（watchChanges 热更新）。字号走 `Config.appearance.fonts.size`
- `themes/` — 预设调色板；`components/` — `Styled*` 主题化控件 / `XxxAnim` 动画预设 / `PanelWrapper`；`assets/` — matugen 配置与应用图标
- `modules/osd/*.qml` — 0 字节死代码，qmllint 报错属预期
