# Flip Moment - IFLOW 项目文档

## 项目概述

Flip Moment 是一个基于 Flutter 开发的决策辅助应用，采用多主题皮肤系统，提供复古、治愈、赛博和许愿四种不同的视觉和交互体验。应用核心功能是帮助用户通过动画交互做出随机决策，同时保存历史记录。

### 核心特性

- **多主题皮肤系统**: 支持复古(vintage)、治愈(healing)、赛博(cyber)、许愿(wish)四种皮肤模式
- **动态交互体验**: 每种皮肤都有独特的动画效果和物理模拟
- **国际化支持**: 支持中文和英文两种语言
- **历史记录**: 保存用户的决策历史
- **硬件交互**: 支持音效播放和震动反馈

## 技术架构

### 架构模式
采用 **Feature-First + Layered Architecture** 架构模式，分为三层：
- **Data (数据层)**: 数据持久化和存储
- **Domain (领域层)**: 业务逻辑和实体
- **Presentation (表现层)**: UI 界面和交互

### 核心组件

#### 皮肤引擎 (Skin Engine)
- **位置**: `lib/core/skin_engine/`
- **设计模式**: 抽象工厂模式
- **核心接口**: `AppSkin` 定义了所有皮肤必须实现的协议
- **管理方式**: 通过 Riverpod 进行状态管理

#### 皮肤类型
1. **VintageSkin**: 复古风格，使用 3D 硬币翻转动画
2. **HealingSkin**: 治愈风格，使用 Rive 矢量动画
3. **CyberSkin**: 赛博朋克风格，科技感 UI
4. **WishSkin**: 许愿风格，梦幻视觉效果

## 构建和运行

### 环境要求
- Flutter SDK: >=3.10.1
- Dart SDK: >=3.10.1

### 安装依赖
```bash
flutter pub get
```

### 代码生成
```bash
flutter packages pub run build_runner build
```

### 运行应用
```bash
flutter run
```

### 构建应用
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

### 测试
```bash
flutter test
```

### 代码分析
```bash
flutter analyze
```

## 开发约定

### 目录结构
```
lib/
├── core/                   # 核心通用模块
│   ├── constants/          # 全局常量
│   ├── skin_engine/        # 皮肤引擎核心
│   ├── skins/             # 皮肤实现
│   ├── theme/             # 基础主题
│   └── utils/             # 工具类
├── features/              # 按功能划分
│   ├── decision/          # 决策功能
│   ├── history/           # 历史记录
│   └── settings/          # 设置功能
├── l10n/                  # 国际化文件
└── services/              # 第三方服务封装
```

### 代码规范
- 使用 `flutter_lints` 进行代码检查
- 遵循 Dart 官方代码风格指南
- 使用 Riverpod 进行状态管理
- 优先使用代码生成工具减少样板代码

### 状态管理
- 使用 **Riverpod** 作为主要状态管理方案
- 通过 `riverpod_generator` 进行代码生成
- 状态提供者统一管理在 `providers/` 目录下

### 数据持久化
- 使用 **Hive** 作为本地数据库
- 数据模型使用 **Freezed** 生成不可变类
- 数据访问通过 Repository 模式抽象

## 核心依赖

### 主要框架
- `flutter_riverpod: ^2.5.1` - 状态管理
- `go_router: ^13.2.0` - 路由管理
- `hive: ^2.2.3` - 本地数据库

### 视觉渲染
- `rive: ^0.13.4` - 矢量动画运行时
- `model_viewer_plus: ^1.7.0` - 3D 模型渲染
- `flutter_animate: ^4.5.0` - 声明式动画
- `google_fonts: ^6.2.1` - 动态字体

### 硬件交互
- `sensors_plus: ^5.0.1` - 传感器数据
- `audioplayers: ^6.0.0` - 音效播放
- `permission_handler: ^11.3.0` - 权限管理

### 代码生成
- `build_runner: ^2.4.9` - 代码生成工具
- `riverpod_generator: ^2.4.0` - Riverpod 代码生成
- `freezed: ^2.4.7` - 不可变数据类生成
- `hive_generator: ^2.0.1` - Hive 数据模型生成

## 开发流程

### 添加新皮肤
1. 在 `lib/core/skins/` 目录创建新的皮肤实现类
2. 实现 `AppSkin` 接口的所有方法
3. 在 `skin_protocol.dart` 中添加新的 `SkinMode` 枚举值
4. 在 `skin_provider.dart` 中注册新皮肤
5. 添加相关的本地化文本

### 添加新功能
1. 在 `lib/features/` 下创建新的功能目录
2. 按照 `data/domain/presentation` 组织代码
3. 创建相应的测试文件
4. 更新路由配置（如需要）

### 国际化更新
1. 更新 `lib/l10n/app_*.arb` 文件
2. 运行 `flutter gen-l10n` 生成本地化代码
3. 在代码中使用 `AppLocalizations.of(context)`

## 项目特色

### 多态皮肤系统
通过抽象工厂模式实现了完全解耦的皮肤系统，UI 组件只需要依赖 `AppSkin` 接口，不关心具体实现细节。

### 声明式动画
使用 `flutter_animate` 库实现流畅的动画效果，每种皮肤都有独特的动画曲线和时长。

### 响应式设计
支持不同屏幕尺寸的适配，确保在手机和平板上都有良好的用户体验。

### 性能优化
- 使用 Hive 实现高性能本地存储
- 动画资源按需加载
- 内存管理优化，避免内存泄漏

## 注意事项

- 皮肤切换是资源密集型操作，需要做好资源管理和内存释放
- 音效文件需要根据当前皮肤预加载
- 动画控制器在不使用时需要及时释放
- 数据库操作应该在后台线程执行