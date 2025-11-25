import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/skin_engine/skin_protocol.dart';

class ResultCard extends StatefulWidget {
  final AppSkin skin;
  final String result;
  final VoidCallback onClose;

  const ResultCard({
    super.key,
    required this.skin,
    required this.result,
    required this.onClose,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 稍微加快一点，更干脆
    );

    _opacityAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // 更有弹性的弹出效果
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // 随机角度 (-0.05 ~ 0.05 弧度)
    final randomAngle = (math.Random().nextDouble() * 0.1) - 0.05;
    _rotateAnim = Tween<double>(begin: 0.0, end: randomAngle).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，做响应式布局
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85; // 占据 85% 宽度

    final bgColor = widget.skin.textPrimary;
    final stampColor = widget.skin.secondaryAccent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Transform.rotate(
            angle: _rotateAnim.value,
            child: Opacity(
              opacity: _opacityAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          width: cardWidth,
          // 高度自适应，但给足内边距
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              // 更加深邃的投影，营造悬浮在桌面之上的感觉
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部装饰线
              Container(width: 40, height: 4, color: Colors.black12),
              const SizedBox(height: 20),

              Text(
                "DESTINY SAYS",
                style: widget.skin.bodyFont.copyWith(
                  color: Colors.black45,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // 巨大的印章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: stampColor, width: 6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.result.toUpperCase(),
                  style: widget.skin.displayFont.copyWith(
                    fontSize: 80, // 字体极大
                    color: stampColor,
                    height: 1.0, // 紧凑行高
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 底部日期戳风格
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_outlined, size: 16, color: Colors.black26),
                  const SizedBox(width: 8),
                  Text(
                    "RECORDED ON 25.11",
                    style: widget.skin.monoFont.copyWith(
                      color: Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}