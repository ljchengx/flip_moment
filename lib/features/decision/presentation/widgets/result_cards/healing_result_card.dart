import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/ui/text/healing_subtitle_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../settings/providers/user_provider.dart';
import 'fortune_data.dart';

// Healing 皮肤贴纸文案池
const _kPositiveStickerTexts = ["PERFECT!", "NICE!", "GO FOR IT!", "YES!"];
const _kNegativeStickerTexts = ["CHILL~", "WAIT~", "NEXT TIME~", "PAUSE~"];

class HealingResultCard extends ConsumerStatefulWidget {
  final bool isYes;
  final FortuneData fortune;

  const HealingResultCard({
    super.key,
    required this.isYes,
    required this.fortune,
  });

  @override
  ConsumerState<HealingResultCard> createState() => _HealingResultCardState();
}

class _HealingResultCardState extends ConsumerState<HealingResultCard> {
  // Healing 卡片的随机值（只生成一次）
  late String _stickerText;
  late double _stickerAngle;
  late double _tapeAngle;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _stickerText = widget.isYes
        ? _kPositiveStickerTexts[rnd.nextInt(_kPositiveStickerTexts.length)]
        : _kNegativeStickerTexts[rnd.nextInt(_kNegativeStickerTexts.length)];
    _stickerAngle = 0.17 + rnd.nextDouble() * 0.18; // 10-20度
    _tapeAngle = (rnd.nextDouble() * 0.105) - 0.0525; // -3~+3度
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // --- 1. 治愈系氛围配置 ---
    final bgColors = widget.isYes
        ? [const Color(0xFFFFF5EE), const Color(0xFFFFE4E1)] // peachy-cream → soft-rose (暖)
        : [const Color(0xFFF0FFF0), const Color(0xFFE6E6FA)]; // mint-cream → lavender (冷)

    final mainTextColor = const Color(0xFF5D4037);
    final accentColor = widget.isYes ? const Color(0xFFFFAB91) : const Color(0xFF81D4FA);

    final watermarkIcon = widget.isYes ? Icons.favorite_rounded : Icons.cloud_rounded;

    // 获取用户数据
    final user = ref.watch(userProvider);

    // 日期格式化
    final now = DateTime.now();
    final dateStr = "${now.month}月${now.day}日 · 今天";

    final userTitle = user.getTitleLabel(loc);
    final decisionCount = user.totalFlips;

    return Container(
      width: MediaQuery.of(context).size.width.clamp(300.0, 500.0),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: bgColors.last.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 3,
            spreadRadius: -1,
            offset: Offset.zero,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 0,
            spreadRadius: 2.5,
            offset: Offset.zero,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // --- Layer 1: 背景纹理 (手账点阵) ---
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(painter: _DotGridPainter(color: mainTextColor)),
              ),
            ),

            // --- Layer 2: 巨大水印 ---
            Positioned(
              left: -40,
              bottom: -30,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  watermarkIcon,
                  size: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),

            // --- Layer 3: 核心内容 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top: 日期胶带 (Washi Tape)
                  Transform.rotate(
                    angle: _tapeAngle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(100),
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

                  // 用户称号标识
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          userTitle,
                          style: GoogleFonts.maShanZheng(
                            fontSize: 13,
                            color: mainTextColor.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
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

                  const SizedBox(height: 32),

                  // Center: 主标题
                  Text(
                    widget.fortune.mainTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.zcoolKuaiLe(
                      fontSize: 72,
                      color: mainTextColor,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subtitle: 手写心情笔记
                  HealingSubTitleText(
                    text: widget.fortune.subTitle,
                    textColor: mainTextColor.withOpacity(0.7),
                  ),

                  const SizedBox(height: 40),

                  // Bottom: 幸运药丸 & 结果贴纸
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: 幸运色药丸 (Lucky Pill)
                      Container(
                        padding: const EdgeInsets.all(5),
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
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: widget.fortune.luckyColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.fortune.luckyColorName,
                                style: GoogleFonts.fredoka(
                                    fontSize: 15,
                                    color: mainTextColor,
                                    fontWeight: FontWeight.w600
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),

                      // Right: 结果贴纸 (The Sticker)
                      Transform.rotate(
                        angle: _stickerAngle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(2, 4))
                              ]
                          ),
                          child: Text(
                            _stickerText,
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
}

/// 手账点阵绘制器
class _DotGridPainter extends CustomPainter {
  final Color color;
  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const double spacing = 26.0;

    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
