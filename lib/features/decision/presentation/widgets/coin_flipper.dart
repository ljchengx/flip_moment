import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../l10n/app_localizations.dart';

class CoinFlipper extends StatefulWidget {
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
  State<CoinFlipper> createState() => _CoinFlipperState();
}

class _CoinFlipperState extends State<CoinFlipper> with SingleTickerProviderStateMixin {
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
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _flip() {
    if (_controller.isAnimating) return;

    widget.onFlipStart?.call();
    HapticFeedback.heavyImpact();

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
    return GestureDetector(
      onTap: _flip,
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
    );
  }

  Widget _buildCoinVisual(bool isFront) {
    // 视觉层保持不变
    // 修正：如果是反面，需要预先旋转180度修正文字方向
    // 这里我们直接在 build 里处理文字方向，不依赖 Transform，逻辑更简单

    return Container(
      width: 200, // 稍微缩小一点尺寸
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.skin.primaryAccent,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.skin.primaryAccent,
            Color.lerp(widget.skin.primaryAccent, Colors.white, 0.5)!,
            widget.skin.primaryAccent,
            Color.lerp(widget.skin.primaryAccent, Colors.black, 0.3)!,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
        boxShadow: [
          // 仅在硬币自身加一点厚度阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 2,
          )
        ],
        border: Border.all(color: widget.skin.backgroundSurface, width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 170, height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: widget.skin.backgroundSurface.withOpacity(0.2), width: 1.5),
            ),
          ),
          // 核心修正：文字翻转处理
          // 如果显示的是反面 (isFront == false)，在这个 3D 容器里文字其实是倒着的
          // 所以我们需要把文字单独转正，或者根据面来渲染
          Transform(
            alignment: Alignment.center,
            transform: isFront ? Matrix4.identity() : (Matrix4.identity()..rotateX(math.pi)),
            child: Text(
              isFront ? AppLocalizations.of(context)!.resultYes : AppLocalizations.of(context)!.resultNo,
              style: widget.skin.displayFont.copyWith(
                fontSize: 60,
                color: widget.skin.backgroundSurface.withOpacity(0.85),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}