# AutoMate Pro

跨平台自动点击器 | Cross-platform Auto Clicker

## 项目简介

AutoMate Pro 是一款功能强大的跨平台桌面自动点击器，采用 Flutter Desktop 开发，支持 Windows、macOS 和 Linux 三大主流操作系统。

## 主要功能

### 基础点击
- **多种点击模式**: 单次点击、连续点击（连点器）、长按、双击
- **可调频率**: 0.1 - 100 CPS（每秒点击次数）
- **间隔配置**: 固定间隔或随机延迟范围
- **坐标设置**: 精确坐标输入 + 屏幕坐标拾取
- **随机位置**: 支持位置偏移，模拟更自然的点击行为
- **鼠标按钮**: 左键、中键、右键、前进、后退

### 控制功能
- **全局热键**: F9 启动，F10 停止
- **预设管理**: 保存/加载点击配置预设
- **窗口透明**: 0-100% 透明度可调
- **窗口置顶**: 始终显示在最前
- **多窗口支持**: 独立的日志窗口

### 实时监控
- **运行日志**: 实时显示点击操作记录
- **日志窗口**: 独立窗口，支持拖拽移动
- **日志过滤**: 按级别(DEBUG/INFO/WARN/ERROR)、关键词、时间过滤
- **日志导出**: 支持 TXT/JSON/CSV 格式导出
- **点击统计**: 运行时长、总点击次数、平均 CPS

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 语言 | Dart 3.x |
| 状态管理 | Riverpod |
| 本地存储 | Hive |
| 窗口管理 | window_manager |
| 键鼠模拟 | mouse / hotkey_manager |
| 路由 | go_router |

## 项目结构

```
lib/
├── core/                    # 核心配置
│   ├── constants/          # 常量定义
│   ├── router.dart         # 路由配置
│   └── theme/              # 主题配置
├── domain/                 # 领域层
│   └── entities/          # 实体模型
├── infrastructure/         # 基础设施层
│   ├── hotkey/             # 热键服务
│   ├── mouse/              # 鼠标服务
│   └── services/           # 核心服务
├── presentation/           # 表现层
│   ├── pages/              # 页面
│   ├── providers/          # 状态管理
│   └── widgets/            # 组件
└── l10n/                   # 国际化
```

## 开发进度

| 阶段 | 里程碑 | 状态 |
|------|--------|------|
| 第一阶段 | M1: MVP | ✅ 已完成 |
| 第二阶段 | M2: 日志系统 | ✅ 已完成 |
| 第三阶段 | M3: 脚本版 | ⏳ 待开发 |
| 第四阶段 | M4: 智能版 | ⏳ 待开发 |
| 第五阶段 | M5: 发布 | ⏳ 待开发 |

**当前版本**: v0.2.0

## 构建运行

### 环境要求
- Flutter SDK 3.x
- Dart SDK 3.x

### 运行命令

```bash
# 获取依赖
flutter pub get

# 运行项目
flutter run -d <platform>
# 示例: flutter run -d macos
#       flutter run -d windows
#       flutter run -d linux

# 构建发布
flutter build macos
flutter build windows
flutter build linux
```

## 文档

- [开发计划](./docs/开发计划.md)
- [需求规格说明书](./docs/需求规格说明书.md)

## 许可证

MIT License

---

**文档版本**: v1.2  
**更新日期**: 2026年2月22日
