import 'dart:math' as math;
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
  late Animation<double> _frameAnim;
  
  // 状态：当前显示哪一组序列
  // true = 正面序列 (heads_xx.png), false = 反面序列 (tails_xx.png)
  bool _isHeadsSequence = true;
  
  // 配置：序列帧总数 (根据实际图片数量调整)
  final int _frameCount = 40;

  @override
  void initState() {
    super.initState();
    // 动画时长与原3D动画保持一致，约1.6秒
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), 
    );

    // 线性动画，对应帧索引 0 -> 39
    _frameAnim = Tween<double>(begin: 0, end: (_frameCount - 1).toDouble()).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 动画结束，回调结果
        final result = _isHeadsSequence ? "YES" : "NO";
        widget.onFlipEnd?.call(result);
        ref.read(hapticServiceProvider).heavy(); // 落地重震
      }
    });
  }

  void _flip() {
    if (_controller.isAnimating) return;

    // 1. 决定结果
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 1. 计算当前应该显示第几张图
          // 如果没在播放动画，就显示最后一张（静止态）
          int currentFrame = _controller.isAnimating 
              ? _frameAnim.value.floor() 
              : (_frameCount - 1); // 默认显示最后一张（落地状态）

          // 2. 构建图片路径
          // 注意：实际文件名是 heads_0001.png 到 heads_0040.png
          final String prefix = _isHeadsSequence ? "heads" : "tails";
          // 格式化为4位数，补0：1 -> 0001, 40 -> 0040
          final String frameNumber = (currentFrame + 1).toString().padLeft(4, '0');
          final String path = "assets/images/coin_anim/${prefix}_$frameNumber.png";

          return SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 可以在这里加一个静态的影子图片
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 120, 
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15, 
                          color: Colors.black.withOpacity(0.5)
                        )
                      ],
                    ),
                  ),
                ),
                
                // 序列帧主体
                // gaplessPlayback: true 是关键，防止图片切换时闪烁
                Image.asset(
                  path,
                  gaplessPlayback: true, 
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}