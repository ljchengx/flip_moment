import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/services/audio/audio_service.dart';
import '../../../../core/services/haptics/haptic_service.dart';

class FrameCoinFlipper extends ConsumerStatefulWidget {
  final AppSkin skin;
  final VoidCallback? onFlipStart;
  final Function(String result)? onFlipEnd;

  const FrameCoinFlipper({
    super.key,
    required this.skin,
    this.onFlipStart,
    this.onFlipEnd,
  });

  @override
  ConsumerState<FrameCoinFlipper> createState() => _FrameCoinFlipperState();
}

class _FrameCoinFlipperState extends ConsumerState<FrameCoinFlipper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frameAnim;   // 控制播放第几张图
  late Animation<double> _heightAnim;  // 控制飞起的高度 (Flutter接管物理)
  late Animation<double> _wobbleAnim;  // 增加一点空中姿态的微调

  // 状态：当前显示哪一组序列
  bool _isHeadsSequence = true;
  
  // ⚙️ 配置区：根据你的新素材调整
  final int _frameCount = 40; // 你的序列帧总数
  final double _jumpHeight = -250.0; // 向上飞的高度 (负数向上)

  @override
  void initState() {
    super.initState();
    
    // 1. 动画时长
    // 40帧以 30~40fps 播放约需 1000~1300ms，这个速度最有重量感
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100), // 回调到 1.1秒，提供更好的物理体验
    );

    // 2. 序列帧进度 (必须是线性的，否则旋转速度会忽快忽慢)
    _frameAnim = Tween<double>(begin: 0, end: (_frameCount - 1).toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear) 
    );

    // 3. 抛物线高度 (核心修复点：不再依赖图片里的位移)
    _heightAnim = TweenSequence<double>([
      // 上升阶段 (40%的时间)：快速冲高，动能转化为势能
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: _jumpHeight)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      // 下落阶段 (60%的时间)：加速下落并带有弹跳落地效果
      TweenSequenceItem(
        tween: Tween(begin: _jumpHeight, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)), // 落地弹跳
        weight: 60,
      ),
    ]).animate(_controller);

    // 4. 空中侧倾 (增加一点3D感，避免太死板)
    _wobbleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 动画结束，回调结果
        final result = _isHeadsSequence ? "YES" : "NO";
        widget.onFlipEnd?.call(result);
        ref.read(hapticServiceProvider).heavy(); // 落地重震
      }
    });
  }

  // 🔥【修改 1】不再直接调用预加载，而是放入 PostFrameCallback
  // 确保组件 build 完成，第一帧已经上屏后，再开始加载动画序列
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lazyLoadAnimationFrames();
    });
  }

  // 🔥【修改 2】重构预加载逻辑：异步 + 分批
  Future<void> _lazyLoadAnimationFrames() async {
    if (!mounted) return;
    
    // 1. 获取屏幕参数
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (300 * pixelRatio).toInt();

    // 2. 异步分批加载
    // 我们不需要加载第 40 帧 (i=40)，因为 Splash 页已经预热过了
    // 只需要加载动画过程中的帧 (1~39)
    // 另外：为了极致体验，我们可以优先加载前 10 帧，防止用户手速太快点击
    
    const int batchSize = 5; // 每加载 5 张图，就休息一下

    for (int i = 1; i < _frameCount; i++) {
      if (!mounted) return;

      final frameNum = i.toString().padLeft(4, '0');
      
      // 加载正面
      await precacheImage(
        ResizeImage(
          AssetImage("assets/images/coin_anim/heads_$frameNum.png"), 
          width: targetWidth, 
          policy: ResizeImagePolicy.fit,
        ), 
        context
      );
      
      // 加载反面
      await precacheImage(
        ResizeImage(
          AssetImage("assets/images/coin_anim/tails_$frameNum.png"), 
          width: targetWidth, 
          policy: ResizeImagePolicy.fit,
        ), 
        context
      );

      // 🔥 核心黑科技：每处理 batchSize 张图，就暂停 16ms (一帧的时间)
      // 这会让出 Event Loop，让 UI 线程有机会响应触摸事件或绘制界面
      if (i % batchSize == 0) {
        await Future.delayed(const Duration(milliseconds: 16));
      }
    }
    
    debugPrint("✅ [CoinFlipper] 所有动画帧后台加载完毕");
  }

  void _flip() {
    if (_controller.isAnimating) return;

    // 1. 决定结果 (50/50 概率)
    final isHeads = math.Random().nextBool();
    
    setState(() {
      _isHeadsSequence = isHeads;
    });

    // 2. 播放音效 & 震动
    ref.read(audioServiceProvider).play(SoundType.tap, widget.skin.mode);
    ref.read(hapticServiceProvider).selection();
    widget.onFlipStart?.call();

    // 3. 启动动画
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
      // 🚀 [性能优化] 增加 RepaintBoundary
      // 告诉 Flutter：这个组件内部变动时，不要去重绘外面的背景！
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
          // 计算当前帧索引
          int currentFrame = _controller.isAnimating 
              ? _frameAnim.value.floor() 
              : (_frameCount - 1); // 静止时显示最后一帧

          // 构建路径: heads_00xx.png 或 tails_00xx.png
          final String prefix = _isHeadsSequence ? "heads" : "tails";
          // 假设文件名是 0001 ~ 0040
          final String frameNumber = (currentFrame + 1).toString().padLeft(4, '0');
          final String path = "assets/images/coin_anim/${prefix}_$frameNumber.png";

          return SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // 允许动画飞出容器边界(如果需要)
              children: [
                // --- A. 影子 (固定在地面) ---
                Positioned(
                  bottom: 40,
                  child: Opacity(
                    // 飞得越高，影子越淡
                    opacity: (1.0 - (_heightAnim.value / _jumpHeight)).clamp(0.2, 1.0),
                    child: Transform.scale(
                      // 飞得越高，影子越小
                      scale: 1.0 - (_heightAnim.value / _jumpHeight) * 0.5,
                      child: Container(
                        width: 100, height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.4))],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // --- B. 硬币本体 (代码控制位移) ---
                Transform.translate(
                  // 核心：由 Flutter 控制 Y 轴位移，实现抛物线
                  offset: Offset(0, _heightAnim.value),
                  child: Transform.rotate(
                    angle: _wobbleAnim.value, // 微小的 Z 轴摆动
                    child: Image(
                      // 使用动态计算的 targetWidth，确保高清显示
                      image: ResizeImage(
                        AssetImage(path), 
                        width: (300 * MediaQuery.of(context).devicePixelRatio).toInt(),
                        policy: ResizeImagePolicy.fit, // 确保不超过指定宽度
                      ),
                      gaplessPlayback: true, // 防止闪烁，必须保留
                      filterQuality: FilterQuality.medium, // 提升抗锯齿质量
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain, // 确保图片完全在容器内
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}