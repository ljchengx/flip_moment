import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 核心依赖 ---
import '../../../../core/skin_engine/skin_provider.dart';
import '../../../../core/skin_engine/skin_protocol.dart';


// --- 组件依赖 ---
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/my_profile_screen.dart';
import 'widgets/coin_flipper.dart';     // 3D 硬币
import 'widgets/mochi_character.dart';  // 治愈团子
import 'widgets/desk_decoration.dart';  // 复古桌垫
import 'widgets/result_card.dart';      // 结果卡片

class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key});

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends ConsumerState<DecisionScreen> {
  // UI 状态：是否显示结果遮罩
  bool _showResult = false;
  // 当前结果 ("YES" / "NO")
  String _currentResult = "";

  // 处理抛掷/跳跃结束后的回调
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

  // 关闭结果卡片，重置状态
  void _closeResult() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听全局皮肤状态
    final skin = ref.watch(currentSkinProvider);
    final isVintage = skin.mode == SkinMode.vintage;

    return Scaffold(
      // --- 背景层构建逻辑 ---
      body: Container(
        decoration: BoxDecoration(
          // 治愈模式(Healing)使用纯色背景，保持干净
          // 复古模式(Vintage)使用径向渐变，营造光照感
          color: isVintage ? null : skin.backgroundSurface,
          gradient: isVintage
              ? RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              // 中心稍微提亮，模拟台灯光照
              Color.lerp(skin.backgroundSurface, Colors.white, 0.08)!,
              // 边缘保持原色
              skin.backgroundSurface,
              // 最外层加深，形成暗角
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
              // --- 层级 0.5: 桌面装饰线 (仅在复古模式显示) ---
              if (isVintage)
                Positioned.fill(
                  child: DeskDecoration(skin: skin),
                ),

              // --- 层级 1: 主界面内容 ---
              // 使用 AnimatedOpacity：当结果弹出时，背景内容变淡
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
                            AppLocalizations.of(context)!.appTitle,
                            style: skin.monoFont.copyWith(
                              fontSize: 14,
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w900,
                              color: skin.primaryAccent,
                            ),
                          ),
                          // 切换皮肤按钮
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isVintage ? Colors.white.withOpacity(0.05) : Colors.transparent,
                            ),
                            // 这里我们把图标改为 Person 或者 Menu，或者保留 Palette 也可以，看你喜好
                            // 我建议暂时保留 Palette，因为用户习惯点这里换皮肤，进去后再换也符合逻辑
                            child: IconButton(
                              icon: Icon(Icons.space_dashboard_outlined, size: 22, color: skin.primaryAccent), // 改成 Dashboard 图标更合适
                              onPressed: () {
                                // 跳转到 MyProfileScreen
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. 日期显示
                    // 这里可以加一个简单的 Container 装饰
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: isVintage ? BoxDecoration(
                        border: Border.all(color: skin.textPrimary.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(4),
                      ) : null, // 治愈模式不需要边框
                      child: Text(
                        "2025 . 11 . 25", // 实际项目可用 DateFormat 格式化 DateTime.now()
                        style: skin.monoFont.copyWith(
                          fontSize: 14,
                          color: skin.textPrimary.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    // 使用 Spacer 自动推挤，让主角居中
                    const Spacer(),

                    // --- 3. 核心互动区 (主角) ---
                    // 根据模式切换显示：硬币 OR 团子
                    SizedBox(
                      height: 300, // 给定足够的活动空间
                      child: Center(
                        child: isVintage
                            ? CoinFlipper(
                          skin: skin,
                          // 开始抛掷时，隐藏上一次的结果
                          onFlipStart: () => setState(() => _showResult = false),
                          onFlipEnd: _handleDecisionEnd,
                        )
                            : MochiCharacter(
                          skin: skin,
                          // 开始戳动时
                          onTap: () => setState(() => _showResult = false),
                          onResult: _handleDecisionEnd,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 4. 底部提示语
                    Text(
                      isVintage ? AppLocalizations.of(context)!.tapToDecide : AppLocalizations.of(context)!.pokeGently, // 文案也随主题变化
                      style: skin.bodyFont.copyWith(
                        fontSize: 14,
                        color: skin.textPrimary.withOpacity(0.5),
                        letterSpacing: isVintage ? 3.0 : 1.0, // 复古宽间距，治愈正常间距
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // --- 层级 2: 结果卡片遮罩层 ---
              // 当 _showResult 为 true 时显示
              if (_showResult)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeResult, // 点击空白处也可以关闭
                    child: Container(
                      // 遮罩颜色：复古用黑色半透，治愈用白色半透
                      color: isVintage
                          ? Colors.black.withOpacity(0.6)
                          : Colors.white.withOpacity(0.4),
                      child: Center(
                        // 阻止点击事件穿透到背景 (防止误触关闭)
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