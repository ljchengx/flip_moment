import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fortune_data.dart';

class WishResultCard extends StatelessWidget {
  final bool isYes;
  final FortuneData fortune;

  const WishResultCard({
    super.key,
    required this.isYes,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
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
              fortune.mainTitle,
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
                fortune.subTitle,
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
                index < fortune.stars ? Icons.star : Icons.star_border,
                color: const Color(0xFFFCE38A),
                size: 14,
              )),
            )
          ],
        ),
      ),
    );
  }
}
