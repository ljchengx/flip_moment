import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/cooldown_provider.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/services/audio/audio_service.dart';
import '../../../../core/services/haptics/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class CoinFlipper extends ConsumerStatefulWidget {
  final AppSkin skin;
  final VoidCallback? onFlipStart;
  final Function(String result)? onFlipEnd;

  const CoinFlipper({
    super.key,
    required this.skin,
    this.onFlipStart,
    this.onFlipEnd,
  });

  @override
  ConsumerState<CoinFlipper> createState() => _CoinFlipperState();
}

class _CoinFlipperState extends ConsumerState<CoinFlipper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _heightAnim;
  late Animation<double> _shadowScaleAnim;
  late Animation<double> _wobbleAnim; // 新增：微小的侧向摆动，增加真实感

  bool _isHeads = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // 稍微调快一点点节奏
    );

    // 1. 旋转动画：疯狂旋转 X 轴
    _rotationAnim = Tween<double>(begin: 0, end: 8 * 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    // 2. 高度动画：纯粹的抛物线
    _heightAnim = TweenSequence<double>([
      // 上升阶段：减速 (easeOut)
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -250.0).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 45
      ),
      // 下落阶段：加速 (easeIn) + 弹跳 (Bounce)
      TweenSequenceItem(
          tween: Tween(begin: -250.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)),
          weight: 55
      ),
    ]).animate(_controller);

    // 3. 阴影动画
    _shadowScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 55),
    ]).animate(_controller);

    // 4. 侧向摆动：模拟空气阻力带来的轻微晃动 (Z轴)
    _wobbleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFlipEnd?.call(_isHeads ? "YES" : "NO");
        ref.read(hapticServiceProvider).medium();
      }
    });
  }

  void _flip() {
    if (_controller.isAnimating) return;
    
    // Check cooldown before allowing flip
    // Requirements: 1.2, 2.2
    if (!ref.read(cooldownProvider.notifier).canPerformDecision()) {
      ref.read(hapticServiceProvider).light(); // Feedback that action is blocked
      return;
    }

    // 🎵 播放点击音效 (核心插入点)
    ref.read(audioServiceProvider).play(SoundType.tap, widget.skin.mode);

    widget.onFlipStart?.call();
    ref.read(hapticServiceProvider).heavy();

    final bool nextResultIsHeads = math.Random().nextBool();

    // 基础圈数：8圈
    // 如果结果是反面，多转半圈 (PI)
    double targetRotation = 8 * 2 * math.pi;
    if (!nextResultIsHeads) {
      targetRotation += math.pi;
    }

    // 重新配置动画
    _rotationAnim = Tween<double>(begin: 0, end: targetRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _isHeads = nextResultIsHeads;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch cooldown state for disabled visual
    // Requirements: 2.2
    final cooldownState = ref.watch(cooldownProvider);
    final isDisabled = cooldownState.isActive;
    
    return GestureDetector(
      onTap: _flip,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _rotationAnim.value;
          // 计算这一帧哪一面朝上
          final isFrontVisible = (math.cos(angle) >= 0);

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // 允许阴影超出边界
            children: [
              // --- 1. 影子 (始终在地面，只缩放，不位移) ---
              Transform.translate(
                offset: const Offset(0, 120), // 固定在硬币起跳点的下方
                child: Transform.scale(
                  scale: _shadowScaleAnim.value,
                  child: Container(
                    width: 80, height: 16,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(0.4))],
                    ),
                  ),
                ),
              ),

              // --- 2. 硬币运动系统 (解耦核心) ---
              // 层级 A: 负责位移 (上下飞)
              Transform.translate(
                offset: Offset(0, _heightAnim.value),
                child: Transform(
                  alignment: Alignment.center,
                  // 层级 B: 负责自转 (3D翻转)
                  // 这里的 Matrix 只处理旋转，不受位移影响
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 透视感 (调小了一点，避免过度变形)
                    ..rotateX(angle)        // 主翻转
                    ..rotateZ(_wobbleAnim.value), // 增加一点点侧倾，更自然
                  child: _buildCoinVisual(isFrontVisible),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildCoinVisual(bool isFront) {
    final String imagePath = isFront
        ? 'assets/images/vintage_coin_heads.png'
        : 'assets/images/vintage_coin_tails.png';

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            // ✨ [优化2] 光影修正：
            // 当显示反面时，因为容器翻转了，我们需要反向偏移阴影，
            // 才能保证视觉上阴影始终是"投向下方"的。
            offset: Offset(0, isFront ? 4 : -4),
            blurRadius: 4,
          )
        ],
      ),
      child: Transform(
        alignment: Alignment.center,
        // ✨ [优化1] 物理修正：
        // 只需 rotateX(pi) 即可抵消父容器的翻转，让图片正立显示。
        // 去掉了 rotateZ，防止文字左右镜像。
        transform: isFront
            ? Matrix4.identity()
            : (Matrix4.identity()..rotateX(math.pi)),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          // 兜底逻辑保持不变，很棒
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.skin.primaryAccent,
            ),
            child: Center(
              child: Text(
                isFront ? "H" : "T",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: widget.skin.backgroundSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}