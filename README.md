# QuickShell - 现代化Hyprland桌面环境

一个功能完整、美观且高度可定制的QuickShell配置，专为Hyprland打造，提供现代化的桌面体验。

## 📋 项目概览

这是一个基于QML和Quickshell框架的桌面环境配置，实现了完整的桌面Shell功能，包括顶部栏、应用启动器、剪贴板管理、系统控制面板等核心组件。

### 🎯 设计理念

- **模块化架构**: 清晰的分层设计，易于维护和扩展
- **响应式界面**: 基于Qt Quick的流畅动画和交互
- **系统集成**: 深度集成Hyprland和各种系统服务
- **主题化**: 完整的主题系统，支持多种配色方案
- **多屏幕支持**: 原生支持多显示器环境

## 🏗️ 项目架构

### 核心架构图

```
┌─────────────────────────────────────────────────────────────┐
│                     shell.qml (入口)                        │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│ │   多屏幕管理    │ │   全局快捷键    │ │   面板包装器    │ │
│ │   (Variants)    │ │ (GlobalShortcut)│ │  (PanelWrapper) │ │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   顶部栏模块    │    │   面板模块      │    │   OSD模块       │
│   (Bar)         │    │   (Panels)      │    │   (OSD)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   系统服务层    │    │   UI组件库      │    │   主题系统      │
│  (Services)     │    │ (Components)    │    │   (Themes)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 目录结构

```
quickshell/
├── shell.qml                           # 主入口文件
├── CLAUDE.md                           # 项目开发指导文档
├── README.md                           # 项目说明文档
├── assets/                             # 静态资源
│   └── fastfetch/                      # Fastfetch配置
├── components/                         # 可复用UI组件库
│   ├── BarWidget.qml                   # 顶部栏组件基类
│   ├── PanelWidget.qml                 # 面板组件基类
│   ├── RoundCorner.qml                 # 圆角装饰组件
│   ├── StyledButton.qml                # 样式化按钮
│   ├── StyledIcon.qml                  # 样式化图标
│   ├── StyledPopup.qml                 # 样式化弹窗
│   ├── StyledRect.qml                  # 样式化矩形容器
│   ├── StyledText.qml                  # 统一文本样式
│   ├── StyledTextInput.qml             # 样式化文本输入
│   └── StyledTooltip.qml               # 样式化工具提示
├── modules/                            # 功能模块
│   ├── bar/                            # 顶部栏模块
│   │   ├── Bar.qml                     # 顶部栏主组件
│   │   └── widgets/                    # 顶部栏小组件
│   │       ├── ActiveApps.qml          # 活动应用显示
│   │       ├── Board.qml               # 系统状态面板
│   │       ├── Clock.qml               # 时钟组件
│   │       ├── SysTray.qml             # 系统托盘
│   │       ├── TrayPopup.qml           # 托盘弹窗
│   │       ├── WidgetsGroup.qml        # 组件组容器
│   │       └── Workspaces.qml          # 工作区管理
│   ├── osd/                            # 屏幕显示模块
│   │   ├── BrightnessOSD.qml           # 亮度OSD
│   │   ├── OsdValueIndicator.qml       # OSD值指示器
│   │   └── VolumeOSD.qml               # 音量OSD
│   └── panels/                         # 面板模块
│       ├── PanelWrapper.qml            # 面板状态机管理器
│       ├── ClipBoardPanel.qml          # 剪贴板管理面板
│       ├── DashBoardPanel.qml          # 仪表板面板
│       ├── LaunchPanel.qml             # 应用启动器面板
│       └── widgets/                    # 面板组件
│           ├── AppListView.qml         # 应用列表视图
│           ├── BluetoothCapsule.qml    # 蓝牙连接胶囊
│           ├── BottomPanel.qml         # 底部快捷操作面板
│           ├── BrightnessSlider.qml    # 亮度滑块
│           ├── CalendarPanelWidget.qml # 日历组件
│           ├── NotificationWidget.qml  # 通知管理组件
│           ├── TodoWidget.qml          # TODO任务管理
│           ├── VolumeSlider.qml        # 音量滑块
│           ├── WifiCapsule.qml         # WiFi连接胶囊
│           └── WorkTimeWidget.qml      # 工作时间追踪
├── services/                           # 系统服务模块
│   ├── AppModel.qml                    # 应用数据管理服务
│   ├── Audio.qml                       # 音频控制服务
│   ├── Battery.qml                     # 电池状态服务
│   ├── Bluetooth.qml                   # 蓝牙管理服务
│   ├── Brightness.qml                  # 亮度控制服务
│   ├── ClipModel.qml                   # 剪贴板历史服务
│   ├── Network.qml                     # 网络状态服务
│   └── SysInfo.qml                     # 系统信息服务
└── themes/                             # 主题系统
    ├── Catppuccin.qml                  # Catppuccin主题
    ├── Dracula.qml                     # Dracula主题
    ├── Gruvbox.qml                     # Gruvbox主题
    ├── Matugen.qml                     # Matugen动态主题
    └── Oxocarbon.qml                   # Oxocarbon主题
