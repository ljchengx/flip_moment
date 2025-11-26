import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 必装依赖
import '../../../../core/skins/cyber_skin.dart';

class LiquidMetalBall extends StatefulWidget {
  final CyberSkin skin;
  final Function(String)? onResult;

  const LiquidMetalBall({super.key, required this.skin, this.onResult});

  @override
  State<LiquidMetalBall> createState() => _LiquidMetalBallState();
}

class _LiquidMetalBallState extends State<LiquidMetalBall> with TickerProviderStateMixin {
  // 液态蠕动控制器
  late AnimationController _blobController;
  // 充能控制器
  late AnimationController _chargeController;

  // 状态
  bool _isCharging = false;
  String? _displayResult; // 最终结果
  String _decodingText = ""; // 正在跳动的乱码
  Timer? _decodeTimer;

  @override
  void initState() {
    super.initState();
    // 1. 蠕动动画 (无限循环)
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 2. 充能动画 (用于震动和颜色变化)
    _chargeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // 高频震动
    );
  }

  @override
  void dispose() {
    _blobController.dispose();
    _chargeController.dispose();
    _decodeTimer?.cancel();
    super.dispose();
  }

  // --- 交互逻辑 ---

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isCharging = true;
      _displayResult = null;
      _decodingText = "AWAITING...";
    });
    _chargeController.repeat(reverse: true);
    HapticFeedback.heavyImpact(); // 初始重击
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!_isCharging) return;

    setState(() => _isCharging = false);
    _chargeController.stop();
    _chargeController.reset();

    // 触发结果
    _startDecodingSequence();
  }

  void _startDecodingSequence() {
    HapticFeedback.mediumImpact();
    // 1. 随机生成结果
    final isYes = math.Random().nextBool();
    final finalString = isYes ? "YES" : "NO";

    // 2. 乱码动画 (解码过程)
    int step = 0;
    _decodeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        // 生成随机乱码，长度与结果一致
        _decodingText = List.generate(
            finalString.length,
                (index) => String.fromCharCode(33 + math.Random().nextInt(90)) // ASCII 乱码
        ).join();
      });

      step++;
      HapticFeedback.selectionClick(); // 滴答滴答声

      // 3. 动画结束 (1秒后)
      if (step > 15) {
        timer.cancel();
        setState(() {
          _decodingText = finalString;
          _displayResult = finalString;
        });
        HapticFeedback.heavyImpact(); // 最终确认反馈
        widget.onResult?.call(finalString);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 关键：使用长按交互
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      // 兼容点击：如果用户只是点击，提示按住
      onTap: () {
        HapticFeedback.lightImpact();
        // 可以加一个 Tooltip 或者 Toast 提示 "HOLD TO CHARGE"
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 液态球体
          _buildBlob(),

          // 2. 文字显示 (叠加在球体上)
          if (_decodingText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: Colors.black.withOpacity(0.6), // 半透黑底增加可读性
              child: Text(
                _decodingText,
                style: widget.skin.displayFont.copyWith(
                  color: _displayResult != null ? widget.skin.primaryAccent : Colors.white,
                  fontSize: 40,
                  letterSpacing: 4.0,
                ),
              )
                  .animate(target: _isCharging ? 1 : 0) // 充能时文字闪烁
                  .shake(hz: 8, offset: const Offset(2, 2)), // 只有 flutter_animate 能这么优雅地写抖动
            ),

          // 3. 充能时的粒子效果 (可选，用 Flutter Animate 简单模拟)
          if (_isCharging)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.skin.primaryAccent.withOpacity(0.5), width: 1),
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(begin: Offset(1,1), end: Offset(1.5, 1.5), duration: 600.ms).fadeOut(),
            )
        ],
      ),
    );
  }

  Widget _buildBlob() {
    return AnimatedBuilder(
      animation: Listenable.merge([_blobController, _chargeController]),
      builder: (context, child) {
        // 动态计算圆角，模拟蠕动
        // 使用正弦波组合
        final t = _blobController.value * 2 * math.pi;
        final wobble = _isCharging ? 20.0 : 0.0; // 充能时剧烈变形

        // 四个角的半径动态变化
        final r1 = 100 + 10 * math.sin(t) + math.Random().nextDouble() * wobble;
        final r2 = 100 + 10 * math.cos(t + 1) + math.Random().nextDouble() * wobble;
        final r3 = 100 + 10 * math.sin(t + 2) + math.Random().nextDouble() * wobble;
        final r4 = 100 + 10 * math.cos(t + 3) + math.Random().nextDouble() * wobble;

        // 颜色变化：充能时变成电光紫，平时是液态铬
        final baseColor = _isCharging
            ? Color.lerp(widget.skin.textPrimary, widget.skin.secondaryAccent, _chargeController.value)!
            : widget.skin.textPrimary;

        return Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(r1),
              topRight: Radius.circular(r2),
              bottomLeft: Radius.circular(r3),
              bottomRight: Radius.circular(r4),
            ),
            boxShadow: [
              // 荧光辉光
              BoxShadow(
                color: _isCharging ? widget.skin.secondaryAccent : widget.skin.primaryAccent.withOpacity(0.3),
                blurRadius: _isCharging ? 30 : 15,
                spreadRadius: _isCharging ? 5 : 0,
              ),
              // 内部高光 (模拟金属反光)
              const BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                offset: Offset(-10, -10),
                blurStyle: BlurStyle.inner, // 内发光
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(10, 10),
                blurStyle: BlurStyle.inner, // 内阴影
              ),
            ],
            // 简单的径向渐变模拟球体感
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                Colors.white,
                baseColor,
                Colors.black,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        )
            .animate(target: _isCharging ? 1 : 0)
            .shake(hz: 20, offset: const Offset(3, 3)); // 充能时球体高频震动
      },
    );
  }
}