import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_moment/core/services/audio/audio_service.dart';
import 'package:flip_moment/core/skin_engine/skin_protocol.dart';

void main() {
  group('AudioService Tests', () {
    late ProviderContainer container;
    late AudioService audioService;

    setUp(() {
      container = ProviderContainer();
      audioService = container.read(audioServiceProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('AudioService should be instantiated correctly', () {
      expect(audioService, isNotNull);
      expect(audioService, isA<AudioService>());
    });

    test('SoundType enum should have correct values', () {
      expect(SoundType.values, contains(SoundType.tap));
      expect(SoundType.values, contains(SoundType.result));
      expect(SoundType.values, contains(SoundType.special));
    });

    test('AudioService toggleMute should work', () {
      // 测试静音切换
      audioService.toggleMute();
      // 由于没有直接的 getter 检查静音状态，我们只能确保不崩溃
      expect(() => audioService.toggleMute(), returnsNormally);
    });

    test('AudioService play should handle different sound types and modes', () async {
      // 测试播放不同类型和模式的音效
      for (final mode in SkinMode.values) {
        for (final type in SoundType.values) {
          // 由于是占位文件，可能会失败，但不应该崩溃
          await audioService.play(type, mode);
        }
      }
    });
  });
}