import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/providers/user_provider.dart';

class ResultCard extends ConsumerStatefulWidget {
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
  ConsumerState<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends ConsumerState<ResultCard> {
  late FortuneData _fortune;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fortune = FortuneGenerator.generate(
      context,
      widget.result == "YES",
      widget.skin.mode,
    );
  }

  Future<void> _saveCardAsImage() async {
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0, // 高清截图
      );

      if (imageBytes != null) {
        // 使用 gal 保存图片
        await Gal.putImageBytes(imageBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("卡片已保存到相册"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("保存失败: $e"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    final bool isYes = widget.result == "YES";
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose, // 点击背景关闭
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          GestureDetector(
            onTap: () {}, // 阻止点击事件穿透到背景
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: RepaintBoundary(
                    child: _buildAdaptiveCard(loc, isYes),
                  ),
                )
              .animate()
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutQuart
              )
              .fadeIn(duration: 300.ms)
              .shimmer(delay: 600.ms, duration: 1200.ms, color: Colors.white.withOpacity(0.1)),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.save_alt_rounded,
                    label: "保存卡片",
                    onTap: _saveCardAsImage,
                    isPrimary: true,
                    skin: widget.skin,
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.ios_share,
                    label: loc.shareButton,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${loc.shareButton}... (Saving)")),
                      );
                    },
                    isPrimary: false,
                    skin: widget.skin,
                  ),
                ],
              )
              .animate()
              .moveY(begin: 60, end: 0, delay: 200.ms, duration: 500.ms)
              .fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveCard(AppLocalizations loc, bool isYes) {
    switch (widget.skin.mode) {
      case SkinMode.vintage:
        return _buildVintageTicket(loc, isYes);
      case SkinMode.healing:
        return _buildHealingNote(loc, isYes);
      case SkinMode.cyber:
        return _buildCyberDataCard(loc, isYes);
      case SkinMode.wish:
        return _buildTarotCard(loc, isYes);
    }
  }

  Widget _buildVintageTicket(AppLocalizations loc, bool isYes) {
    // --- 1. 动态视觉元素配置 ---
    final isApproved = isYes; // 假设 isYes 决定通过/不通过
    
    // 颜色配置：经典红黑配色 (Vintage Noir & Rouge)
    final primaryTextColor = const Color(0xFF1D1D1D); 
    final stampColor = isApproved ? const Color(0xFFB71C1C) : const Color(0xFF455A64);
    final paperColor = const Color(0xFFF9F7F0); // 米白道林纸

    // 文字配置
    final mainTitle = _fortune.mainTitle.toUpperCase();
    final subTitle = _fortune.subTitle;
    
    // 水印符号配置 (太阳代表吉，云朵/月亮代表凶)
    final watermarkIcon = isApproved ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined;
    
    // 印章文字
    final stampText = isApproved ? "APPROVED" : "NEXT TIME";

    // 🔥 获取用户数据
    final user = ref.watch(userProvider);

    // 日期与决策次数
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
    final decisionNo = "NO.${user.totalFlips.toString().padLeft(4, '0')}"; // 用户总决策次数

    // 用户等级信息
    final userLevel = "LV.${user.level}";
    final userTitle = user.getTitleLabel(loc);

    return Container(
      // 让卡片撑满宽度，但在大屏幕上限制最大宽度，并在垂直方向留出呼吸空间
      width: MediaQuery.of(context).size.width.clamp(300.0, 500.0),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(6), // 复古纸张圆角很小
        boxShadow: [
          // 纸张的自然投影：深浅两层增加立体感
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      // 使用 ClipRRect 确保水印不会溢出卡片圆角
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // --- 2. 背景层：巨大水印符号 (Watermark) ---
            Positioned(
              right: -40,
              top: 60,
              child: Transform.rotate(
                angle: 0.2, // 微微倾斜
                child: Icon(
                  watermarkIcon,
                  size: MediaQuery.of(context).size.width * 0.7, // 响应式：屏幕宽度的 70%
                  color: Colors.black.withOpacity(0.04), // 极低透明度
                ),
              ),
            ),
            
            // --- 3. 纹理层：纸张线条 (可选，增加细腻度) ---
            Positioned.fill(
               child: CustomPaint(painter: PaperLinesPainter()),
            ),

            // --- 4. 内容层：核心信息 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部：决策次数与日期
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧：决策次数
                      Text(decisionNo, style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black38, letterSpacing: 1.5)),
                      // 右侧：日期
                      Text(dateStr, style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 🔥 用户称号标识（仅显示称号，不显示等级）
                  Row(
                    children: [
                      // 称号装饰图标
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: primaryTextColor.withOpacity(0.4),
                      ),
                      const SizedBox(width: 6),
                      // 称号
                      Flexible(
                        child: Text(
                          userTitle,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 11,
                            color: primaryTextColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Colors.black87, thickness: 1.5),
                  const SizedBox(height: 40), // 调整留白

                  // 中部：结果主标题 (Typography)
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        mainTitle,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 72, 
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 副标题 (中文建议用 MaShanZheng 或系统衬线体)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      color: Colors.black.withOpacity(0.05), // 文字背后的浅底色，增强层次
                      child: Text(
                        subTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.maShanZheng(
                          fontSize: 20,
                          color: Colors.black54,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 64), // 撑开底部空间

                  // 底部：功能区
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧：幸运指引 (Lucky Guide)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.palette_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text("LUCKY COLOR", style: GoogleFonts.oswald(fontSize: 10, color: Colors.black45, letterSpacing: 1)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 10, height: 10, 
                                decoration: BoxDecoration(color: _fortune.luckyColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(_fortune.luckyColorName, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),

                      // 右侧：视觉印章 (The Stamp)
                      Transform.rotate(
                        angle: -0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: stampColor.withOpacity(0.7), width: 2),
                            borderRadius: BorderRadius.circular(6),
                            // 印章内部稍微做旧
                            color: stampColor.withOpacity(0.05),
                          ),
                          child: Text(
                            stampText,
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 16,
                              color: stampColor.withOpacity(0.9),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24), // 🔥 增加间距：从 16 改为 24

                  // 底部装饰：条形码纹理
                  Opacity(
                    opacity: 0.3,
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(40, (index) => Container(
                          width: index % 2 == 0 ? 2 : 1,
                          margin: EdgeInsets.only(right: index % 4 == 0 ? 4 : 2),
                          color: Colors.black,
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealingNote(AppLocalizations loc, bool isYes) {
    // --- 1. 治愈系氛围配置 ---
    // 这种"奶呼呼"的配色是小红书最流行的
    final bgColors = isYes 
        ? [const Color(0xFFFFF3E0), const Color(0xFFFFEBEE)] // 奶黄 -> 桃粉 (暖阳)
        : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)]; // 冰蓝 -> 薄荷 (清风)
        
    // 字体颜色：不要用纯黑，要用"暖咖色"，更温柔
    final mainTextColor = const Color(0xFF5D4037); 
    // 强调色 (用于贴纸背景)
    final accentColor = isYes ? const Color(0xFFFFAB91) : const Color(0xFF81D4FA);
    
    // 视觉元素
    final watermarkIcon = isYes ? Icons.favorite_rounded : Icons.cloud_rounded;
    final stickerText = isYes ? "PERFECT!" : "CHILL~";
    
    // 🔥 获取用户数据
    final user = ref.watch(userProvider);

    // 日期格式化：模拟手账日记
    final now = DateTime.now();
    final dateStr = "${now.month}月${now.day}日 · 今天";

    // 用户等级信息
    final userLevel = "LV.${user.level}";
    final userTitle = user.getTitleLabel(loc);
    final decisionCount = user.totalFlips;

    return Container(
      // 同样撑满全屏，但限制最大宽度，制造沉浸感
      width: MediaQuery.of(context).size.width.clamp(300.0, 500.0),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
        borderRadius: BorderRadius.circular(32), // 超级圆润的导角 (Super Ellipse)
        boxShadow: [
          // 第一层：弥散的彩色光晕 (Dreamy Glow)
          BoxShadow(
            color: bgColors.last.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          // 第二层：内部的白色高光描边 (模拟果冻质感)
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 0,
            spreadRadius: 2, // 模拟白色描边
            offset: const Offset(0, 0),
          )
        ],
      ),
      // 使用 ClipRRect 裁剪内部溢出的水印
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // --- Layer 1: 背景纹理 (手账点阵) ---
            Positioned.fill(
               child: Opacity(
                 opacity: 0.15, // 淡淡的，不抢戏
                 child: CustomPaint(painter: DotGridPainter(color: mainTextColor)),
               ),
            ),
            
            // --- Layer 2: 巨大水印 (The Giant Watermark) ---
            // 放在左下角或角落，像云朵一样漂浮
            Positioned(
              left: -40,
              bottom: -30,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  watermarkIcon,
                  size: MediaQuery.of(context).size.width * 0.8, // 响应式：屏幕宽度的 80%
                  color: Colors.white.withOpacity(0.5), // 奶白色半透明
                ),
              ),
            ),
            
            // --- Layer 3: 核心内容 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top: 日期胶带 (Washi Tape)
                  Transform.rotate(
                    angle: -0.03, // 微微歪一点，像手贴的
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(100), // 胶囊形状
                      ),
                      child: Text(
                        dateStr,
                        style: GoogleFonts.maShanZheng(
                          fontSize: 16,
                          color: mainTextColor.withOpacity(0.8),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔥 用户称号标识（治愈系风格，仅显示称号和决策次数）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // 🔥 修复溢出：限制 Row 的最小尺寸
                    children: [
                      // 称号（使用 Flexible 防止溢出）
                      Flexible(
                        child: Text(
                          userTitle,
                          style: GoogleFonts.maShanZheng(
                            fontSize: 13,
                            color: mainTextColor.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis, // 🔥 防止文字溢出
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 决策次数徽章
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: accentColor),
                            const SizedBox(width: 4),
                            Text(
                              "×$decisionCount",
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                color: mainTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),
                  
                  // Center: 主标题 (Happy Font)
                  // 治愈系要用圆体或快乐体
                  Text(
                    _fortune.mainTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.zcoolKuaiLe( 
                      fontSize: 72, // 依然要巨大！
                      color: mainTextColor,
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subtitle: 手写心情笔记
                  Text(
                    _fortune.subTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.maShanZheng(
                      fontSize: 24, // 加大字号
                      color: mainTextColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Bottom: 幸运药丸 & 结果贴纸
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: 幸运色药丸 (Lucky Pill)
                      Container(
                        padding: const EdgeInsets.all(5), // 内边距
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))
                          ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             // 颜色圆点
                             Container(
                               width: 28, height: 28,
                               decoration: BoxDecoration(
                                 color: _fortune.luckyColor,
                                 shape: BoxShape.circle,
                               ),
                               child: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                             ),
                             const SizedBox(width: 10),
                             // 颜色名称
                             Text(
                               _fortune.luckyColorName,
                               style: GoogleFonts.fredoka(
                                 fontSize: 15, 
                                 color: mainTextColor, 
                                 fontWeight: FontWeight.w600
                               ),
                             ),
                             const SizedBox(width: 16),
                          ],
                        ),
                      ),
                      
                      // Right: 结果贴纸 (The Sticker)
                      // 模拟一张带白边的贴纸
                      Transform.rotate(
                        angle: 0.15, // 俏皮地翘起来
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 4), // 厚厚的白边
                            boxShadow: [
                              BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(2, 4))
                            ]
                          ),
                          child: Text(
                            stickerText,
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberDataCard(AppLocalizations loc, bool isYes) {
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryColor = const Color(0xFFCCFF00);
    final bgBlack = const Color(0xFF0A0A0A);

    return Container(
      width: screenWidth * 0.85,
      decoration: BoxDecoration(
        color: bgBlack,
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 20)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("SYSTEM_MSG // ${isYes ? 'ACK' : 'NACK'}", 
                  style: GoogleFonts.vt323(color: bgBlack, fontWeight: FontWeight.bold, fontSize: 16)),
                const Icon(Icons.hub, size: 16, color: Colors.black),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fortune.mainTitle,
                  style: GoogleFonts.vt323(
                    fontSize: 56,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ).animate().tint(color: primaryColor, duration: 200.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  ">>> ${_fortune.subTitle}",
                  style: GoogleFonts.shareTechMono(
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    for(int i=0; i<5; i++)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 40, height: 4,
                        color: i < _fortune.stars ? primaryColor : Colors.grey[800],
                      )
                  ],
                ),
                const SizedBox(height: 8),
                Text("PROBABILITY: ${(0.7 + math.Random().nextDouble()*0.29).toStringAsFixed(4)}",
                  style: GoogleFonts.vt323(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarotCard(AppLocalizations loc, bool isYes) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth * 0.7,
      height: screenWidth * 0.7 * 1.6,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCE38A), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF4E4376).withOpacity(0.5), blurRadius: 30)],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFCE38A).withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFCE38A), size: 30),
            const SizedBox(height: 20),
            Text(
              _fortune.mainTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _fortune.subTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerif(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => Icon(
                index < _fortune.stars ? Icons.star : Icons.star_border,
                color: const Color(0xFFFCE38A),
                size: 14,
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVintageStamp(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8F3B35), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "TODAY\nAPPROVED",
        textAlign: TextAlign.center,
        style: GoogleFonts.courierPrime(
          fontSize: 8, 
          color: const Color(0xFF8F3B35), 
          fontWeight: FontWeight.bold
        ),
      ),
    ).animate().rotate(begin: 0, end: -0.1);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required AppSkin skin,
  }) {
    // 根据皮肤模式确定主题色
    Color themeColor;
    if (skin.mode == SkinMode.cyber) {
      themeColor = const Color(0xFFCCFF00);
    } else if (skin.mode == SkinMode.healing) {
      themeColor = skin.primaryAccent;
    } else if (skin.mode == SkinMode.vintage) {
      themeColor = skin.primaryAccent;
    } else {
      themeColor = Colors.white;
    }

    final Color btnColor = isPrimary ? themeColor : Colors.white.withOpacity(0.1);
    final Color textColor = skin.mode == SkinMode.cyber && isPrimary 
        ? Colors.black 
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: btnColor,
              border: isPrimary ? null : Border.all(color: themeColor.withOpacity(0.6), width: 1.5),
              boxShadow: isPrimary ? [
                BoxShadow(
                  color: themeColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Icon(icon, color: textColor, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: skin.bodyFont.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 别忘了把这个 Painter 放在文件底部或者工具类里
class PaperLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02) // 极淡的线条
      ..strokeWidth = 1;
      
    // 画横线，模拟笔记本内页
    for (double i = 40; i < size.height - 40; i += 30) {
      canvas.drawLine(Offset(20, i), Offset(size.width - 20, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FortuneData {
  final String mainTitle;
  final String subTitle;
  final int stars;
  final Color luckyColor;
  final String luckyColorName;

  FortuneData(this.mainTitle, this.subTitle, this.stars, this.luckyColor, this.luckyColorName);
}

class FortuneGenerator {
  static FortuneData generate(BuildContext context, bool isYes, SkinMode mode) {
    final loc = AppLocalizations.of(context)!;
    final random = math.Random();
    
    List<String> titles;
    List<String> subs;

    switch (mode) {
      case SkinMode.vintage:
        titles = isYes 
            ? [loc.vinYes1, loc.vinYes2, loc.vinYes3] 
            : [loc.vinNo1, loc.vinNo2, loc.vinNo3];
        subs = isYes
            ? [loc.vinYesSub1, loc.vinYesSub2, loc.vinYesSub3]
            : [loc.vinNoSub1, loc.vinNoSub2, loc.vinNoSub3];
        break;
      case SkinMode.healing:
        titles = isYes 
            ? [loc.heaYes1, loc.heaYes2, loc.heaYes3] 
            : [loc.heaNo1, loc.heaNo2, loc.heaNo3];
        subs = isYes
            ? [loc.heaYesSub1, loc.heaYesSub2, loc.heaYesSub3]
            : [loc.heaNoSub1, loc.heaNoSub2, loc.heaNoSub3];
        break;
      case SkinMode.cyber:
        titles = isYes 
            ? [loc.cybYes1, loc.cybYes2, loc.cybYes3] 
            : [loc.cybNo1, loc.cybNo2, loc.cybNo3];
        subs = isYes
            ? [loc.cybYesSub1, loc.cybYesSub2, loc.cybYesSub3]
            : [loc.cybNoSub1, loc.cybNoSub2, loc.cybNoSub3];
        break;
      case SkinMode.wish:
        titles = isYes 
            ? [loc.wisYes1, loc.wisYes2, loc.wisYes3] 
            : [loc.wisNo1, loc.wisNo2, loc.wisNo3];
        subs = isYes
            ? [loc.wisYesSub1, loc.wisYesSub2, loc.wisYesSub3]
            : [loc.wisNoSub1, loc.wisNoSub2, loc.wisNoSub3];
        break;
    }

    final index = random.nextInt(titles.length);
    final stars = 3 + random.nextInt(3);

    final colors = [
      (const Color(0xFFE57373), "Coral Red"),
      (const Color(0xFF81C784), "Mint Green"),
      (const Color(0xFF64B5F6), "Sky Blue"),
      (const Color(0xFFFFD54F), "Sunshine"),
      (const Color(0xFF9575CD), "Lavender"),
    ];
    final colorData = colors[random.nextInt(colors.length)];

    return FortuneData(titles[index], subs[index], stars, colorData.$1, colorData.$2);
  }
}

// 🌸 手账点阵绘制器 (放在文件底部)
class DotGridPainter extends CustomPainter {
  final Color color;
  DotGridPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    // 圆点画笔
    final paint = Paint()
      ..color = color.withOpacity(0.2) // 很淡
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
      
    const double spacing = 26.0; // 点阵间距
    
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}