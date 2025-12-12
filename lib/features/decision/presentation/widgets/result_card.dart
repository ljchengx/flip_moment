import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../../l10n/app_localizations.dart';
import 'result_cards/fortune_data.dart';
import 'result_cards/vintage_result_card.dart';
import 'result_cards/healing_result_card.dart';
import 'result_cards/cyber_result_card.dart';
import 'result_cards/wish_result_card.dart';

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
    final isYes = widget.result == "YES";
    _fortune = FortuneGenerator.generate(
      context,
      isYes,
      widget.skin.mode,
    );
  }

  Future<void> _saveCardAsImage() async {
    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes != null) {
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
      child: GestureDetector(
        onTap: widget.onClose,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: RepaintBoundary(
                child: _buildAdaptiveCard(isYes),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.elasticOut
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
    );
  }

  Widget _buildAdaptiveCard(bool isYes) {
    switch (widget.skin.mode) {
      case SkinMode.vintage:
        return VintageResultCard(isYes: isYes, fortune: _fortune);
      case SkinMode.healing:
        return HealingResultCard(isYes: isYes, fortune: _fortune);
      case SkinMode.cyber:
        return CyberResultCard(isYes: isYes, fortune: _fortune);
      case SkinMode.wish:
        return WishResultCard(isYes: isYes, fortune: _fortune);
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required AppSkin skin,
  }) {
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
