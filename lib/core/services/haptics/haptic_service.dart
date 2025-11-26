import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';

class HapticService {
  final Ref _ref;

  HapticService(this._ref);

  // 检查开关
  bool get _canVibrate => _ref.read(settingsProvider).isHapticOn;

  Future<void> light() async {
    if (_canVibrate) await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (_canVibrate) await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (_canVibrate) await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (_canVibrate) await HapticFeedback.selectionClick();
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) => HapticService(ref));