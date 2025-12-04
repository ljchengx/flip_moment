import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../l10n/app_localizations.dart';

class ResultCard extends StatefulWidget {
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
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // --- 背景层：高斯模糊 ---
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          // --- 核心层：拍立得海报 ---
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 卡片本体 (支持 RepaintBoundary 用于截图)
              RepaintBoundary(
                child: _buildPolaroidCard(loc),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 200.ms),

              const SizedBox(height: 40),

              // --- 操作栏 (分享 & 关闭) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.ios_share,
                    label: loc.shareButton,
                    onTap: () {
                      // TODO: 实现截图分享逻辑 (RenderRepaintBoundary)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.shareButton)),
                      );
                    },
                    isPrimary: false,
                  ),
                  const SizedBox(width: 40),
                  _buildActionButton(
                    icon: Icons.close,
                    label: loc.closeButton,
                    onTap: widget.onClose,
                    isPrimary: true,
                  ),
                ],
              )
                  .animate()
                  .moveY(begin: 50, end: 0, delay: 200.ms, duration: 400.ms)
                  .fadeIn(),
            ],
          ),
        ],
      ),
    );
  }

  // 📸 拍立得卡片构建
  Widget _buildPolaroidCard(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;

    return Transform.rotate(
      angle: -0.02,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F2E9),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 显影区 (黑色方块)
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF080808),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      blurStyle: BlurStyle.inner
                    ),
                  ]
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 结果文字
                      Text(
                        widget.result.toUpperCase(),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 80,
                          color: const Color(0xFFFF3B30).withOpacity(0.9),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 40, spreadRadius: 10)
                          ]
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                      
                      // 装饰性小字
                      Text(
                        loc.flipMomentLogo,
                        style: widget.skin.monoFont.copyWith(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. 底部手写区
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.resultCardTitle,
                      style: GoogleFonts.cedarvilleCursive(
                        fontSize: 28,
                        color: const Color(0xFF2C3333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.resultCardSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                // 右侧：日期印章
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "DEC 04\n2025",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.courierPrime(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
              border: isPrimary ? null : Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              icon, 
              color: isPrimary ? Colors.black : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}