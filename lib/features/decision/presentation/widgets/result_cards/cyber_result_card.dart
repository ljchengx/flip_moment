import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'fortune_data.dart';

class CyberResultCard extends StatelessWidget {
  final bool isYes;
  final FortuneData fortune;

  const CyberResultCard({
    super.key,
    required this.isYes,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
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
                  fortune.mainTitle,
                  style: GoogleFonts.vt323(
                    fontSize: 56,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ).animate().tint(color: primaryColor, duration: 200.ms),

                const SizedBox(height: 16),

                Text(
                  ">>> ${fortune.subTitle}",
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
                        color: i < fortune.stars ? primaryColor : Colors.grey[800],
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
}
