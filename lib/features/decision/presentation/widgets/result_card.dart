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
  late FortuneData _fortune;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fortune = FortuneGenerator.generate(
      context, 
      widget.result == "YES",
      widget.skin.mode,
    );
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
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                child: _buildAdaptiveCard(loc, isYes),
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
                    icon: Icons.ios_share,
                    label: loc.shareButton,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${loc.shareButton}... (Saving)")),
                      );
                    },
                    isPrimary: true,
                    skin: widget.skin,
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    label: loc.closeButton,
                    onTap: widget.onClose,
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

    // 日期与序列号
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')} . ${now.month.toString().padLeft(2, '0')} . ${now.year}";
    final serialNo = "NO.${now.millisecondsSinceEpoch.toString().substring(8)}"; // 取后几位

    return Container(
      // 让卡片撑满宽度，并在垂直方向留出呼吸空间
      width: double.infinity,
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
                  size: 280, // 巨大尺寸！
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
                  // 顶部：序列号与日期
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(serialNo, style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black38, letterSpacing: 1.5)),
                      Text(dateStr, style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black87, thickness: 1.5), 
                  const SizedBox(height: 48), // 大面积留白

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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: stampColor.withOpacity(0.7), width: 3),
                            borderRadius: BorderRadius.circular(8),
                            // 印章内部稍微做旧
                            color: stampColor.withOpacity(0.05), 
                          ),
                          child: Text(
                            stampText,
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 22,
                              color: stampColor.withOpacity(0.9),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 治愈系配色：奶呼呼的渐变
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isYes 
        ? [const Color(0xFFFFF9C4), const Color(0xFFFFE0B2)] // 奶黄 -> 奶橘
        : [const Color(0xFFE1F5FE), const Color(0xFFE0F7FA)], // 奶蓝 -> 奶绿
    );

    return Transform.rotate(
      angle: 0.03, // 微微倾斜，像随手贴的
      child: Container(
        width: screenWidth * 0.75,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(60), // 不规则圆角，增加可爱感
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            // 弥散柔光阴影，颜色跟随主色
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // ✨ 关键点：用巨大的 Emoji 代替图标，这是小红书最爱
            Text(isYes ? "🎉" : "🍵", style: const TextStyle(fontSize: 80))
                .animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            
            const SizedBox(height: 16),
            
            Text(
              _fortune.mainTitle,
              style: GoogleFonts.zcoolKuaiLe( // 你的代码里已经用了这个，很棒！
                fontSize: 40,
                color: const Color(0xFF5D4037), // 暖咖色文字，不要用纯黑
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 像手账里的胶带文字背景
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _fortune.subTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.maShanZheng(fontSize: 18, color: const Color(0xFF5C5C5C)),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 幸运色药丸
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _fortune.luckyColor.withOpacity(0.3), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.palette_rounded, size: 16, color: _fortune.luckyColor),
                  const SizedBox(width: 8),
                  Text(
                    "${loc.luckyColor}: ${_fortune.luckyColorName}",
                    style: GoogleFonts.quicksand(
                      color: _fortune.luckyColor, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            )
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
        "${loc.today}\nAPPROVED",
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