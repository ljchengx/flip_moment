import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  final bool isSoundOn;
  final bool isHapticOn;

  const AppSettings({this.isSoundOn = true, this.isHapticOn = true});

  AppSettings copyWith({bool? isSoundOn, bool? isHapticOn}) {
    return AppSettings(
      isSoundOn: isSoundOn ?? this.isSoundOn,
      isHapticOn: isHapticOn ?? this.isHapticOn,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  late Box _box;
  static const _kSoundKey = 'setting_sound_on';
  static const _kHapticKey = 'setting_haptic_on';

  @override
  AppSettings build() {
    _box = Hive.box('settings_box'); // 确保 main.dart 里已经 openBox('settings_box')
    return AppSettings(
      isSoundOn: _box.get(_kSoundKey, defaultValue: true),
      isHapticOn: _box.get(_kHapticKey, defaultValue: true),
    );
  }

  void toggleSound(bool value) {
    _box.put(_kSoundKey, value);
    state = state.copyWith(isSoundOn: value);
  }

  void toggleHaptic(bool value) {
    _box.put(_kHapticKey, value);
    state = state.copyWith(isHapticOn: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);