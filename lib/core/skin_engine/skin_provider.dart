import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../skins/healing_skin.dart';
import '../skins/vintage_skin.dart';
import 'skin_protocol.dart';

part 'skin_provider.g.dart'; // 等待 build_runner 生成代码

@Riverpod(keepAlive: true)
class CurrentSkin extends _$CurrentSkin {
  @override
  AppSkin build() {
    // 默认启动为复古模式，实际项目中可读取本地存储
    return VintageSkin();
  }

  void toggleSkin() {
    if (state.mode == SkinMode.vintage) {
      state = HealingSkin(); // 切换逻辑
    } else {
      state = VintageSkin();
    }
  }
}