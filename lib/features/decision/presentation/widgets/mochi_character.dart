import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/skin_engine/skin_protocol.dart';

class MochiCharacter extends StatefulWidget {
  final AppSkin skin;
  final VoidCallback? onTap;
  final Function(String result)? onResult;

  const MochiCharacter({
    super.key,
    required this.skin,
    this.onTap,
    this.onResult,
  });

  @override
  State<MochiCharacter> createState() => _MochiCharacterState();
}

class _MochiCharacterState extends State<MochiCharacter> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _jumpAnim;

  // 眨眼控制器
  late AnimationController _blinkController;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 1. 主物理控制器 (负责跳跃和弹性)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 弹性缩放 (模拟果冻落地后的抖动)
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 20), // 蓄力变扁
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.2), weight: 20), // 弹起拉长
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20), // 落地微扁
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40), // 恢复
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 跳跃高度
    _jumpAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 20),   // 蓄力不动
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -150.0), weight: 30),// 起飞
      TweenSequenceItem(tween: Tween(begin: -150.0, end: 0.0), weight: 50),// 降落
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final result = math.Random().nextBool() ? "YES" : "NO";
        widget.onResult?.call(result);
        HapticFeedback.selectionClick(); // 轻触反馈
        setState(() => _isProcessing = false);
      }
    });

    // 2. 眨眼逻辑 (独立循环)
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 1000 + math.Random().nextInt(2000)), () async {
      if (!mounted) return;
      await _blinkController.forward();
      await _blinkController.reverse();
      _startBlinking();
    });
  }

  void _onTap() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    widget.onTap?.call();
    HapticFeedback.lightImpact(); // 按下时的轻微反馈
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _blinkController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. 影子 (随高度变小变淡)
              Transform.translate(
                offset: const Offset(0, 100),
                child: Opacity(
                  opacity: 1.0 - (_jumpAnim.value.abs() / 200).clamp(0.0, 0.8),
                  child: Transform.scale(
                    scale: 1.0 - (_jumpAnim.value.abs() / 300),
                    child: Container(
                      width: 120, height: 20,
                      decoration: BoxDecoration(
                        color: widget.skin.textPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. 团子本体
              Transform.translate(
                offset: Offset(0, _jumpAnim.value),
                child: Transform.scale(
                  scaleY: _scaleAnim.value, // Y轴形变 (变扁/拉长)
                  // 保持体积守恒：变扁时变宽
                  scaleX: 1.0 + (1.0 - _scaleAnim.value) * 0.5,
                  child: Container(
                    width: 200,
                    height: 180, // 略微扁平的初始形状
                    decoration: BoxDecoration(
                      color: widget.skin.primaryAccent, // 抹茶绿
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.skin.primaryAccent.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: _buildFace(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFace() {
    // 简单的豆豆眼表情
    return Stack(
      children: [
        // 左眼
        Positioned(
          left: 60, top: 70,
          child: _buildEye(),
        ),
        // 右眼
        Positioned(
          right: 60, top: 70,
          child: _buildEye(),
        ),
        // 腮红 (可爱关键)
        Positioned(
          left: 45, top: 90,
          child: Container(
            width: 20, height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB7B2).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          right: 45, top: 90,
          child: Container(
            width: 20, height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB7B2).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // 嘴巴 (简单的弧线)
        Positioned(
          left: 95, top: 85,
          child: Container(
            width: 10, height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.skin.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEye() {
    // 眨眼动画：高度变为 0
    final eyeHeight = 12.0 * (1.0 - _blinkController.value);
    return Container(
      width: 12,
      height: eyeHeight,
      decoration: BoxDecoration(
        color: widget.skin.textPrimary,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}