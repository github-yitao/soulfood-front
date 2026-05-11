# SoulFood Front

一个基于 Flutter 的「今天吃什么」决策应用前端项目。

当前阶段以首页原型和基础工程结构为主，后续会逐步接入真实决策逻辑、历史记录和个人偏好能力。

目前已补充基础路由层和三个底部导航页面占位（首页/记录/我的）。

## 技术栈

- Flutter
- Dart
- Material 3

## 快速开始

### 1. 环境准备

- Flutter SDK（建议与项目 Dart 版本兼容）
- Xcode（iOS 构建）
- Android Studio / Android SDK（Android 构建）

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 本地运行

```bash
flutter run
```

### 4. 静态检查与测试

```bash
flutter analyze
flutter test
```

## 目录结构

```text
lib/
	main.dart                # 应用入口
	app.dart                 # MaterialApp 与全局主题 + 路由注册
	routing/
		app_routes.dart        # 路由常量
	pages/
		root_page.dart         # 根页面（底部导航容器）
		home_page.dart         # 首页内容
		records_page.dart      # 记录页占位
		profile_page.dart      # 我的页占位
	widgets/
		feature_card.dart      # 可复用 UI 组件
```

## 开发规范（基础）

- 保持单一职责：页面放在 pages，复用组件放在 widgets。
- 优先使用 package import，避免跨目录相对路径引用。
- 提交前至少执行一次 flutter analyze。
- 新功能开发使用 feature 分支，例如 feat/zjm。

## Git 工作流建议

1. 从 main 拉取并创建功能分支。
2. 在功能分支内完成开发与自测。
3. 提交 PR 合并回 main。

示例：

```bash
git checkout main
git pull
git checkout -b feat/your-name
```
