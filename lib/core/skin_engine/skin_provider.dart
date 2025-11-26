import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../skins/cyber_skin.dart';
import '../skins/healing_skin.dart';
import '../skins/vintage_skin.dart';
import '../skins/wish_skin.dart';
import 'skin_protocol.dart';

part 'skin_provider.g.dart'; // 等待 build_runner 生成代码

@Riverpod(keepAlive: true)
class CurrentSkin extends _$CurrentSkin {
  @override
  AppSkin build() {
    // 读取本地缓存逻辑可在此处添加
    return VintageSkin();
  }

  // 核心：切换指定皮肤
  void setSkin(SkinMode mode) {
    switch (mode) {
      case SkinMode.vintage:
        state = VintageSkin();
        break;
      case SkinMode.healing:
        state = HealingSkin();
        break;
      case SkinMode.cyber:
        state = CyberSkin(); // 暂时用 Vintage 代替，防止报错
        break;
      case SkinMode.wish:
        state = WishSkin();
        break;
    }
  }

  // 保留原有 toggle 逻辑作为快捷方式
  void toggleSkin() {
    // 简单的循环切换逻辑
    final nextIndex = (state.mode.index + 1) % SkinMode.values.length;
    setSkin(SkinMode.values[nextIndex]);
  }
}