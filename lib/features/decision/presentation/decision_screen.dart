import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 核心依赖 ---
import '../../../../core/skin_engine/skin_provider.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/skins/cyber_skin.dart'; // 引入 CyberSkin 以访问特定属性

// --- 组件依赖 ---
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/my_profile_screen.dart';
import 'widgets/desk_decoration.dart';
import 'widgets/result_card.dart';
import 'widgets/cyber_hud_decoration.dart'; // 引入赛博 HUD 背景

class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key});

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

// 1. 混入 TickerProvider 以支持动画控制器
class _DecisionScreenState extends ConsumerState<DecisionScreen> with SingleTickerProviderStateMixin {
  // UI 状态
  bool _showResult = false;
  String _currentResult = "";

  // 通用待机动画控制器 (用于驱动呼吸、悬浮等效果)
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器，默认开启往复循环 (Loop)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  // 处理交互结束后的回调 (从 buildInteractiveHero 传回)
  void _handleDecisionEnd(String result) {
    // 延迟 300ms 制造悬念，然后弹出结果
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentResult = result;
          _showResult = true;
        });
      }
    });
  }

  // 关闭结果卡片
  void _closeResult() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取全局状态
    final skin = ref.watch(currentSkinProvider);
    final loc = AppLocalizations.of(context)!;

    // 辅助判断变量 (用于处理背景层的特殊逻辑)
    final isVintage = skin.mode == SkinMode.vintage;
    final isCyber = skin.mode == SkinMode.cyber;

    return Scaffold(
      // --- 背景层构建逻辑 ---
      body: Container(
        decoration: BoxDecoration(
          // 如果是特殊模式(复古/赛博)，背景色可能由 Decoration 或 Gradient 处理
          color: (isVintage || isCyber) ? null : skin.backgroundSurface,
          gradient: isVintage
              ? RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              // 复古模式：模拟台灯光照的径向渐变
              Color.lerp(skin.backgroundSurface, Colors.white, 0.08)!,
              skin.backgroundSurface,
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          )
              : null,
        ),
        child: SafeArea(
          // 使用 Stack 处理层级叠加
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- 层级 0.5: 动态背景装饰 ---

              // 1. 复古模式：桌垫与刻度线
              if (isVintage)
                Positioned.fill(
                  child: DeskDecoration(skin: skin),
                ),

              // 2. 赛博模式：HUD 抬头显示
              if (isCyber)
                Positioned.fill(
                  child: const CyberHudDecoration(),
                ),

              // --- 层级 1: 主界面内容 ---
              // 当结果弹出时，背景内容变淡 (Opacity)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showResult ? 0.2 : 1.0,
                child: Column(
                  children: [
                    // 1. 顶部导航栏
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // App 标题
                          Text(
                            loc.appTitle,
                            style: skin.monoFont.copyWith(
                              fontSize: 14,
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w900,
                              color: skin.primaryAccent,
                            ),
                          ),
                          // 个人中心/设置入口
                          IconButton(
                            icon: Icon(Icons.space_dashboard_outlined, size: 22, color: skin.primaryAccent),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 2. 日期显示 (装饰性)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: isVintage ? BoxDecoration(
                        border: Border.all(color: skin.textPrimary.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(4),
                      ) : null,
                      child: Text(
                        "2025 . 11 . 26", // 实际开发建议用 DateFormat
                        style: skin.monoFont.copyWith(
                          fontSize: 14,
                          color: skin.textPrimary.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // --- 🔥 3. 核心互动区 (多态调用) ---
                    // 无论当前是什么皮肤，直接调用 skin 协议中的工厂方法构建组件
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: skin.buildInteractiveHero(
                          controller: _idleController, // 传入共享控制器
                          onTap: () {
                            // 任何皮肤开始交互时，都隐藏旧的结果卡片
                            setState(() => _showResult = false);
                          },
                          onResult: _handleDecisionEnd, // 统一处理结果回调
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 4. 底部提示语
                    Text(
                      // 根据模式简单切换文案 (也可以考虑放入 Skin 协议)
                      isVintage ? loc.tapToDecide : loc.pokeGently,
                      style: skin.bodyFont.copyWith(
                        fontSize: 14,
                        color: skin.textPrimary.withOpacity(0.5),
                        letterSpacing: isVintage ? 3.0 : 1.0,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // --- 层级 2: 结果卡片遮罩层 ---
              if (_showResult)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeResult, // 点击空白处关闭
                    child: Container(
                      // 遮罩颜色适配：深色主题用黑遮罩，浅色用白遮罩
                      color: (isVintage || isCyber)
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.4),
                      child: Center(
                        // 阻止点击事件穿透到遮罩
                        child: GestureDetector(
                          onTap: () {},
                          child: ResultCard(
                            skin: skin,
                            result: _currentResult,
                            onClose: _closeResult,
                          ),
                        ),
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