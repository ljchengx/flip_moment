import 'package:flutter/material.dart';

// 定义双模态枚举
enum SkinMode { vintage, healing }

/// [AppSkin] 抽象基类
/// 这是所有 UI 组件唯一依赖的对象。
abstract class AppSkin {
  // 基础标识
  SkinMode get mode;

  // --- 🎨 语义化颜色 (Semantic Colors) ---
  Color get backgroundSurface;  // 背景
  Color get primaryAccent;      // 主强调色 (金/绿)
  Color get secondaryAccent;    // 次强调色 (红/粉)
  Color get textPrimary;        // 正文

  // --- ✒️ 语义化字体 (Semantic Typography) ---
  TextStyle get displayFont;    // 大标题
  TextStyle get bodyFont;       // 正文
  TextStyle get monoFont;       // 数字/日期

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