# PurcleShell

一个功能完整、美观且高度可定制的QuickShell配置，专为Hyprland打造，提供现代化的桌面体验。

## 📋 项目概览

这是一个基于QML和Quickshell框架的桌面环境配置，实现了完整的桌面Shell功能，包括顶部栏、应用启动器、剪贴板管理、系统控制面板等核心组件。

### 🎯 设计理念

- **模块化架构**: 清晰的分层设计，易于维护和扩展
- **响应式界面**: 基于Qt Quick的流畅动画和交互
- **系统集成**: 深度集成Hyprland和各种系统服务
- **主题化**: 完整的主题系统，支持多种配色方案
- **多屏幕支持**: 原生支持多显示器环境

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

## 📄 许可证

本项目采用MIT许可证，详见[LICENSE](LICENSE)文件

## 🙏 致谢

感谢以下开源项目的灵感和支持：

- [end-4 dots-hyprland](https://github.com/end-4/dots-hyprland) - UI设计灵感
- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) - 架构设计参考
- [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) - QML最佳实践
- [caelestia-shell](https://github.com/caelestia-dots/shell) - 组件设计思路
