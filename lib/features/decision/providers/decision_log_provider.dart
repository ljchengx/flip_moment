import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/skin_engine/skin_protocol.dart';
import '../data/decision_model.dart';

class DecisionStats {
  final int totalCount;
  final int streakDays;
  final double happyRate;

  DecisionStats({
    this.totalCount = 0,
    this.streakDays = 0,
    this.happyRate = 0.0,
  });
}

class DecisionLogNotifier extends Notifier<List<DecisionModel>> {
  late Box<DecisionModel> _box;

  @override
  List<DecisionModel> build() {
    _box = Hive.box<DecisionModel>('decisions_box');
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> addRecord(String result, SkinMode mode) async {
    final newRecord = DecisionModel.create(result: result, skinMode: mode);
    await _box.add(newRecord);
    state = [newRecord, ...state];
  }

  DecisionStats get stats {
    if (state.isEmpty) return DecisionStats();

    final total = state.length;
    final yesCount = state.where((e) => e.result == "YES").length;
    final rate = total == 0 ? 0.0 : (yesCount / total * 100);

    int streak = 0;
    final today = DateTime.now();
    streak = state.isNotEmpty ? 1 : 0;

    return DecisionStats(
      totalCount: total,
      streakDays: streak,
      happyRate: rate,
    );
  }
}

final decisionLogProvider = NotifierProvider<DecisionLogNotifier, List<DecisionModel>>(
  DecisionLogNotifier.new,
);