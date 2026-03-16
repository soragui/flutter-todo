# Flutter 待办事项应用

一个功能完整的 Flutter 待办事项应用，使用 Material Design 3 和 Provider 状态管理。

## 功能特性

- ✅ **添加任务** - 快速添加新任务，支持设置截止日期
- ✅ **标记完成** - 点击复选框或滑动切换任务完成状态
- ✅ **编辑任务** - 点击编辑按钮修改任务内容
- ✅ **删除任务** - 左滑或点击删除按钮删除任务
- ✅ **筛选任务** - 支持筛选"全部"/"进行中"/"已完成"
- ✅ **本地存储** - 使用 SharedPreferences 持久化存储
- ✅ **Material Design 3** - 现代化美观的 UI 设计
- ✅ **深色模式** - 自动跟随系统主题

## 项目结构

```
lib/
├── main.dart                 # 应用入口，主题配置
├── models/
│   └── task.dart            # 任务数据模型
├── providers/
│   └── task_provider.dart   # 任务状态管理 (Provider)
├── services/
│   └── storage_service.dart # 本地存储服务
├── screens/
│   └── home_screen.dart     # 主屏幕
└── widgets/
    ├── task_item.dart       # 任务列表项
    ├── add_task_dialog.dart # 添加任务对话框
    ├── filter_chip_bar.dart # 筛选芯片栏
    └── empty_state.dart     # 空状态视图
```

## 技术栈

- **Flutter** - UI 框架
- **Provider** - 状态管理
- **SharedPreferences** - 本地数据持久化
- **UUID** - 生成唯一任务 ID
- **Material Design 3** - 设计系统

## 运行方法

### 前提条件

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (用于模拟器)

### 安装依赖

```bash
cd ~/.openclaw/workspace-coder/todo_app
flutter pub get
```

### 运行应用

```bash
# 运行调试版本
flutter run

# 或指定设备
flutter run -d <device_id>
```

### 构建发布版本

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (需要 Mac 和 Xcode)
flutter build ios
```

## 使用说明

1. **添加任务**: 点击右下角"新任务"按钮，输入任务内容，可选设置截止日期
2. **完成任务**: 点击任务左侧的圆形复选框
3. **编辑任务**: 点击任务右侧的编辑图标
4. **删除任务**: 左滑任务项或点击删除图标
5. **筛选任务**: 点击顶部的筛选芯片切换视图
6. **清除已完成**: 点击右上角清除按钮批量删除已完成任务

## 截图

（应用运行后截图可添加至此）

## 许可证

MIT License
