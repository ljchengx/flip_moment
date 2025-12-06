import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 移除 noise_meter 和 permission_handler 引用
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/services/audio/audio_service.dart';
import '../../../../core/services/haptics/haptic_service.dart';

class WishPond extends ConsumerStatefulWidget {
  final AppSkin skin;
  final Function(String) onResult;

  const WishPond({
    super.key,
    required this.skin,
    required this.onResult,
  });

  @override
  ConsumerState<WishPond> createState() => _WishPondState();
}

class _WishPondState extends ConsumerState<WishPond> with TickerProviderStateMixin {
  // --- 物理/交互状态 ---
  Offset _dragOffset = Offset.zero;
  final Offset _coinPosition = const Offset(0, 50); // 初始位置
  bool _isDragging = false;
  bool _isFlying = false;

  // --- 流程状态 ---
  bool _coinSunk = false;      // 硬币是否已沉入水中 (隐藏硬币)
  bool _ripplesActive = false; // 是否正在播放涟漪
  bool _bubblesActive = false; // 是否正在冒气泡
  bool _resultVisible = false; // 结果是否已显示

  String? _finalResult;

  // --- 动画控制器 ---
  late AnimationController _flightController; // 飞行
  late Animation<double> _scaleAnim;
  late Animation<Offset> _pathAnim;

  late AnimationController _rippleController; // 涟漪

  // 气泡控制器列表 (用于生成随机气泡)
  final List<BubbleData> _bubbles = [];

