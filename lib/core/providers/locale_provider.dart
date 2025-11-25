import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 定义 Locale 状态管理器
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('zh')) { // 默认中文
    _loadLocale();
  }

  static const _boxName = 'settings_box';
  static const _keyName = 'locale_code';

  Future<void> _loadLocale() async {
    final box = await Hive.openBox(_boxName);
    final String? savedCode = box.get(_keyName);
    if (savedCode != null) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final box = await Hive.openBox(_boxName);
    await box.put(_keyName, locale.languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      setLocale(const Locale('zh'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});