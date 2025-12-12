import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 冷却状态数据类
/// Requirements: 1.1, 1.2, 1.3
class CooldownState {
  final bool isActive;
  final int remainingSeconds;
  final DateTime? endTime;

  const CooldownState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.endTime,
  });

  CooldownState copyWith({
    bool? isActive,
    int? remainingSeconds,
    DateTime? endTime,
  }) {
    return CooldownState(
      isActive: isActive ?? this.isActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CooldownState &&
        other.isActive == isActive &&
        other.remainingSeconds == remainingSeconds &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(isActive, remainingSeconds, endTime);

  @override
  String toString() =>
      'CooldownState(isActive: $isActive, remainingSeconds: $remainingSeconds, endTime: $endTime)';
}

/// 冷却状态管理器
/// Requirements: 1.1, 1.2, 1.3, 3.2
class CooldownNotifier extends Notifier<CooldownState> {
  static const _boxName = 'settings_box';
  static const _kCooldownEndKey = 'cooldown_end_timestamp';
  static const cooldownDuration = 60; // 秒

  Timer? _timer;

  @override
  CooldownState build() {
    // 在 dispose 时取消 timer
    ref.onDispose(() {
      _timer?.cancel();
    });

    // 检查持久化的冷却状态
    _checkPersistedCooldown();
    return const CooldownState();
  }

  /// 检查并恢复持久化的冷却状态
  /// Requirements: 3.2
  Future<void> _checkPersistedCooldown() async {
    try {
      final box = await Hive.openBox(_boxName);
      final int? endTimestamp = box.get(_kCooldownEndKey);

      if (endTimestamp != null) {
        final endTime = DateTime.fromMillisecondsSinceEpoch(endTimestamp);
        final now = DateTime.now();

        if (endTime.isAfter(now)) {
          // 冷却仍然有效，恢复状态
          final remaining = endTime.difference(now).inSeconds;
          state = CooldownState(
            isActive: true,
            remainingSeconds: remaining,
            endTime: endTime,
          );
          _startTimer();
        } else {
          // 冷却已过期，清除持久化数据
          await box.delete(_kCooldownEndKey);
        }
      }
    } catch (e) {
      // Hive 读取失败，默认返回无冷却状态
      state = const CooldownState();
    }
  }

  /// 启动冷却
  /// Requirements: 1.1
  Future<void> startCooldown() async {
    debugPrint('[FM] startCooldown 被调用');
    final endTime = DateTime.now().add(const Duration(seconds: cooldownDuration));

    // 🔥 先更新状态（同步），确保 UI 立即响应
    state = CooldownState(
      isActive: true,
      remainingSeconds: cooldownDuration,
      endTime: endTime,
    );
    debugPrint('[FM] cooldown state更新: isActive=${state.isActive}, remaining=${state.remainingSeconds}');

    _startTimer();

    // 然后持久化结束时间戳（异步，不阻塞 UI）
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_kCooldownEndKey, endTime.millisecondsSinceEpoch);
      debugPrint('[FM] cooldown 持久化完成');
    } catch (e) {
      debugPrint('[FM] cooldown 持久化失败: $e');
    }
  }

  /// 启动倒计时 Timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  /// 每秒更新倒计时
  void _tick() {
    if (state.endTime == null) {
      _clearCooldown();
      return;
    }

    final now = DateTime.now();
    final remaining = state.endTime!.difference(now).inSeconds;

    if (remaining <= 0) {
      _clearCooldown();
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  /// 清除冷却状态
  /// Requirements: 3.4
  Future<void> _clearCooldown() async {
    _timer?.cancel();
    _timer = null;

    // 清除持久化数据
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_kCooldownEndKey);
    } catch (e) {
      // 清除失败，不影响主流程
    }

    state = const CooldownState();
  }

  /// 检查是否可以执行决策操作
  /// Requirements: 1.2, 1.3
  bool canPerformDecision() {
    return !state.isActive || state.remainingSeconds <= 0;
  }
}

/// 冷却状态 Provider
final cooldownProvider = NotifierProvider<CooldownNotifier, CooldownState>(
  CooldownNotifier.new,
);
