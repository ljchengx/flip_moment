import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/ui/text/vintage_subtitle_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../settings/providers/user_provider.dart';
import 'fortune_data.dart';

class VintageResultCard extends ConsumerWidget {
  final bool isYes;
  final FortuneData fortune;

  const VintageResultCard({
    super.key,
    required this.isYes,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    // --- 1. 动态视觉元素配置 ---
    final isApproved = isYes;

    // 颜色配置：经典红黑配色 (Vintage Noir & Rouge)
    final primaryTextColor = const Color(0xFF1D1D1D);
    final stampColor = isApproved ? const Color(0xFFB71C1C) : const Color(0xFF455A64);
    final paperColor = const Color(0xFFF9F7F0); // 米白道林纸

    // 文字配置
    final mainTitle = fortune.mainTitle.toUpperCase();
    final subTitle = fortune.subTitle;

    // 水印符号配置 (太阳代表吉，云朵/月亮代表凶)
    final watermarkIcon = isApproved ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined;

    // 印章文字
    final stampText = isApproved ? "APPROVED" : "NEXT TIME";

    // 获取用户数据
    final user = ref.watch(userProvider);

    // 日期与决策次数
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
    final decisionNo = "NO.${user.totalFlips.toString().padLeft(4, '0')}";

    // 用户等级信息
    final userTitle = user.getTitleLabel(loc);

    return Container(
      width: MediaQuery.of(context).size.width.clamp(300.0, 500.0),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // --- 2. 背景层：巨大水印符号 (Watermark) ---
            Positioned(
              right: -40,
              top: 60,
              child: Transform.rotate(
                angle: 0.2,
                child: Icon(
                  watermarkIcon,
                  size: MediaQuery.of(context).size.width * 0.7,
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
            ),

            // --- 3. 纹理层：纸张线条 ---
            Positioned.fill(
              child: CustomPaint(painter: _PaperLinesPainter()),
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
                      Text(decisionNo, style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black38, letterSpacing: 1.5)),
                      Text(dateStr, style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 用户称号标识
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: primaryTextColor.withOpacity(0.4),
                      ),
                      const SizedBox(width: 6),
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
                  const SizedBox(height: 40),

                  // 中部：结果主标题
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

                  // 副标题
                  VintageSubTitleText(text: subTitle),

                  const SizedBox(height: 64),

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
                                decoration: BoxDecoration(color: fortune.luckyColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(fortune.luckyColorName, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold)),
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

                  const SizedBox(height: 24),

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
}

/// 纸张线条绘制器
class _PaperLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double i = 40; i < size.height - 40; i += 30) {
      canvas.drawLine(Offset(20, i), Offset(size.width - 20, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
