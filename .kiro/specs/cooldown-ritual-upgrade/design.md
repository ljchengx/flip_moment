# Design Document: Cooldown Ritual Upgrade

## Overview

本设计文档详细描述冷却系统的仪式感升级方案。基于小红书"仪式感设计：延迟满足与过程美学"的设计理念，我们将当前简单的倒计时指示器转变为一个具有情感价值、仪式感和决策重要性的沉浸式等待体验。

设计核心原则：
- **能量充能隐喻** - 将等待时间可视化为能量积蓄的过程
- **呼吸感动画** - 模拟生命体的呼吸节奏，营造冥想氛围
- **诗意化表达** - 用温暖的文案替代冷冰冰的数字
- **皮肤适配** - 每种主题都有独特的视觉表达

## Architecture

### Component Hierarchy

```
CooldownRitualScreen (ConsumerStatefulWidget)
├── BackgroundLayer
│   └── SkinThemedGradient
├── ContentLayer
│   ├── DecisionCounterBadge (top)
│   ├── EnergyOrbWidget (center)
│   │   ├── OrbGlowLayer
│   │   ├── OrbFillLayer
│   │   └── OrbBreathAnimation
│   ├── ParticleAuraWidget
│   ├── CountdownPoetryText
│   └── WisdomQuoteWidget (bottom)
├── CelebrationOverlay (conditional)
│   ├── ParticleBurst
│   └── ReadyMessage
└── AnimationControllers
    ├── breathController (3-4s cycle)
    ├── particleController (continuous)
    ├── quoteController (15-20s cycle)
    └── celebrationController (800-1200ms)
```

### State Management

使用 Riverpod 进行状态管理：
- `cooldownProvider` - 现有的冷却状态管理器
- `skinProvider` - 获取当前皮肤配置
- `userProvider` - 获取用户决策次数
- `settingsProvider` - 获取触觉反馈设置
- 本地 `AnimationController` 管理各种动画

### Integration with Existing System

```dart
// 在 DecisionScreen 中集成
if (cooldownState.isActive) {
  return CooldownRitualScreen(
    skin: currentSkin,
    cooldownState: cooldownState,
    onCooldownComplete: () => /* 返回决策界面 */,
  );
}
```

## Components and Interfaces

### 1. CooldownRitualScreen Widget

主容器组件，负责整体布局和动画协调。

```dart
class CooldownRitualScreen extends ConsumerStatefulWidget {
  final AppSkin skin;
  final CooldownState cooldownState;
  final VoidCallback onCooldownComplete;
  
  // 设计常量
  static const Duration breathCycleDuration = Duration(seconds: 4);
  static const Duration quoteRotationInterval = Duration(seconds: 18);
  static const Duration celebrationDuration = Duration(milliseconds: 1000);
}
```

### 2. EnergyOrbWidget

核心能量球组件，展示充能进度。

```dart
class EnergyOrbWidget extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final AppSkin skin;
  final Animation<double> breathAnimation;
  
  // 尺寸常量
  static const double minDiameter = 120.0;
  static const double maxDiameter = 180.0;
  
  // 发光参数
  static const double minGlowOpacity = 0.2;
  static const double maxGlowOpacity = 1.0;
  
  // 计算当前发光强度
  double get glowOpacity => minGlowOpacity + (progress * (maxGlowOpacity - minGlowOpacity));
  
  // 判断状态
  bool get isDormant => progress < 0.5;
  bool get isNearReady => progress > 0.8;
}
```

### 3. ParticleAuraWidget

漂浮粒子光环组件。

```dart
class ParticleAuraWidget extends StatefulWidget {
  final AppSkin skin;
  final double progress;
  final bool isCelebrating;
  
  // 粒子参数
  static const int minParticleCount = 8;
  static const int maxParticleCount = 15;
}

class Particle {
  Offset position;
  double size;
  double opacity;
  double angle; // 轨道角度
  double speed;
  ParticleShape shape; // 根据皮肤决定
}

enum ParticleShape {
  heart,    // Healing
  star,     // Vintage
  diamond,  // Cyber
  sparkle,  // Wish
}
```

### 4. CountdownPoetryWidget

诗意化倒计时组件。

