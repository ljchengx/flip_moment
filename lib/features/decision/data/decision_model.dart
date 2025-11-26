import 'package:hive/hive.dart';
import '../../../core/skin_engine/skin_protocol.dart';

part 'decision_model.g.dart';

@HiveType(typeId: 1)
class DecisionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String result;

  @HiveField(3)
  final String skinModeName;

  DecisionModel({
    required this.id,
    required this.timestamp,
    required this.result,
    required this.skinModeName,
  });

  factory DecisionModel.create({
    required String result,
    required SkinMode skinMode,
  }) {
    return DecisionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      result: result,
      skinModeName: skinMode.name,
    );
  }
}