  @override
  void initState() {
    super.initState();
    // 1. 飞行控制器
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onCoinSplash();
      }
    });

    // 2. 涟漪控制器
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _flightController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  // --- 交互逻辑 (弹弓) ---

  void _onTapCoin() {
    if (_isFlying || _coinSunk) return;
    ref.read(hapticServiceProvider).selection();
    // 模拟向下拖拽后发射
    _dragOffset = const Offset(0, 80);
    _onPanEnd(DragEndDetails(velocity: Velocity.zero));
  }

  void _onPanStart(DragStartDetails details) {
    if (_isFlying || _coinSunk) return;
    
    // 🎵 播放水滴音效
    ref.read(audioServiceProvider).play(SoundType.tap, widget.skin.mode);
    
    _isDragging = true;
    ref.read(hapticServiceProvider).selection();
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      double dy = details.delta.dy;
      // 只能向下拉
      if (_dragOffset.dy + dy > 0) {
        _dragOffset += Offset(details.delta.dx * 0.5, dy * 0.5);
      }
      // 限制最大拉伸
      if (_dragOffset.distance > 150) {
        _dragOffset = Offset.fromDirection(_dragOffset.direction, 150);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    if (_dragOffset.distance < 10) {
      setState(() => _dragOffset = Offset.zero);
      return;
    }

    // 发射!
    _isFlying = true;
    ref.read(hapticServiceProvider).heavy();

    // 计算落点 (反向抛物线)
    final targetY = -200.0 - (_dragOffset.dy * 1.5);
    final targetX = -_dragOffset.dx * 1.5;

    _pathAnim = Tween<Offset>(
      begin: _coinPosition + _dragOffset,
      end: Offset(targetX, targetY),
    ).animate(CurvedAnimation(parent: _flightController, curve: Curves.easeOutQuad));

    // 近大远小
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _flightController, curve: Curves.easeOutQuad),
    );

    setState(() => _dragOffset = Offset.zero);
    _flightController.forward();
  }

  // --- 核心流程控制 ---

  // 1. 硬币入水瞬间
  void _onCoinSplash() {
    ref.read(hapticServiceProvider).medium(); // 入水震动

    setState(() {
      _coinSunk = true;      // 隐藏硬币
      _ripplesActive = true; // 激活涟漪
    });

    _rippleController.forward(from: 0.0); // 播放涟漪动画

    // 生成结果
    _finalResult = math.Random().nextBool() ? "YES" : "NO";

    // 2. 倒计时 3秒 -> 冒气泡
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startBubbles();
    });
  }

  // 3. 冒气泡阶段
  void _startBubbles() {
    setState(() {
      _bubblesActive = true;
      // 生成 5 个随机气泡数据
      for (int i = 0; i < 5; i++) {
        _bubbles.add(BubbleData.random());
      }
    });

    // 4. 气泡破裂后 -> 显影
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _revealResult();
    });
  }

  // 5. 结果显影
  Future<void> _revealResult() async {
    await ref.read(hapticServiceProvider).light(); // 显影时的神圣感
    setState(() {
      _resultVisible = true;
    });

    // 通知上层 (可选延迟，让用户多看一会儿水面文字)
    if (_finalResult != null) {
      // widget.onResult(_finalResult!); // 如果你想直接弹卡片，取消注释。
      // 但在这个设计里，水面文字本身就是结果，所以我们不强制弹窗，或者延后弹窗
      Future.delayed(const Duration(seconds: 2), () {
        if(mounted) {
          // 🎵 播放结果音效
          ref.read(audioServiceProvider).play(SoundType.result, widget.skin.mode);
          widget.onResult(_finalResult!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 强制撑开尺寸
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. 水面背景 (深邃感)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.skin.backgroundSurface, // 浅水
                    widget.skin.secondaryAccent,   // 深水
                  ],
                  stops: const [0.2, 1.0],
                ),
                boxShadow: [
                  BoxShadow(color: widget.skin.secondaryAccent.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                ],
              ),
            ),
          ),

          // 2. 涟漪层 (Ripple) - 仅在硬币入水时显示
          if (_ripplesActive)
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: RipplePainter(
                    animationValue: _rippleController.value,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  size: const Size(300, 300),
                );
              },
            ),

          // 3. 结果文字 (自发光)
          if (_resultVisible)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - opacity)), // 稍微上浮的效果
                    child: Text(
                      _finalResult ?? "",
                      style: widget.skin.displayFont.copyWith(
                        fontSize: 70,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          BoxShadow(color: widget.skin.primaryAccent, blurRadius: 30, spreadRadius: 10), // 光晕
                          const BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // 4. 气泡层 (Bubbles)
          if (_bubblesActive)
            ..._bubbles.map((b) => BubbleWidget(data: b)).toList(),

          // 5. 硬币本体 (未沉底时显示)
          if (!_coinSunk)
            AnimatedBuilder(
              animation: _flightController,
              builder: (context, child) {
                Offset currentPos = _isFlying ? _pathAnim.value : (_coinPosition + _dragOffset);
                double currentScale = _isFlying ? _scaleAnim.value : 1.0;

                return Transform.translate(
                  offset: currentPos,
                  child: Transform.scale(
                    scale: currentScale,
                    child: GestureDetector(
                      onTap: _onTapCoin,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: _buildGlowingCoin(),
                    ),
                  ),
                );
              },
            ),

          // 6. 弹道辅助线
          if (_isDragging)
            CustomPaint(
              painter: SlingshotPainter(
                start: _coinPosition,
                end: _coinPosition + _dragOffset,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlowingCoin() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.skin.primaryAccent,
        boxShadow: [
          BoxShadow(color: widget.skin.primaryAccent, blurRadius: 15, spreadRadius: 1),
          const BoxShadow(color: Colors.white, blurRadius: 4, spreadRadius: -1)
        ],
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
      ),
      child: Center(
        child: Text("\$", style: TextStyle(fontSize: 32, color: widget.skin.secondaryAccent.withOpacity(0.5), fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- 🎨 辅助绘制类 ---

// 1. 涟漪绘制器
class RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RipplePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width * 0.6;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 绘制 3 圈涟漪
    for (int i = 0; i < 3; i++) {
      // 每圈稍微错开
      final double progress = (animationValue + i * 0.2) % 1.0;
      final double radius = progress * maxRadius;
      final double opacity = (1.0 - progress).clamp(0.0, 1.0); // 扩散消失

      paint.color = color.withOpacity(opacity * 0.6);
      paint.strokeWidth = 4 * (1-progress); // 越远越细

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) => true;
}

// 2. 气泡数据模型
class BubbleData {
  final double startX;
  final double size;
  final int speedMs;
  final double delayMs;

  BubbleData({required this.startX, required this.size, required this.speedMs, required this.delayMs});

  factory BubbleData.random() {
    final rnd = math.Random();
    return BubbleData(
      startX: (rnd.nextDouble() - 0.5) * 100, // 随机分布在中心附近
      size: 10 + rnd.nextDouble() * 20,       // 大小 10-30
      speedMs: 1000 + rnd.nextInt(1000),      // 速度
      delayMs: rnd.nextDouble() * 500,        // 随机延迟出发
    );
  }
}

// 3. 气泡组件 (简单的上浮动画)
class BubbleWidget extends StatefulWidget {
  final BubbleData data;
  const BubbleWidget({super.key, required this.data});

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnim;
  late Animation<double> _alphaAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.data.speedMs));

    _yAnim = Tween<double>(begin: 50, end: -100).animate(_controller); // 从底部向上飘
    _alphaAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 80),
    ]).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.data.delayMs.toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.data.startX, _yAnim.value),
          child: Opacity(
            opacity: _alphaAnim.value,
            child: Container(
              width: widget.data.size,
              height: widget.data.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SlingshotPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  SlingshotPainter({required this.start, required this.end, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // 简单的虚线模拟
    canvas.drawLine(center + start, center + end, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}