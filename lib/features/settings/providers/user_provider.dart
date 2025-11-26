import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/user_model.dart';

class UserNotifier extends Notifier<UserModel> {
  late Box<UserModel> _box;

  @override
  UserModel build() {
    _box = Hive.box<UserModel>('user_box');
    
    if (_box.isEmpty) {
      final newUser = UserModel(
        uid: const Uuid().v4(),
        nickname: "Fate Traveler",
      );
      _box.put('current_user', newUser);
      return newUser;
    } else {
      return _box.get('current_user')!;
    }
  }

  void incrementExp() {
    state.level += 1;
    state.save();
    ref.notifyListeners();
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel>(UserNotifier.new);