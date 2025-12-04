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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.82;
    final themeColor = isYes ? const Color(0xFF2E7D32) : const Color(0xFF8F3B35);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _fortune.mainTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1C1E),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 40, height: 2, color: themeColor),
                const SizedBox(height: 16),
                Text(
                  _fortune.subTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildVintageStamp(loc),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "NO.${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                          style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Container(height: 12, width: 60, color: Colors.black87), 
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          
          CustomPaint(
            size: Size(cardWidth, 12),
            painter: _DashedLinePainter(color: Colors.grey[400]!),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHealingNote(AppLocalizations loc, bool isYes) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Transform.rotate(
      angle: 0.03,
      child: Container(
        width: screenWidth * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: widget.skin.primaryAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isYes ? "🎉" : "🍵",
              style: const TextStyle(fontSize: 60),
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            
            const SizedBox(height: 20),
            
            Text(
              _fortune.mainTitle,
              style: GoogleFonts.zcoolKuaiLe(
                fontSize: 36,
                color: widget.skin.primaryAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _fortune.subTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.maShanZheng(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _fortune.luckyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.palette, size: 14, color: _fortune.luckyColor),
                  const SizedBox(width: 6),
                  Text(
                    "${loc.luckyColor}: ${_fortune.luckyColorName}",
                    style: TextStyle(color: _fortune.luckyColor, fontSize: 12, fontWeight: FontWeight.bold),
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
    final Color btnColor = skin.mode == SkinMode.cyber 
        ? (isPrimary ? const Color(0xFFCCFF00) : Colors.white) 
        : (isPrimary ? Colors.white : Colors.white70);
    
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
              color: isPrimary ? btnColor : Colors.white.withOpacity(0.1),
              border: isPrimary ? null : Border.all(color: Colors.white, width: 1.5),
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