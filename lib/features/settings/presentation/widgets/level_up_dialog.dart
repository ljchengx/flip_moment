import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../l10n/app_localizations.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final String newTitle;
  final AppSkin skin;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.newTitle,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  skin.primaryAccent.withOpacity(0.5),
                  Colors.transparent
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: const Duration(seconds: 4)),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: skin.cardBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: skin.primaryAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10)
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.levelUpTitle,
                  style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: skin.primaryAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                const SizedBox(height: 20),

                Text(
                  "$newLevel",
                  style: GoogleFonts.inter(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: skin.textPrimary
                  ),
                ).animate().fadeIn().moveY(begin: 20, end: 0),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: skin.primaryAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getLocalizedTitle(loc, newTitle),
                    style: skin.monoFont.copyWith(
                      fontWeight: FontWeight.bold,
                      color: skin.textPrimary
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: skin.primaryAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      loc.awesomeButton,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: skin.backgroundSurface
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations loc, String title) {
    switch (title) {
      case "Drifter":
        return loc.titleDrifter;
      case "Light Seeker":
        return loc.titleLightSeeker;
      case "Moment Collector":
        return loc.titleMomentCollector;
      case "Star Reader":
        return loc.titleStarReader;
      case "Fate Architect":
        return loc.titleFateArchitect;
      default:
        return title;
    }
  }
}