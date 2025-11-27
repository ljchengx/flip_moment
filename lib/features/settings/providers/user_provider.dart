import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/user_model.dart';
import '../../../core/utils/username_generator.dart';

class UserNotifier extends Notifier<UserModel> {
  late Box<UserModel> _box;
  DateTime? _lastFlipDate;

  @override
  UserModel build() {
    _box = Hive.box<UserModel>('user_box');
    
    if (_box.isEmpty) {
      return _createNewGuestUser();
    } else {
      final existingUser = _box.get('current_user');
      if (existingUser != null) {
        return existingUser;
      } else {
        return _createNewGuestUser();
      }
    }
  }

  /// 创建一个全新的游客用户
  UserModel _createNewGuestUser() {
    final randomNickname = UsernameGenerator.generateRandomUsername();
    
    final newUser = UserModel(
      uid: const Uuid().v4(),
      nickname: randomNickname,
      level: 1,
      currentExp: 0,
      totalFlips: 0,
      maxExpForNextLevel: 100,
    );

    _box.put('current_user', newUser);
    debugPrint("🆕 Created New Guest User: ${newUser.nickname} (${newUser.uid})");
    
    return newUser;
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
    
    // 不再更改昵称，保留用户的个性化身份
    // 称号系统通过 getTitleLabel() 方法独立获取
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

  /// 重置用户身份 (调试用)
  /// 清除当前用户数据并创建新的随机身份
  Future<void> resetIdentity() async {
    await _box.delete('current_user');
    state = _createNewGuestUser();
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel>(UserNotifier.new);