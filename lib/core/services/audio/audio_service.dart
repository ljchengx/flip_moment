import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../skin_engine/skin_protocol.dart';

/// 定义听觉意图
enum SoundType {
  tap,      // 交互触发 (点击/蓄力/拉动)
  result,   // 结果揭晓 (成功/出现)
  special,  // 特殊音效 (如赛博故障声、许愿池的风铃)
}

class AudioService {
  // 使用单个播放器处理短音效，如果需要高并发(如快速点击)，可考虑使用 Soundpool
  // 但对于 audioplayers 6.0+，AudioPlayer 在低延迟模式下表现已足够好
  final AudioPlayer _player = AudioPlayer();

  // 静音状态 (未来可对接 SettingsProvider)
  bool _isMuted = false;

  AudioService() {
    // 初始化配置：设置音频上下文
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient, // 允许与其他音乐混音
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) _player.stop();
  }

  /// 核心播放方法
  /// [type]: 动作类型
  /// [mode]: 当前皮肤模式
  Future<void> play(SoundType type, SkinMode mode) async {
    if (_isMuted) return;

    // 1. 动态解析资源路径
    final assetPath = _resolvePath(type, mode);
    if (assetPath == null) return;

    try {
      // 2. 停止上一段声音 (避免重叠杂乱，可视需求调整为并发)
      if (type == SoundType.result) {
        await _player.stop(); 
      }
      
      // 3. 播放 (AssetSource 会自动查找 assets/)
      // audioplayers 6.x 写法
      await _player.play(AssetSource(assetPath), volume: 1.0);
      
    } catch (e) {
      // 生产环境建议接入 Crashlytics，开发环境打印即可
      print("⚠️ Audio Playback Error: $e");
    }
  }

  /// 路径映射逻辑
  /// 约定资源命名规范：assets/audio/{skin}_{type}.mp3
  String? _resolvePath(SoundType type, SkinMode mode) {
    // 将枚举转为字符串前缀: vintage, healing, cyber, wish
    final String prefix = mode.name; 
    
    // 将动作转为后缀
    final String suffix = type.name; 

    // 最终路径示例: "audio/vintage_tap.mp3"
    return "audio/${prefix}_${suffix}.mp3";
  }
}

// 全局 Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});