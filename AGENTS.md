# AGENTS.md

PurcleShell — 基于 Quickshell 的 Hyprland 桌面 shell。

## 验证

- **qmllint 必须用 Qt6 版本**：`/usr/lib/qt6/bin/qmllint`。
  `/usr/bin/qmllint` 是 qt5-declarative 的 Qt5 版，遇到 Qt6 语法
  （`pragma Singleton`、inline component、`required property`）会**静默退出 255 且无任何输出**，
  不能作为验证依据。判断通过与否要看**退出码**，不能只看输出是否为空。
- `qs.*` / `Quickshell.*` 模块在裸 qmllint 下必然报 import 警告，过滤 `syntax` 关键字看语法错误即可。
- `modules/osd/*.qml` 目前是 0 字节空文件（死代码），qmllint 会报错，属预期。

## Quickshell 热加载（watchFiles）的限制

- **运行期新建的 .qml 文件不会被注册进目录模块**（如 `qs.modules.bar.popouts`），
  reload 时会报 `Type Xxx is not a type`。已有文件的修改才能正常热加载。
  解决：引用方用 `Loader { source: Qt.resolvedUrl("Xxx.qml") }` 按路径加载；
  或者重启 quickshell 使新文件注册。
- 配置加载失败时 shell 继续运行上一次成功的配置，`qs log` 查看错误。
- **多次失败的 reload 会让合成器侧窗口状态变陈旧**：QML 侧一切正常（activeFocus、
  keyboardFocus 绑定都对）但键盘事件到不了窗口，就是这种情况的典型症状。
  把可疑窗口 `visible: false` 再恢复（或重启 quickshell）让它重新映射即可修复，
  不要盲目继续改 QML。

## QML 陷阱（本项目踩过的）

- **不要声明与基类原生属性同名的自定义属性**（如 PanelWindow 的 `screen`、`exclusiveZone`）。
  QML 会静默遮蔽原生属性，实例赋值写到自定义属性上，原生行为失效且无报错。
  需要透传时用不同名字（如 `reservedZone`）再绑定原生属性。
- **inline component 不允许循环引用**（`Inline components form a cycle!`）。
  递归结构用独立文件 + `Loader { source: Qt.resolvedUrl(...) }` 自引用实现。
- `GlobalShortcut` 来自 `Quickshell.Hyprland`，不是 `Quickshell` 核心。
- `ScriptModel`、`Variants`（含 `instances`）来自 `Quickshell`，不是 QtQuick。
- inline `component` 声明必须写在 root 对象**内部**，文件顶层是语法错误。
- `StyledTextInput` 基于 `TextInput`（无 placeholder 之外的部分 TextField 特性），
  placeholder 支持已自行实现。
- MaterialSymbol 的字号属性是 `size`，没有 `iconSize`。
- **跨目录模块单例的 binding 初次求值为 null 且不会重试**：单例 A 的 property binding
  引用另一目录模块的单例 B（如 Theme 引用 `qs.themes` 的 Catppuccin）时，创建顺序问题
  会使首次求值拿到 null，而 binding 无可通知依赖就永不重算。
  解决：声明 `property int generation: 0`，`Component.onCompleted: root.generation++`，
  在相关 binding 内部先读一下 `generation` 强制重求值（见 services/Theme.qml）。
- Quickshell 目录模块单例要求 **`pragma Singleton` + 根类型为 `Singleton`（需 `import Quickshell`）**，
  `pragma Singleton` + `QtObject` 根是无效的（解析为 null）。
- 给 JsonObject 写入时**不要用 `obj[key] = value` 动态赋值**（可能写到 JS 包装器上不落入
  Q_PROPERTY，导致 JsonAdapter 不持久化），用显式 switch 分支赋值。

## 架构约定

- 单窗口 drawers 架构：bar、panels、popouts 都在同一个全屏 PanelWindow（`Drawers.qml`），
  mask Region 控制输入区域；bar 的桌面占位由 1×1 隐形 `BarExclusion` 窗口完成
  （全屏窗口 ExclusionMode.Ignore 无法占位，caelestia Exclusions 同款技巧）。
- popouts（`modules/bar/popouts/`）紧贴 bar 底缘、顶角方角与 bar 同色相连（caelestia 连体效果），
  与面板（Visibilities）互斥：开面板关 popout，开 popout 收面板。
- 主题色统一从 `Theme` 单例取语义色；样式 token 从 `Config.appearance` 取
  （spacing/padding/rounding/border/animations），不要硬编码。
- 配色架构（三层）：
  - **门面 `services/Theme.qml`**：全部消费方只碰 `Theme.*` 语义色，不感知底层方案；
  - **预设 `themes/*.qml`**：固定调色板（presetId/displayName/dark 元数据 + 语义色），
    每个预设可在 `Config.colors.themeWallpapers` 绑定一张壁纸（切主题自动换壁纸）；
  - **动态 `services/Color.qml`**：`scheme = "matugen"` 时壁纸变化自动跑 matugen
    （`assets/matugen/config.toml` + 模板 → `~/.cache/PurcleShell/matugen-colors.json`，
    FileView 监听热更新）；`scheme = "pywal"` 时监听 `~/.cache/wal/colors.json`（外部 wal 驱动）。
  切换入口：壁纸面板的「配色」区（Theme.usePreset / useMatugen / usePywal）。
  新增预设：themes/ 下新建文件（需重启 quickshell 注册）+ ConfigColor 的 themeWallpapers 加 key。
- 通知（`services/Notifications.qml`）：NotificationServer 收到通知后创建 `NotifWrapper`
  （QtObject 代理，popupModel/historyModel 行结构均为 `{ wrapper }`）。生命周期：
  `closed(reason)` — Expired/Dismissed 只收弹窗、历史保留作记录；CloseRequested（应用撤回）
  彻底移除销毁。transient 只弹不进历史；resident/critical 常驻；自动关闭尊重应用的
  expireTimeout。注意：QtObject 没有默认属性，wrapper 内的 Timer/Connections 要用
  `property Xxx x: Xxx {}` 属性内联实例化，不能直接声明为子对象。
- 服务层单例命名为领域名词（Audio/Battery/Bluetooth/Brightness/Network/Player/...），
  组件库 `components/` 分族：`Styled*`（主题化控件）、`XxxAnim`（动画预设）、语义名（AppIcon/MaterialSymbol）。
