import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/skin_engine/skin_protocol.dart';
import '../../../core/skin_engine/skin_provider.dart';
import '../../../core/services/haptics/haptic_service.dart';
import '../../decision/presentation/decision_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // 🔮 随机运势文案池
  final List<String> _fortunes = [
    "今日宜：直觉行事",
    "宜：喝一杯冰美式",
    "忌：犹豫不决",
    "运势：大吉",
    "听从内心的声音",
    "答案就在下一秒",
  ];
  late String _dailyFortune;

  @override
  void initState() {
    super.initState();
    _dailyFortune = _fortunes[math.Random().nextInt(_fortunes.length)];
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1. 预加载逻辑 (如加载 heavy assets) 可放这里
    // 2. 稍微震动一下，提示"系统启动"
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(hapticServiceProvider).light();
    });

    // 3. 等待动画结束 (1.5秒仪式感)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 4. 无缝转场进入主页
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DecisionScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前皮肤，决定开场秀
    final skin = ref.watch(currentSkinProvider);

    return Scaffold(
      backgroundColor: skin.backgroundSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // A. 核心动画层
          Center(child: _buildThemeOpening(skin)),

          // B. 底部运势文案 (淡入停留)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _dailyFortune,
                style: skin.bodyFont.copyWith(
                  fontSize: 14,
                  color: skin.textPrimary.withOpacity(0.6),
                  letterSpacing: 2.0,
                ),
              )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 800.ms), // 晚一点出现
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOpening(AppSkin skin) {
    switch (skin.mode) {
      case SkinMode.vintage:
        return _VintageShutter(skin: skin);
      case SkinMode.healing:
        return _HealingAwakening(skin: skin);
      case SkinMode.cyber:
        return _CyberBoot(skin: skin);
      case SkinMode.wish:
        return _WishMist(skin: skin);
    }
  }
}

// --- 🎥 方案一：Vintage - "光阴的快门" ---
class _VintageShutter extends StatelessWidget {
  final AppSkin skin;
  const _VintageShutter({required this.skin});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. 文案先出
        Text(
          "Capture the Decision.",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            color: skin.primaryAccent,
            fontStyle: FontStyle.italic,
          ),
        ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),

        // 2. 机械光圈 (用一个黑色的圆形遮罩模拟打开效果)
        // 这里反向操作：原本全黑，中间挖孔变大
        // 简化实现：一个巨大的黑色边框圆，边框宽度逐渐变小，或者孔径变大
        // 为了视觉效果，我们用一个 AnimatedBuilder 画一个收缩的黑色光圈
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
          builder: (context, value, child) {
            // value 0 -> 1 (打开过程)
            // 模拟光圈叶片旋转打开 (简化为缩放)
            return Transform.scale(
              scale: 0.5 + value * 20, // 从小孔变到无限大
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // 模拟光圈边缘
                  border: Border.all(
                    color: skin.primaryAccent.withOpacity(1.0 - value), // 逐渐消失
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- 🍡 方案二：Healing - "团子的苏醒" ---
class _HealingAwakening extends StatelessWidget {
  final AppSkin skin;
  const _HealingAwakening({required this.skin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 团子本体
        Container(
          width: 120,
          height: 100,
          decoration: BoxDecoration(
            color: skin.primaryAccent,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Center(
            child: Text(
              "zZz...", 
              style: GoogleFonts.quicksand(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1200.ms, curve: Curves.elasticOut) // 伸懒腰
        .shake(delay: 1000.ms, hz: 4), // 醒来抖动

        const SizedBox(height: 40),
        
        Text(
          "Poke me gently ~",
          style: GoogleFonts.patrickHand( // 手写体
            fontSize: 24,
            color: skin.textPrimary,
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}

// --- 👾 方案三：Cyber - "系统接入中" ---
class _CyberBoot extends StatelessWidget {
  final AppSkin skin;
  const _CyberBoot({required this.skin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 故障文字
        Text(
          "SYSTEM_BOOT_SEQUENCE",
          style: GoogleFonts.vt323(
            fontSize: 28,
            color: const Color(0xFFCCFF00), // 酸性绿
            letterSpacing: 4.0,
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .tint(color: Colors.red, duration: 200.ms) // 颜色闪烁
        .then().tint(color: Colors.blue, duration: 200.ms)
        .then().tint(color: const Color(0xFFCCFF00), duration: 600.ms),

        const SizedBox(height: 20),

        // 进度条
        Container(
          width: 200,
          height: 4,
          color: Colors.grey[900],
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(color: const Color(0xFFCCFF00), width: 200)
                .animate()
                .scaleX(alignment: Alignment.centerLeft, duration: 1200.ms, curve: Curves.easeInOutCubicEmphasized), // 步进式加载
          ),
        ),
        
        const SizedBox(height: 10),
        Text(
          "DECODING DESTINY...",
          style: skin.monoFont.copyWith(fontSize: 12),
        ).animate().fadeIn().shake(),
      ],
    );
  }
}

// --- ✨ 方案四：Wish - "迷雾散去" ---
class _WishMist extends StatelessWidget {
  final AppSkin skin;
  const _WishMist({required this.skin});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 底层：隐约可见的许愿池文字
        Center(
          child: Text(
            "Make a wish\ninto the galaxy.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cedarvilleCursive(
              fontSize: 32,
              color: skin.textPrimary,
            ),
          ),
        ),

        // 顶层：迷雾 (高斯模糊 + 白色遮罩)
        // 动画：模糊度逐渐降低，透明度逐渐降低
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 10.0, end: 0.0), // 模糊半径从 10 变 0
          duration: const Duration(milliseconds: 1200),
          builder: (context, sigma, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: Container(
                color: Colors.white.withOpacity(sigma / 20), // 迷雾也逐渐变透明
              ),
            );
          },
        ),
      ],
    );
  }
}