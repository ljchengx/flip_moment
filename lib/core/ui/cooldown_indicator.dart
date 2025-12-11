import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cooldown_provider.dart';
import '../skin_engine/skin_protocol.dart';

/// 冷却倒计时指示器
/// 显示圆形进度 + 剩余秒数，适配各皮肤的视觉风格
/// Requirements: 2.1, 2.4
class CooldownIndicator extends ConsumerStatefulWidget {
  final AppSkin skin;
  final double size;

  const CooldownIndicator({
    super.key,
    required this.skin,
    this.size = 120.0,
  });

  @override
  ConsumerState<CooldownIndicator> createState() => _CooldownIndicatorState();
}

class _CooldownIndicatorState extends ConsumerState<CooldownIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle pulse animation for visual feedback
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cooldownState = ref.watch(cooldownProvider);

    if (!cooldownState.isActive) {
      return const SizedBox.shrink();
    }

    final progress = cooldownState.remainingSeconds / CooldownNotifier.cooldownDuration;
    final skin = widget.skin;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: _buildIndicator(skin, cooldownState, progress),
        );
      },
    );
  }

  Widget _buildIndicator(AppSkin skin, CooldownState state, double progress) {
    // Get skin-specific styling
    final colors = _getSkinColors(skin);
    final textStyle = _getSkinTextStyle(skin);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.backgroundColor,
              border: Border.all(
                color: colors.borderColor.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // Progress indicator with smooth animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: progress, end: progress),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, animatedProgress, child) {
              return SizedBox(
                width: widget.size - 8,
                height: widget.size - 8,
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 4,
                  backgroundColor: colors.trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.progressColor),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // Countdown text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Text(
                  '${state.remainingSeconds}',
                  key: ValueKey<int>(state.remainingSeconds),
                  style: textStyle.copyWith(
                    fontSize: widget.size * 0.3,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
              ),
              Text(
                's',
                style: textStyle.copyWith(
                  fontSize: widget.size * 0.12,
                  color: colors.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _CooldownColors _getSkinColors(AppSkin skin) {
    switch (skin.mode) {
      case SkinMode.vintage:
        return _CooldownColors(
          backgroundColor: const Color(0xFF25282B),
          borderColor: skin.primaryAccent,
          trackColor: skin.primaryAccent.withOpacity(0.2),
          progressColor: skin.primaryAccent,
          textColor: skin.textPrimary,
        );
      case SkinMode.healing:
        return _CooldownColors(
          backgroundColor: Colors.white.withOpacity(0.9),
          borderColor: skin.primaryAccent,
          trackColor: skin.primaryAccent.withOpacity(0.2),
          progressColor: skin.primaryAccent,
          textColor: skin.textPrimary,
        );
      case SkinMode.cyber:
        return _CooldownColors(
          backgroundColor: const Color(0xFF111111),
          borderColor: const Color(0xFF00F0FF), // glitchBlue
          trackColor: const Color(0xFF00F0FF).withOpacity(0.2),
          progressColor: skin.primaryAccent, // Acid Green
          textColor: skin.textPrimary,
        );
      case SkinMode.wish:
        return _CooldownColors(
          backgroundColor: Colors.white.withOpacity(0.6),
          borderColor: skin.secondaryAccent,
          trackColor: skin.primaryAccent.withOpacity(0.3),
          progressColor: skin.secondaryAccent,
          textColor: skin.textPrimary,
        );
    }
  }

  TextStyle _getSkinTextStyle(AppSkin skin) {
    return skin.monoFont;
  }
}

/// Helper class for skin-specific colors
class _CooldownColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color trackColor;
  final Color progressColor;
  final Color textColor;

  const _CooldownColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.trackColor,
    required this.progressColor,
    required this.textColor,
  });
}
