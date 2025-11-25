import 'package:flip_moment/features/decision/presentation/widgets/desk_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/skin_engine/skin_provider.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import 'widgets/coin_flipper.dart';
// 1. 引入新写的卡片组件
import 'widgets/result_card.dart';

// 2. 改为 StatefulWidget 以便在本地管理 UI 状态
class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key});

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends ConsumerState<DecisionScreen> {
  // UI状态：是否显示结果卡片
  bool _showResult = false;
  String _currentResult = "";

  void _handleFlipEnd(String result) {
    // 硬币落地后，延迟一小会儿再显示结果，制造悬念
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _currentResult = result;
          _showResult = true;
        });
        // 这里以后调用 Riverpod 存储历史记录
      }
    });
  }

  void _closeResult() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(currentSkinProvider);

    return Scaffold(
      body: Container(
        // 背景光照保持不变
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color.lerp(skin.backgroundSurface, Colors.white, 0.08)!,
              skin.backgroundSurface,
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- [NEW] 层级 0.5: 桌面装饰线与桌垫 ---
              // 放在最底层，作为背景的一部分
              Positioned.fill(
                child: DeskDecoration(skin: skin),
              ),

              // --- 层级 1: 主内容 ---
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showResult ? 0.2 : 1.0, // 结果出现时背景变淡
                child: Column(
                  children: [
                    // 顶部栏
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("FLIP MOMENT", style: TextStyle(color: skin.primaryAccent, letterSpacing: 3, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.palette_outlined, color: skin.primaryAccent),
                            onPressed: () => ref.read(currentSkinProvider.notifier).toggleSkin(),
                          ),
                        ],
                      ),
                    ),

                    // 日期
                    Text("2025 . 11 . 25", style: skin.monoFont.copyWith(color: Colors.white30)),

                    const Spacer(), // 利用 Spacer 自动推挤

                    // --- 3D 硬币 ---
                    // 现在硬币会正好落在 DeskDecoration 绘制的深色方块中央
                    CoinFlipper(
                      skin: skin,
                      onFlipStart: () => setState(() => _showResult = false),
                      onFlipEnd: _handleFlipEnd,
                    ),

                    const Spacer(), // 上下 Spacer 比例一致，保持居中

                    // 底部文字
                    Text("TAP TO DECIDE", style: skin.bodyFont.copyWith(color: Colors.white24, letterSpacing: 4)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // --- 层级 2: 结果卡片 ---
              if (_showResult)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45, // 遮罩
                    child: Center(
                      child: ResultCard(
                        skin: skin,
                        result: _currentResult,
                        onClose: _closeResult,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}