# CodeBuddyAppDemo - Swift+UIKit Dashboard

这是一个基于Swift和UIKit实现的移动应用主页面，根据Figma设计文件创建。

## 项目结构

```
CodeBuddyAppDemo/
├── DashboardViewController.swift    # 主页面控制器
├── DashboardCardView.swift          # 卡片组件
├── DashboardLargeButton.swift       # 大按钮组件
├── FontManager.swift               # 字体管理器
├── AppDelegate.swift               # 应用委托
├── SceneDelegate.swift             # 场景委托
├── ViewController.swift            # 基础视图控制器
└── Assets/
    └── CodeBubbyAssets/4_1/       # Figma设计资源
```

## 功能特性

- **响应式布局**: 使用Auto Layout实现自适应布局
- **卡片式设计**: 四个功能卡片（SOS、安全、环境、可持续发展）
- **大按钮区域**: 两个主要功能按钮（垃圾车路线、历史记录）
- **字体管理**: 支持Montserrat字体
- **导航控制**: 使用UINavigationController

## 设计说明

页面基于Figma设计实现，包含：
- 欢迎标题和用户姓名显示
- 四个功能卡片网格布局
- 两个底部大按钮
- 西班牙语界面（根据设计需求）

## 运行方式

1. 打开 `CodeBuddyAppDemo.xcodeproj`
2. 选择模拟器（推荐iPhone 15）
3. 点击运行按钮或使用 `Cmd + R`

## 技术栈

- **语言**: Swift 5.0+
- **框架**: UIKit
- **布局**: Auto Layout
- **架构**: MVC模式