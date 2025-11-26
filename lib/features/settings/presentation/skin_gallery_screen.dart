import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 核心依赖
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/skin_engine/skin_provider.dart';
import '../../../../core/skins/vintage_skin.dart';
import '../../../../core/skins/healing_skin.dart';
import '../../../../core/skins/cyber_skin.dart'; // 确保引入了 CyberSkin
import '../../../../core/services/haptics/haptic_service.dart'; // 引入 HapticService

// 国际化
import '../../../l10n/app_localizations.dart';

class SkinGalleryScreen extends ConsumerStatefulWidget {
  const SkinGalleryScreen({super.key});

  @override
  ConsumerState<SkinGalleryScreen> createState() => _SkinGalleryScreenState();
}

class _SkinGalleryScreenState extends ConsumerState<SkinGalleryScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // 预加载皮肤实例用于预览
  // 注意：这里只是为了画廊预览，不用每次都 new，节省资源
  final Map<SkinMode, AppSkin> _previewSkins = {
    SkinMode.vintage: VintageSkin(),
    SkinMode.healing: HealingSkin(),
    SkinMode.cyber: CyberSkin(), // 赛博皮肤预览
    SkinMode.wish: HealingSkin(), // 许愿池暂未开发，用 Healing 占位
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    // 进入页面时，自动滚动到当前选中的皮肤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMode = ref.read(currentSkinProvider).mode;
      final index = SkinMode.values.indexOf(currentMode);
      if (index != -1) {
        _pageController.jumpToPage(index);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.galleryTitle, // "主题画廊"
          style: GoogleFonts.inter(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // 1. 轮播区
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: SkinMode.values.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final mode = SkinMode.values[index];
                // 简单的视差缩放计算
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.1)).clamp(0.9, 1.0);
                    } else {
                      value = (index == _currentPage) ? 1.0 : 0.9;
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * MediaQuery.of(context).size.height * 0.65,
                        width: Curves.easeOut.transform(value) * 400,
                        child: child,
                      ),
                    );
                  },
                  child: _SkinCard(
                    mode: mode,
                    skinInstance: _previewSkins[mode] ?? VintageSkin(), // 安全回退
                    isActive: ref.watch(currentSkinProvider).mode == mode,
                    loc: loc,
                    onApply: () {
                      // 切换皮肤
                      ref.read(currentSkinProvider.notifier).setSkin(mode);
                      ref.read(hapticServiceProvider).medium();
                    },
                  ),
                );
              },
            ),
          ),

          // 2. 指示器
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(SkinMode.values.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.black : Colors.grey.withOpacity(0.3),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SkinCard extends StatefulWidget {
  final SkinMode mode;
  final AppSkin skinInstance;
  final bool isActive;
  final AppLocalizations loc;
  final VoidCallback onApply;

  const _SkinCard({
    required this.mode,
    required this.skinInstance,
    required this.isActive,
    required this.loc,
    required this.onApply,
  });

  @override
  State<_SkinCard> createState() => _SkinCardState();
}

class _SkinCardState extends State<_SkinCard> with SingleTickerProviderStateMixin {
  late AnimationController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.mode.isPremium;

    // 🔥 核心修改：如果是 VIP，虽然显示锁定，但我们允许预览
    // 如果你想完全模拟未解锁状态，这里设为 true
    final isLocked = isPremium;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A. 顶部预览区
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.mode.previewColor,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: widget.skinInstance.buildInteractiveHero(
                            controller: _heroController,
                            onTap: () {},
                          ),
                        ),
                        if (isLocked && !widget.isActive)
                          Positioned.fill(
                            child: Container(color: Colors.black.withOpacity(0.2)),
                          ),
                        if (isLocked && !widget.isActive)
                          const Icon(Icons.lock_outline, color: Colors.white54, size: 64),
                      ],
                    ),
                  ),
                ),

                // B. 底部信息区
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Row(
                          children: [
                            Text(
                              widget.mode.getTitle(widget.loc).toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                            if (widget.isActive) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            ]
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 描述
                        Text(
                          widget.mode.getDescription(widget.loc),
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // 按钮
                        _buildActionButton(isLocked && !widget.isActive, isPremium),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // C. VIP 勋章
            if (isPremium)
              Positioned(
                top: 20, right: 20,
                child: _buildVipBadge(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Color(0xFFFFD700), size: 14),
          const SizedBox(width: 4),
          Text(
            widget.loc.vipBadge,
            style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isLocked, bool isPremium) {
    // 1. 已应用状态
    if (widget.isActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(
            widget.loc.statusApplied,
            style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );
    }

    // 2. 锁定状态 (VIP)
    if (isLocked) {
      return GestureDetector(
        onTap: () {
          // 🔥🔥🔥 开发者后门：点击直接应用！
          // 在正式版中，这里应该跳转支付页面
          // Navigator.pushNamed(context, '/paywall');

          // 模拟解锁成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✨ Developer Mode: Premium Theme Unlocked!"),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );

          widget.onApply(); // 直接调用应用逻辑
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF111111), Color(0xFF333333)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.loc.actionUnlock,
                style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      );
    }

    // 3. 普通应用按钮
    return GestureDetector(
      onTap: widget.onApply,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(
            widget.loc.actionApply,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}