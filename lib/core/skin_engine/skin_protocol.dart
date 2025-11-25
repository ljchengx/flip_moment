import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// 定义双模态枚举
enum SkinMode {
  vintage,
  healing,
  cyber, // 新增
  wish, // 新增
}

extension SkinModeX on SkinMode {
  // 获取本地化标题
  String getTitle(AppLocalizations loc) {
    switch (this) {
      case SkinMode.vintage: return loc.themeVintage;
      case SkinMode.healing: return loc.themeHealing;
      case SkinMode.cyber: return loc.themeCyber;
      case SkinMode.wish: return loc.themeWish;
    }
  }

  // 获取本地化描述 (新增)
  String getDescription(AppLocalizations loc) {
    switch (this) {
      case SkinMode.vintage: return loc.skinDescVintage;
      case SkinMode.healing: return loc.skinDescHealing;
      case SkinMode.cyber: return loc.skinDescCyber;
      case SkinMode.wish: return loc.skinDescWish;
    }
  }

  bool get isPremium {
    return this == SkinMode.cyber || this == SkinMode.wish;
  }

  Color get previewColor {
    switch (this) {
      case SkinMode.vintage: return const Color(0xFF1A1C1E);
      case SkinMode.healing: return const Color(0xFFFDFBF7);
      case SkinMode.cyber: return const Color(0xFF050505);
      case SkinMode.wish: return const Color(0xFF2B5876);
    }
  }
}

/// [AppSkin] 抽象基类
/// 这是所有 UI 组件唯一依赖的对象。
abstract class AppSkin {
  // 基础标识
  SkinMode get mode;

  // --- 🎨 语义化颜色 (Semantic Colors) ---
  Color get backgroundSurface; // 背景
  Color get primaryAccent; // 主强调色 (金/绿)
  Color get secondaryAccent; // 次强调色 (红/粉)
  Color get textPrimary; // 正文

  // --- ✒️ 语义化字体 (Semantic Typography) ---
  TextStyle get displayFont; // 大标题
  TextStyle get bodyFont; // 正文
  TextStyle get monoFont; // 数字/日期

  // --- 🧩 动态资源 (Dynamic Assets) ---
  /// 核心互动组件构建器
  /// 传入 [controller] 以便外部控制动画进度
  Widget buildInteractiveHero({
    required AnimationController controller,
    required VoidCallback onTap,
  });

  // --- ⚡ 物理参数 (Physics) ---
  Curve get animationCurve;

  Duration get animationDuration;

  // --- 👤 个人主页专用样式 ---
  /// 头部背景渐变 (模拟皮质或卧室光感)
  Gradient get profileHeaderGradient;

  /// 卡片背景色
  Color get cardBackgroundColor;

  /// 头像边框装饰器 (返回 BoxBorder 或 ShapeBorder)
  BoxBorder get avatarBorder;

  /// 宫格图标的风格 (是否圆润，是否扁平)
  double get cardBorderRadius;
}
