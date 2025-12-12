import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/cooldown_provider.dart';
import '../../../core/skin_engine/skin_protocol.dart';
import '../../../core/services/haptics/haptic_service.dart';
import '../../../features/decision/providers/decision_log_provider.dart';
import '../data/ritual_theme_config.dart';
import 'widgets/energy_orb_widget.dart';
import 'widgets/particle_aura_widget.dart';
import 'widgets/countdown_poetry_widget.dart';
import 'widgets/wisdom_quote_widget.dart';
import 'widgets/decision_counter_badge.dart';
import 'widgets/unlock_celebration_overlay.dart';

/// Main cooldown ritual screen with immersive waiting experience
class CooldownRitualScreen extends ConsumerStatefulWidget {
  final AppSkin skin;
  final VoidCallback? onComplete;

  const CooldownRitualScreen({
    super.key,
    required this.skin,
    this.onComplete,
  });

  @override
  ConsumerState<CooldownRitualScreen> createState() =>
      _CooldownRitualScreenState();
}

class _CooldownRitualScreenState extends ConsumerState<CooldownRitualScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _particleController;
  late AnimationController _celebrationController;
  late RitualThemeConfig _themeConfig;

  bool _hasTriggeredNearReadyHaptic = false;
  bool _isCelebrating = false;

  @override
  void initState() {
    super.initState();

    _themeConfig = RitualThemeConfig.fromSkin(widget.skin);

    // Breath animation (3.5s cycle, scale 0.95-1.05)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    // Particle animation (8s cycle, continuous)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Celebration animation (1s one-shot)
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _particleController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerProgressHaptic(double progress) {
    if (progress >= 0.8 && !_hasTriggeredNearReadyHaptic) {
      ref.read(hapticServiceProvider).light();
      _hasTriggeredNearReadyHaptic = true;
    }
  }

  void _triggerCelebration() {
    if (_isCelebrating) return;

    setState(() {
      _isCelebrating = true;
    });

    ref.read(hapticServiceProvider).medium();
  }

  void _handleCelebrationComplete() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cooldownState = ref.watch(cooldownProvider);
    final decisionCount = ref.watch(decisionLogProvider).length;

    // Calculate progress: 0.0 to 1.0
    final progress = cooldownState.remainingSeconds > 0
        ? 1.0 - (cooldownState.remainingSeconds / 60.0)
        : 1.0;

    // Trigger haptic feedback at 80%
    _triggerProgressHaptic(progress);

    // Trigger celebration when complete
    if (progress >= 1.0 && !_isCelebrating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerCelebration();
      });
    }

    // Accelerate breath animation when < 20 seconds (Property 12)
    if (cooldownState.remainingSeconds < 20 &&
        _breathController.duration!.inMilliseconds > 2000) {
      _breathController.duration = const Duration(milliseconds: 2000);
    }

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _themeConfig.backgroundGradient,
            ),
          ),
        ),

        // Main content
        SafeArea(
          child: Stack(
            children: [
              // Decision counter badge (top)
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: DecisionCounterBadge(
                    decisionCount: decisionCount,
                    config: _themeConfig,
                  ),
                ),
              ),

              // Center content (orb + particles + countdown)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Energy orb with particles
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Particles behind orb
                          ParticleAuraWidget(
                            config: _themeConfig,
                            progress: progress,
                            animation: _particleController,
                            isCelebrating: _isCelebrating,
                          ),

                          // Energy orb
                          EnergyOrbWidget(
                            progress: progress,
                            config: _themeConfig,
                            breathAnimation: _breathController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Countdown poetry
                    CountdownPoetryWidget(
                      remainingSeconds: cooldownState.remainingSeconds,
                      config: _themeConfig,
                    ),

                    const Spacer(),

                    // Wisdom quote (bottom)
                    WisdomQuoteWidget(
                      config: _themeConfig,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Celebration overlay
        if (_isCelebrating)
          Positioned.fill(
            child: UnlockCelebrationOverlay(
              config: _themeConfig,
              onComplete: _handleCelebrationComplete,
            ),
          ),
      ],
    );
  }
}