```

## 接口规范

```qml

import QuickShell

QuickShell.cacheDir

```


## 🎨 功能特性

### ✅ 已完成功能

#### 📱 顶部栏系统

- **工作区管理**: 动态工作区显示和切换
- **活动应用**: 当前运行应用显示，支持应用固定
- **系统状态**: 实时系统监控（网络、蓝牙、电量、音频、亮度）
- **系统托盘**: 完整的系统托盘集成
- **时钟显示**: 日期时间显示
- **视觉效果**: 圆角装饰、阴影效果、流畅动画

#### 🚀 应用启动器

- **应用搜索**: 智能应用名称搜索和过滤
- **频率排序**: 基于使用频率的智能排序
- **键盘导航**: 完整的键盘快捷键支持
- **高亮显示**: 搜索关键词高亮
- **应用启动**: 支持桌面应用解析和启动

#### 📋 剪贴板管理

- **历史记录**: 剪贴板历史记录显示
- **快速操作**: 一键复制、删除功能
- **键盘快捷键**: 便捷的键盘操作
- **持久化**: 基于`cliphist`的剪贴板历史

todo)) 支持多种格式

#### 🎛️ Dashboard控制面板

- **模块化设计**: 可扩展的小部件系统
- **WiFi胶囊**: 快速WiFi连接和状态显示
- **蓝牙胶囊**: 蓝牙设备管理界面
- **日历组件**: 日期显示和导航
- **TODO管理**: 完整的任务管理系统
  - 添加、完成、删除任务
  - 任务过滤（全部/活跃/已完成）
  - 优先级指示器
  - 持久化存储到JSON
- **工作时间**: 时间追踪和管理
- **音量控制**: 系统音量调节滑块
- **亮度控制**: 显示器亮度调节
- **底部面板**: 快捷操作面板

#### 🎨 主题系统

- **多主题支持**: Catppuccin、Gruvbox、Dracula、Oxocarbon
- **动态主题**: Matugen壁纸取色系统
- **统一配色**: 完整的颜色变量管理
- **明暗模式**: 部分主题支持明暗切换

#### 🖥️ 多屏幕支持

- **原生支持**: 基于Quickshell Variants系统
- **独立实例**: 每屏幕独立的组件实例
- **状态同步**: 全局状态在所有屏幕间同步

### 🚧 开发中功能

#### 📺 OSD指示器

- **音量OSD**: 音量调节时的屏幕显示
- **亮度OSD**: 亮度调节时的屏幕显示
- **统一设计**: 与整体主题一致的OSD样式

#### 🎛️ 主题管理GUI

- **可视化切换**: 图形化主题选择界面
- **实时预览**: 主题效果实时预览
- **自定义设置**: 用户自定义主题选项

### 📅 计划功能

#### 🔔 通知系统

- **通知管理**: 系统通知的显示和管理
- **弹窗动画**: 从右上角滑入的通知弹窗
- **历史记录**: 通知历史查看

#### ⚡ 性能优化

- **资源优化**: 降低CPU和内存使用
- **启动优化**: 加快组件启动速度
- **渲染优化**: 提升动画渲染性能

## 🎯 设计模式

### 🏗️ 架构模式

#### 单例模式 (Singleton)

**应用场景**: 所有系统服务

```qml
pragma Singleton
Singleton {
    id: root
    // 全局状态管理
}
```

**优势**:

- 全局状态一致性
- 避免重复实例化
- 统一的数据接口

#### 状态机模式 (State Machine)

**应用场景**: 面板生命周期管理

```qml
readonly property int stateClosed: 0
readonly property int stateLoading: 1
readonly property int stateOpen: 2
readonly property int stateClosing: 3
property int panelState: stateClosed
```

**状态流程**: `Closed → Loading → Open → Closing → Closed`
**优势**:

- 状态管理清晰
- 动画控制精确
- 异常处理完善

#### 观察者模式 (Observer)

**应用场景**: 系统状态变化响应

```qml
// Qt信号槽机制
onNetworkStateChanged: {
    updateUI();
}
```

**优势**:

- 松耦合设计
- 事件驱动架构
- 实时状态更新

#### 组件组合模式 (Composite)

**应用场景**: UI组件组织

```qml
BarWidget {
    // 继承基类属性
    // 组合多个子组件
}
```

**优势**:

- 代码复用性高
- 组件层次清晰
- 易于扩展维护

### 🔧 技术特性

#### 异步加载

- **Loader组件**: 按需加载面板内容
- **异步处理**: 避免UI阻塞
- **生命周期管理**: 组件创建和销毁

#### 数据绑定

- **响应式设计**: 自动UI更新
- **属性绑定**: 简化状态管理
- **计算属性**: 动态数据计算

#### 动画系统

- **流畅过渡**: 平滑的动画效果
- **缓动函数**: 自然的运动曲线
- **性能优化**: GPU加速渲染

## 🛠️ 开发指南

### 环境要求

- **Quickshell**: 最新版本的Quickshell框架
- **Hyprland**: Wayland合成器
- **QtQuick**: QML运行环境
- **系统依赖**:
  - `nmcli` (网络管理)
  - `cliphist` (剪贴板历史)
  - `upower` (电源管理)
  - `pipewire` (音频系统)

### 安装使用

1. **克隆仓库**

```bash
git clone <repository-url> ~/.config/quickshell
cd ~/.config/quickshell
```

2. **安装依赖**

```bash
# Arch Linux
sudo pacman -S quickshell hyprland

