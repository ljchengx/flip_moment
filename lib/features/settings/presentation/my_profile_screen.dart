import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. 引入国际化生成的包 (如果报红，请运行 flutter pub get)

// 2. 引入核心 Provider
import '../../../../core/skin_engine/skin_provider.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart'; // 语言切换 Provider

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  // --- 🍎 iOS 设计语言常量 ---
  static const kBackgroundColorLight = Color(0xFFF2F2F7);
  static const kCardColorLight = Color(0xFFFFFFFF);
  static const kTextPrimary = Color(0xFF000000);
  static const kTextSecondary = Color(0xFF8E8E93);
  static const kTextTertiary = Color(0xFFC7C7CC);
  static const kSeparator = Color(0xFFC6C6C8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听皮肤状态 (用于头像边框)
    final skin = ref.watch(currentSkinProvider);
    // 获取多语言代理 (loc)
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColorLight,
      appBar: AppBar(
        backgroundColor: kBackgroundColorLight,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        // 动态标题: "Me" / "我的"
        title: Opacity(
          opacity: 0.0, // 保持 iOS 风格，初始隐藏大标题，上滑显示(这里简化为一直隐藏)
          child: Text(loc.meTitle, style: GoogleFonts.inter(color: kTextPrimary, fontWeight: FontWeight.w600)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        // --- 🌍 语言切换入口 ---
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: kTextPrimary),
            tooltip: 'Switch Language',
            onPressed: () {
              // 调用 LocaleProvider 切换中英文
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. 大标题 (Large Title) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                loc.meTitle, // "我的"
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- 2. 身份卡片 (Identity Card) ---
            _buildIdentitySection(skin, loc),

            const SizedBox(height: 30),

            // --- 3. 核心功能组 (Core Features) ---
            _buildSectionHeader(loc.sectionFeatures), // "核心功能"
            _buildInsetGroup(
              children: [
                _buildListTile(
                  icon: Icons.palette,
                  iconBgColor: const Color(0xFFFF2D55), // iOS Pink
                  title: loc.featureThemes, // "主题皮肤"
                  // 动态显示当前皮肤名: "Vintage" / "复古机械"
                  value: _getSkinName(skin.mode, loc),
                  onTap: () => ref.read(currentSkinProvider.notifier).toggleSkin(),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.history_edu,
                  iconBgColor: const Color(0xFF5856D6), // iOS Indigo
                  title: loc.featureLog, // "决策手账"
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.app_registration,
                  iconBgColor: const Color(0xFF34C759), // iOS Green
                  title: loc.featureWidgets, // "桌面组件"
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- 4. 通用设置组 (General) ---
            _buildSectionHeader(loc.sectionGeneral), // "通用设置"
            _buildInsetGroup(
              children: [
                _buildListTile(
                  icon: Icons.settings,
                  iconBgColor: const Color(0xFF8E8E93), // iOS Gray
                  title: loc.settingGeneral, // "设置与更多"
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 50),

            // 底部版本号
            Center(
              child: Text(
                loc.footerVersion,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kTextTertiary,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- 🧩 辅助方法 ---

  // 获取皮肤名称的多语言文本
  String _getSkinName(SkinMode mode, AppLocalizations loc) {
    switch (mode) {
      case SkinMode.vintage: return loc.themeVintage;
      case SkinMode.healing: return loc.themeHealing;
    // case SkinMode.cyber: return loc.themeCyber;
    // case SkinMode.wish: return loc.themeWish;
      default: return "";
    }
  }

  // --- 🎨 组件构建区 ---

  Widget _buildIdentitySection(AppSkin skin, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: kCardColorLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          // 动态材质头像框
          _buildHeroAvatar(skin),

          const SizedBox(height: 16),

          Text(
            "Make_A_Decision",
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: kTextPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            loc.identityTitle, // "Lv.5 命运领航员"
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blueAccent),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF2F2F7), thickness: 2),
          const SizedBox(height: 20),

          // 数据栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("108", loc.statsFlips), // "次决策"
              _buildStatItem("7", loc.statsStreak),  // "日连续"
              _buildStatItem("92%", loc.statsHappy), // "快乐率"
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAvatar(AppSkin skin) {
    // 基础头像
    final avatarContent = Container(
      width: 86, height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        image: const DecorationImage(
          image: AssetImage('assets/images/avatar_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );

    // 根据主题应用材质
    if (skin.mode == SkinMode.vintage) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6C17A), Color(0xFFC6A664), Color(0xFF8C7335)],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, spreadRadius: -1),
            BoxShadow(color: const Color(0xFFC6A664).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: avatarContent,
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFE8F5E9), const Color(0xFFB5C99A).withOpacity(0.6)],
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFFB5C99A).withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
          ],
        ),
        child: avatarContent,
      );
    }
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
            value,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: kTextPrimary, letterSpacing: -0.5)
        ),
        const SizedBox(height: 2),
        Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: kTextTertiary, letterSpacing: 1.0)
        ),
      ],
    );
  }

  Widget _buildInsetGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kCardColorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: kTextPrimary)
              ),
              const Spacer(),
              if (value != null) ...[
                Text(value, style: GoogleFonts.inter(fontSize: 15, color: kTextSecondary)),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.arrow_forward_ios, size: 14, color: kSeparator),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 58,
      endIndent: 0,
      color: kSeparator,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: kTextSecondary),
      ),
    );
  }
}