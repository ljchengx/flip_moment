import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../skins/cyber_skin.dart';
import '../skins/healing_skin.dart';
import '../skins/vintage_skin.dart';
import '../skins/wish_skin.dart';
import 'skin_protocol.dart';

part 'skin_provider.g.dart'; // 等待 build_runner 生成代码

@Riverpod(keepAlive: true)
class CurrentSkin extends _$CurrentSkin {
  static const _kSkinKey = 'current_skin_mode_index';

  @override
  AppSkin build() {
    // 1. 从 settings_box 读取上次保存的皮肤索引
    // 注意：确保 main.dart 里已经打开了 'settings_box'
    final box = Hive.box('settings_box');
    final int savedIndex = box.get(_kSkinKey, defaultValue: SkinMode.vintage.index);
    
    // 2. 恢复皮肤
    return _getSkinFromMode(SkinMode.values[savedIndex]);
  }

  void setSkin(SkinMode mode) {
    // 1. 保存状态
    final box = Hive.box('settings_box');
    box.put(_kSkinKey, mode.index);
    
    // 2. 更新内存
    state = _getSkinFromMode(mode);
  }

  AppSkin _getSkinFromMode(SkinMode mode) {
    switch (mode) {
      case SkinMode.vintage: return VintageSkin();
      case SkinMode.healing: return HealingSkin();
      case SkinMode.cyber:   return CyberSkin(); // 实际上线时请确保 CyberSkin 已完善
      case SkinMode.wish:    return WishSkin();  // 实际上线时请确保 WishSkin 已完善
    }
  }

  // 保留原有 toggle 逻辑作为快捷方式
  void toggleSkin() {
    // 简单的循环切换逻辑
    final nextIndex = (state.mode.index + 1) % SkinMode.values.length;
    setSkin(SkinMode.values[nextIndex]);
  }
}