# 确保系统工具已安装
sudo pacman -S networkmanager pipewire upower
```

3. **配置快捷键**

```bash
# 在Hyprland配置中添加快捷键绑定
bind = SUPER, SPACE, exec, qs
```

4. **启动QuickShell**

```bash
quickshell -p shell.qml
# 或者使用简写
qs -p .
```

### 开发工作流

#### 代码格式化

```bash
# 格式化所有QML文件
qmlformat -i **/*.qml

# 语法检查
qmllint **/*.qml
```

#### 调试技巧

- **日志输出**: 使用`console.log()`进行调试
- **热重载**: QuickShell支持部分热重载功能

#### 扩展开发

**添加新的面板组件**:

1. 在`modules/panels/widgets/`创建组件文件
2. 继承`PanelWidget`基类
3. 在`DashBoardPanel.qml`中注册组件
4. 实现键盘导航支持

**添加新的系统服务**:

1. 在`services/`目录创建服务文件
2. 使用`pragma Singleton`声明
3. 实现`Process`集成
4. 提供统一的数据接口

**添加新主题**:

1. 在`themes/`目录创建主题文件
2. 继承`QtObject`并定义颜色变量
3. 支持`dark`和`light`两种模式
4. 更新主题选择界面

### 配置说明

#### 全局快捷键

- `SUPER + A`: 打开启动器
- `SUPER + V`: 打开剪贴板管理
- `SUPER + D`: 打开Dashboard面板

#### 自定义配置

大部分配置选项在各组件中可直接修改:

- 更新间隔设置
- 颜色主题变量
- 动画时长参数
- 组件尺寸设置

## 🔧 故障排除

### 常见问题

**Q: QuickShell无法启动？**
A: 检查QML语法错误，使用`qmllint`进行语法检查

**Q: 系统服务不工作？**
A: 确保相关系统工具已安装且在PATH中

**Q: 多屏幕显示异常？**
A: 检查Hyprland的多屏幕配置

**Q: 主题不生效？**
A: 确保主题文件语法正确，检查导入路径

## 📄 许可证

本项目采用MIT许可证，详见[LICENSE](LICENSE)文件

## 🙏 致谢

感谢以下开源项目的灵感和支持：

- [end-4 dots-hyprland](https://github.com/end-4/dots-hyprland) - UI设计灵感
- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) - 架构设计参考
- [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) - QML最佳实践
- [caelestia-shell](https://github.com/caelestia-dots/shell) - 组件设计思路