```dart
class CountdownPoetryWidget extends StatelessWidget {
  final int remainingSeconds;
  final AppSkin skin;
  
  // 时间阈值
  static const int gatheringThreshold = 45;
  static const int almostReadyThreshold = 20;
  
  String getDisplayText(AppLocalizations loc) {
    if (remainingSeconds > gatheringThreshold) {
      return _getGatheringPhrase(loc);
    } else if (remainingSeconds > almostReadyThreshold) {
      return _getAlmostReadyPhrase(loc);
    } else {
      return remainingSeconds.toString();
    }
  }
}
```

### 5. WisdomQuoteWidget

智慧语录组件。

```dart
class WisdomQuoteWidget extends StatefulWidget {
  final AppSkin skin;
  
  // 语录池
  static const List<String> quotes = [
    "每一个决定都是通往未来的钥匙",
    "静心等待，答案自会浮现",
    "命运眷顾有准备的人",
    "深呼吸，让直觉引导你",
    "好事多磨，耐心是最好的礼物",
    // ... 更多语录
  ];
  
  static const Duration fadeTransitionDuration = Duration(milliseconds: 600);
}
```

### 6. DecisionCounterBadge

决策计数徽章组件。

```dart
class DecisionCounterBadge extends StatelessWidget {
  final int decisionCount;
  final AppSkin skin;
  
  // 格式化显示
  String getFormattedCount(AppLocalizations loc) {
    return loc.decisionCountFormat(decisionCount + 1);
    // 中文: "第 {n} 次决策"
    // 英文: "Decision #{n}"
  }
}
```

### 7. UnlockCelebrationOverlay

解锁庆祝动画覆盖层。

```dart
class UnlockCelebrationOverlay extends StatefulWidget {
  final AppSkin skin;
  final VoidCallback onComplete;
  
  static const Duration duration = Duration(milliseconds: 1000);
}
```

## Data Models

### RitualThemeConfig

每种皮肤的仪式主题配置。

```dart
class RitualThemeConfig {
  final List<Color> gradientColors;
  final Color orbGlowColor;
  final Color orbFillColor;
  final ParticleShape particleShape;
  final Color particleColor;
  final TextStyle quoteTextStyle;
  
  // 工厂方法
  factory RitualThemeConfig.fromSkin(AppSkin skin) {
    switch (skin.mode) {
      case SkinMode.healing:
        return RitualThemeConfig(
          gradientColors: [Color(0xFFFFF5EE), Color(0xFFFFE4E1)],
          orbGlowColor: Color(0xFFFFB7B2), // 腮红粉
          orbFillColor: Color(0xFFE0BBE4), // 烟粉豆沙
          particleShape: ParticleShape.heart,
          particleColor: Color(0xFFFFB7B2),
          quoteTextStyle: GoogleFonts.maShanZheng(...),
        );
      case SkinMode.vintage:
        return RitualThemeConfig(
          gradientColors: [Color(0xFF1A1C1E), Color(0xFF2C2F33)],
          orbGlowColor: Color(0xFFC6A664), // 复古金
          orbFillColor: Color(0xFF8F3B35), // 复古红
          particleShape: ParticleShape.star,
          particleColor: Color(0xFFC6A664),
          quoteTextStyle: GoogleFonts.playfairDisplay(...),
        );
      case SkinMode.cyber:
        return RitualThemeConfig(
          gradientColors: [Color(0xFF050505), Color(0xFF1A0033)],
          orbGlowColor: Color(0xFF00F0FF), // 故障蓝
          orbFillColor: Color(0xFFCCFF00), // 酸性绿
          particleShape: ParticleShape.diamond,
          particleColor: Color(0xFF00F0FF),
          quoteTextStyle: GoogleFonts.vt323(...),
        );
      case SkinMode.wish:
        return RitualThemeConfig(
          gradientColors: [Color(0xFFD4F1F4), Color(0xFFB8E2E8)],
          orbGlowColor: Color(0xFFFCE38A), // 星光金
          orbFillColor: Color(0xFF2B5876), // 深海蓝
          particleShape: ParticleShape.sparkle,
          particleColor: Color(0xFFFCE38A),
          quoteTextStyle: GoogleFonts.alegreya(...),
        );
    }
  }
}
```

### CountdownPhrases

倒计时诗意化文案。

