import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/user_model.dart';

class UserNotifier extends Notifier<UserModel> {
  late Box<UserModel> _box;
  DateTime? _lastFlipDate;

  @override
  UserModel build() {
    _box = Hive.box<UserModel>('user_box');
    
    if (_box.isEmpty) {
      final newUser = UserModel(
        uid: const Uuid().v4(),
        nickname: "Drifter",
      );
      _box.put('current_user', newUser);
      return newUser;
    } else {
      return _box.get('current_user')!;
    }
  }

  void addExperience(int amount, {VoidCallback? onLevelUp}) {
    state.currentExp += amount;
    state.totalFlips += 1;

    bool leveledUp = false;
    while (state.currentExp >= state.maxExpForNextLevel) {
      _performLevelUp();
      leveledUp = true;
    }

    state.save();
    ref.notifyListeners();

    if (leveledUp && onLevelUp != null) {
      onLevelUp();
    }
  }

  void _performLevelUp() {
    state.currentExp -= state.maxExpForNextLevel;
    state.level += 1;
    
    state.maxExpForNextLevel = 100 + (state.level - 1) * 50;
    
    state.nickname = state.titleLabel;
  }

  void recordFlip({bool isDailyFirst = false, int streakDays = 0}) {
    int expAmount = 10;
    
    if (isDailyFirst) {
      expAmount += 50;
    }
    
    if (streakDays > 0) {
      expAmount += (streakDays * 5).clamp(0, 50);
    }
    
    addExperience(expAmount);
  }

  void recordShare() {
    addExperience(100);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel>(UserNotifier.new);