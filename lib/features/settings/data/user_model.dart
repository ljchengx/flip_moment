import 'package:hive/hive.dart';
import '../../../l10n/app_localizations.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  String nickname;

  @HiveField(2)
  int level;

  @HiveField(3)
  int totalFlips;

  @HiveField(4)
  int currentExp;

  @HiveField(5)
  int maxExpForNextLevel;

  UserModel({
    required this.uid,
    this.nickname = "Drifter", // 保留作为默认值，实际使用时会被随机生成器替换
    this.level = 1,
    this.totalFlips = 0,
    this.currentExp = 0,
    this.maxExpForNextLevel = 100,
  });

  String getTitleLabel(AppLocalizations loc) {
    if (level <= 5) return loc.titleDrifter;
    if (level <= 15) return loc.titleLightSeeker;
    if (level <= 30) return loc.titleMomentCollector;
    if (level <= 50) return loc.titleStarReader;
    return loc.titleFateArchitect;
  }

  String get titleLabel {
    if (level <= 5) return "Drifter";
    if (level <= 15) return "Light Seeker";
    if (level <= 30) return "Moment Collector";
    if (level <= 50) return "Star Reader";
    return "Fate Architect";
  }
  
  double get progress => (currentExp / maxExpForNextLevel).clamp(0.0, 1.0);
}