```dart
class CountdownPhrases {
  // 阶段1: > 45秒 (静心等待)
  static const gatheringPhrases = [
    "静心片刻...",
    "能量汇聚中...",
    "命运正在编织...",
  ];
  
  static const gatheringPhrasesEn = [
    "Gathering energy...",
    "Centering your spirit...",
    "Fate is weaving...",
  ];
  
  // 阶段2: 20-45秒 (即将准备好)
  static const almostReadyPhrases = [
    "即将准备好...",
    "能量充盈中...",
    "答案渐渐清晰...",
  ];
  
  static const almostReadyPhrasesEn = [
    "Almost ready...",
    "Energy rising...",
    "Clarity approaching...",
  ];
}
```

## Error Handling

### 动画异常处理

```dart
@override
void dispose() {
  // 安全清理所有动画控制器
  _breathController.dispose();
  _particleController.dispose();
  _quoteTimer?.cancel();
  super.dispose();
}
```

### 皮肤配置缺失

```dart
// 提供默认配置
final config = RitualThemeConfig.fromSkin(skin) ?? RitualThemeConfig.defaultConfig;
```

### 触觉反馈异常

```dart
Future<void> _triggerHaptic(HapticType type) async {
  try {
    if (!settingsProvider.hapticEnabled) return;
    await hapticService.trigger(type);
  } catch (e) {
    // 静默失败，不影响主流程
    debugPrint('Haptic feedback failed: $e');
  }
}
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following correctness properties have been identified for property-based testing:

### Property 1: Progress-Based Fill Percentage

*For any* cooldown progress value between 0.0 and 1.0, the Energy_Orb fill percentage SHALL equal the progress value, ensuring visual representation accurately reflects elapsed time.

**Validates: Requirements 2.1**

### Property 2: Progress-Based Glow Intensity

*For any* cooldown progress value between 0.0 and 1.0, the Energy_Orb glow opacity SHALL equal `0.2 + (progress * 0.8)`, resulting in opacity range from 0.2 (empty) to 1.0 (full).

**Validates: Requirements 2.2**

### Property 3: Threshold State Determination

*For any* cooldown progress value:
- If progress < 0.5, the orb state SHALL be "dormant" (dim appearance)
- If progress >= 0.5 and < 0.8, the orb state SHALL be "charging" (normal appearance)
- If progress >= 0.8, the orb state SHALL be "nearReady" (pulsing glow)

**Validates: Requirements 2.3, 2.4**

### Property 4: Particle Count Bounds

*For any* rendering of the ParticleAuraWidget, the number of particles SHALL be between 8 and 15 inclusive.

**Validates: Requirements 3.1**

### Property 5: Particle Color Skin Matching

*For any* skin mode, the particle colors used in ParticleAuraWidget SHALL be derived from that skin's accent color palette (primaryAccent or secondaryAccent).

**Validates: Requirements 3.5**

### Property 6: Wisdom Quote Vocabulary

*For any* displayed wisdom quote, the text SHALL be a member of the predefined curated quote list, ensuring only approved healing/philosophical content is shown.

**Validates: Requirements 4.2**

### Property 7: Countdown Poetry Threshold Mapping

*For any* remaining time value in seconds:
- If remainingSeconds > 45, the display SHALL be from the "gathering" phrase set
- If remainingSeconds is between 20 and 45 (inclusive), the display SHALL be from the "almostReady" phrase set
- If remainingSeconds < 20, the display SHALL include the numeric countdown value

**Validates: Requirements 5.2, 5.3, 5.4**

### Property 8: Decision Counter Format

*For any* non-negative integer decision count n, the formatted display string SHALL match the pattern "第 {n+1} 次决策" (Chinese) or "Decision #{n+1}" (English), where n+1 represents the upcoming decision number.

**Validates: Requirements 6.2**

### Property 9: Skin-Specific Ritual Rendering

*For any* skin mode, the RitualThemeConfig SHALL return:
- Healing: pink/peach glow colors and heart-shaped particles
- Vintage: amber glow colors and star-shaped particles
- Cyber: cyan/green glow colors and diamond-shaped particles
- Wish: purple/blue glow colors and sparkle-shaped particles

**Validates: Requirements 7.1, 7.2, 7.3, 7.4**

### Property 10: Haptic Settings Respect

*For any* haptic trigger event, if the user's haptic settings are disabled, the system SHALL NOT invoke any haptic feedback methods. If enabled, the appropriate haptic type SHALL be triggered.

**Validates: Requirements 9.4, 9.5**

### Property 11: Breath Animation Scale Bounds

*For any* frame of the Breath_Animation, the scale factor applied to the Energy_Orb SHALL be between 0.95 and 1.05 inclusive.

**Validates: Requirements 10.2**

### Property 12: Breath Animation Acceleration

*For any* remaining time below 20 seconds, the Breath_Animation cycle duration SHALL be shorter than the default 3-4 second cycle, indicating urgency through faster pulsing.

**Validates: Requirements 10.4**

## Testing Strategy

### Property-Based Testing Framework

本项目使用 **flutter_test** 结合自定义随机生成器进行属性测试。每个属性测试将运行至少 100 次迭代。

### Property-Based Tests

每个正确性属性将实现为独立的属性测试：

```dart
// 示例：Property 1 - Progress-Based Fill Percentage
// **Feature: cooldown-ritual-upgrade, Property 1: Progress-Based Fill Percentage**
void testProgressBasedFill() {
  final random = Random();
  for (int i = 0; i < 100; i++) {
    final progress = random.nextDouble(); // 0.0 - 1.0
    final fillPercentage = EnergyOrbWidget.calculateFillPercentage(progress);
    expect(fillPercentage, closeTo(progress, 0.001));
  }
}

