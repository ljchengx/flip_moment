import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    // 拍立得通常比较窄长，调整宽度比例
    final cardWidth = screenWidth * 0.80; 

    // 判断是否为 Vintage 模式，如果是则应用特殊样式，否则保留原有逻辑（保持兼容性）
    // 或者直接修改所有模式，这里演示直接修改为拍立得风格（更具特色）
    
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
          // 拍立得经典布局：底部留白极大
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), 
          decoration: BoxDecoration(
            color: const Color(0xFFF6F2E9), // 🎞️ 米白色相纸质感
            borderRadius: BorderRadius.circular(2), // 拍立得几乎是直角
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(5, 10), // 悬浮感投影
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 黑色显影区域 (AspectRatio 1:1)
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818), // 深黑底色
                    // 模拟镜头暗角 (Vignette)
                    gradient: RadialGradient(
                      colors: [const Color(0xFF2A2A2A), const Color(0xFF080808)],
                      radius: 0.85,
                    ),
                  ),
                  child: Center(
                    // 结果文字：发光印章效果
                    child: Text(
                      widget.result.toUpperCase(),
                      style: GoogleFonts.playfairDisplay( // 复古衬线体
                        fontSize: 72,
                        color: const Color(0xFFFF3B30).withOpacity(0.9), // 烧灼红
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          // 霓虹/显影液辉光
                          BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 30, spreadRadius: 5)
                        ]
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // 2. 底部手写备注区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 左侧：手写签名
                  Text(
                    "The Decision", 
                    style: GoogleFonts.cedarvilleCursive(
                      fontSize: 24, 
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3333) // 墨水色
                    )
                  ),
                  // 右侧：打字机日期
                  Text(
                    "NOV 27, '25", 
                    style: GoogleFonts.courierPrime(
                      fontSize: 12, 
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                    )
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