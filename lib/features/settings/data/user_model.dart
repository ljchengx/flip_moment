import 'package:hive/hive.dart';

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

  UserModel({
    required this.uid,
    this.nickname = "Traveler",
    this.level = 1,
    this.totalFlips = 0,
  });
}