// 示例：Property 7 - Countdown Poetry Threshold Mapping
// **Feature: cooldown-ritual-upgrade, Property 7: Countdown Poetry Threshold Mapping**
void testCountdownPoetryThresholds() {
  final random = Random();
  for (int i = 0; i < 100; i++) {
    final seconds = random.nextInt(61); // 0-60 seconds
    final displayText = CountdownPoetryWidget.getDisplayText(seconds);
    
    if (seconds > 45) {
      expect(CountdownPhrases.gatheringPhrases.contains(displayText) ||
             CountdownPhrases.gatheringPhrasesEn.contains(displayText), isTrue);
    } else if (seconds >= 20) {
      expect(CountdownPhrases.almostReadyPhrases.contains(displayText) ||
             CountdownPhrases.almostReadyPhrasesEn.contains(displayText), isTrue);
    } else {
      expect(displayText.contains(seconds.toString()), isTrue);
    }
  }
}
```

### Unit Tests

单元测试覆盖以下关键场景：

1. **组件渲染测试**
   - 验证 CooldownRitualScreen 在冷却激活时正确显示
   - 验证 EnergyOrbWidget 正确渲染不同进度状态
   - 验证 ParticleAuraWidget 粒子数量在范围内

2. **状态转换测试**
   - 冷却开始时显示仪式界面
   - 冷却结束时触发庆祝动画
   - 庆祝动画完成后返回决策界面

3. **皮肤适配测试**
   - 每种皮肤的颜色配置正确
   - 粒子形状与皮肤匹配

### Widget Tests

```dart
testWidgets('CooldownRitualScreen displays when cooldown is active', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cooldownProvider.overrideWith(() => MockCooldownNotifier(isActive: true)),
      ],
      child: MaterialApp(
        home: CooldownRitualScreen(skin: HealingSkin()),
      ),
    ),
  );
  
  expect(find.byType(EnergyOrbWidget), findsOneWidget);
  expect(find.byType(WisdomQuoteWidget), findsOneWidget);
});
```

### Test File Structure

```
test/
├── core/
│   ├── ui/
│   │   ├── cooldown_ritual_screen_test.dart
│   │   ├── energy_orb_widget_test.dart
│   │   ├── particle_aura_widget_test.dart
│   │   └── cooldown_ritual_properties_test.dart  // 属性测试
│   └── providers/
│       └── cooldown_provider_test.dart  // 已存在，需扩展
```

### Test Tagging Convention

所有属性测试必须使用以下格式标注：

```dart
// **Feature: cooldown-ritual-upgrade, Property {number}: {property_text}**
```

例如：
```dart
// **Feature: cooldown-ritual-upgrade, Property 9: Skin-Specific Ritual Rendering**
test('skin-specific ritual config returns correct values', () {
  // test implementation
});
```

