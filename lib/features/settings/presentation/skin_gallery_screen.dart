import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/skin_engine/skin_provider.dart';
import '../../../../core/skins/vintage_skin.dart';
import '../../../../core/skins/healing_skin.dart';
import '../../../l10n/app_localizations.dart';

class SkinGalleryScreen extends ConsumerStatefulWidget {
  const SkinGalleryScreen({super.key});

  @override
  ConsumerState<SkinGalleryScreen> createState() => _SkinGalleryScreenState();
}

class _SkinGalleryScreenState extends ConsumerState<SkinGalleryScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // 预加载所有皮肤实例用于预览 (轻量级)
  // 注意：实际项目中 Cyber/Wish 未实现时，这里暂时用 Vintage/Healing 占位演示
  final Map<SkinMode, AppSkin> _previewSkins = {
    SkinMode.vintage: VintageSkin(),
    SkinMode.healing: HealingSkin(),
    SkinMode.cyber: VintageSkin(), // TODO: Replace with CyberSkin()
    SkinMode.wish: HealingSkin(), // TODO: Replace with WishSkin()
  };

  @override
  void initState() {
    super.initState();
    // 视口比例 0.8，让两侧露出一点点，提示可以滑动
    _pageController = PageController(viewportFraction: 0.85);

    // 初始化时定位到当前皮肤
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
      backgroundColor: const Color(0xFFF2F2F7), // iOS Light Gray
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.galleryTitle,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // --- 1. 卡片轮播区 ---
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: SkinMode.values.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final mode = SkinMode.values[index];
                // 计算视差/缩放效果
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.1)).clamp(0.9, 1.0);
                    } else {
                      // 初始状态处理
                      value = (index == _currentPage) ? 1.0 : 0.9;
                    }
                    return Center(
                      child: SizedBox(
                        height:
                            Curves.easeOut.transform(value) *
                            MediaQuery.of(context).size.height *
                            0.65,
                        width: Curves.easeOut.transform(value) * 400,
                        child: child,
                      ),
                    );
                  },
                  child: _SkinCard(
                    mode: mode,
                    skinInstance: _previewSkins[mode]!,
                    isActive: ref.watch(currentSkinProvider).mode == mode,
                    loc: loc,
                    onApply: () {
                      ref.read(currentSkinProvider.notifier).setSkin(mode);
                      HapticFeedback.mediumImpact();
                    },
                  ),
                );
              },
            ),
          ),

          // --- 2. 底部指示器 ---
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(SkinMode.values.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.black
                      : Colors.grey.withOpacity(0.3),
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
  final VoidCallback onApply;

  final AppLocalizations loc;

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

class _SkinCardState extends State<_SkinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heroController;

  @override
  void initState() {
    super.initState();
    // 让预览界面的 Hero 缓慢自动播放，展示动态效果
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 慢动作预览
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
    final isLocked =
        isPremium; // 这里应该结合 UserProStatusProvider 判断，暂时假设所有 Premium 都未解锁
    final loc = widget.loc;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- A. 顶部预览区 (60% 高度) ---
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.mode.previewColor, // 使用配置的主色
                      // 可以在这里加一个淡淡的 Grid 或 Noise 纹理
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 动态 Hero 预览
                        Transform.scale(
                          scale: 0.8,
                          child: widget.skinInstance.buildInteractiveHero(
                            controller: _heroController,
                            onTap: () {}, // 预览模式禁止点击交互，只展示
                          ),
                        ),

                        // 如果是锁定状态，加一层模糊滤镜 "Tease"
                        if (isLocked)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.2), // 稍微压暗
                              // 实际项目中可用 BackdropFilter 做高斯模糊，但性能开销大，这里用半透遮罩模拟
                            ),
                          ),

                        // 锁图标
                        if (isLocked)
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.white54,
                            size: 64,
                          ),
                      ],
                    ),
                  ),
                ),

                // --- B. 底部信息区 (40% 高度) ---
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
                              widget.mode.getTitle(loc).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            if (widget.isActive) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 描述
                        Text(
                          widget.mode.getDescription(loc),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // 操作按钮
                        _buildActionButton(isLocked, isPremium, loc),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- C. VIP 悬浮勋章 ---
            if (isPremium)
              Positioned(top: 20, right: 20, child: _buildVipBadge(loc)),
          ],
        ),
      ),
    );
  }

  // 构建 VIP 勋章 (黑金轻奢风)
  Widget _buildVipBadge(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black, // 纯黑底
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 1), // 金边
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Color(0xFFFFD700), size: 14),
          const SizedBox(width: 4),
          Text(
            loc.vipBadge,
            style: GoogleFonts.inter(
              color: const Color(0xFFFFD700), // 金字
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 构建底部按钮
  Widget _buildActionButton(
    bool isLocked,
    bool isPremium,
    AppLocalizations loc,
  ) {
    if (widget.isActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            loc.statusApplied,
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (isLocked) {
      // VIP 解锁按钮 (渐变色)
      return GestureDetector(
        onTap: () {
          // TODO: 触发内购弹窗
          HapticFeedback.heavyImpact();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF111111), Color(0xFF333333)], // 黑金渐变
              // 或者更骚气的金色渐变: [Color(0xFFFDC830), Color(0xFFF37335)]
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 8),
              Text(
                loc.actionUnlock,
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFD700), // 金色文字
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 普通应用按钮
    return GestureDetector(
      onTap: widget.onApply,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            loc.actionApply,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
