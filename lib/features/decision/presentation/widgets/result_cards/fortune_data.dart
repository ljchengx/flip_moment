import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/skin_engine/skin_protocol.dart';
import '../../../../../l10n/app_localizations.dart';

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
