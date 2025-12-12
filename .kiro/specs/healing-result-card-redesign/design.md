# Design Document: Healing Result Card Redesign

## Overview

本设计文档详细描述治愈主题结果卡片的重新设计方案。基于小红书"治愈系与软性生产力"美学支柱，我们将创建一个具有高情绪价值、强氛围感和社交货币属性的结果展示组件。

设计核心原则：
- **奶呼呼的配色** - 使用莫兰迪色系的低饱和度渐变
- **极致圆润** - 32px+ 的超椭圆圆角，无锐角设计
- **手账质感** - 点阵纹理、和纸胶带、贴纸装饰
- **情感陪伴** - 拟人化的视觉语言，温暖的文案

## Architecture

### Component Hierarchy

```
HealingResultCard (StatefulWidget)
├── BackgroundLayer
│   ├── SoftGradientBackground
│   ├── DotGridPattern
│   └── WatermarkIcon
├── ContentLayer
│   ├── WashiTapeDateLabel
│   ├── UserInfoBadge
│   ├── MainTitleText
│   ├── SubtitleText
│   └── BottomSection
│       ├── LuckyPillWidget
│       └── ResultStickerWidget
├── DecorationLayer
│   └── FloatingParticles
└── AnimationController
    ├── ScaleAnimation
    ├── FadeAnimation
    └── ShimmerAnimation
```

### State Management

使用 Riverpod 进行状态管理：
- `userProvider` - 获取用户信息（等级、称号、决策次数）
- `skinProvider` - 获取当前皮肤配置
- 本地 `AnimationController` 管理入场动画

## Components and Interfaces

### 1. HealingNoteCard Widget

主容器组件，负责整体布局和动画协调。

```dart
class HealingNoteCard extends ConsumerStatefulWidget {
  final bool isYes;           // 决策结果
  final FortuneData fortune;  // 运势数据
  final VoidCallback onClose; // 关闭回调
  
  // 设计常量
  static const double cardBorderRadius = 32.0;
  static const double maxCardWidth = 340.0;
  static const Duration animationDuration = Duration(milliseconds: 600);
}
```

### 2. SoftGradientBackground

柔和渐变背景组件。

```dart
class SoftGradientBackground extends StatelessWidget {
  final bool isPositive;
  
  // 正面结果：暖色调
  static const positiveColors = [
    Color(0xFFFFF5EE), // Seashell (奶桃色)
    Color(0xFFFFE4E1), // Misty Rose (雾玫瑰)
  ];
  
  // 负面结果：冷色调
  static const negativeColors = [
    Color(0xFFF0FFF0), // Honeydew (薄荷奶)
    Color(0xFFE6E6FA), // Lavender (薰衣草)
  ];
}
```

### 3. WatermarkIcon

大型半透明水印图标。

```dart
class WatermarkIcon extends StatelessWidget {
  final bool isPositive;
  
  // 正面：爱心图标
  // 负面：云朵图标
  static const double sizeRatio = 0.7; // 相对于卡片宽度
  static const double opacity = 0.4;
  static const Offset offset = Offset(-40, -30);
}
```

### 4. WashiTapeDateLabel

和纸胶带风格的日期标签。

```dart
class WashiTapeDateLabel extends StatelessWidget {
  final DateTime date;
  
  // 格式："12月12日 · 今天"
  static const double rotationAngle = -0.03; // 微微倾斜
  static const Color backgroundColor = Color(0x99FFFFFF);
}
```

### 5. UserInfoBadge

用户信息徽章组件。

```dart
class UserInfoBadge extends StatelessWidget {
  final String userTitle;
  final int decisionCount;
  final Color accentColor;
  
  // 药丸形状，包含称号和决策次数
}
```

### 6. LuckyPillWidget

幸运色药丸组件。

```dart
class LuckyPillWidget extends StatelessWidget {
  final Color luckyColor;
  final String colorName;
  
  // 白色胶囊容器
  // 内含圆形色块 + 颜色名称
  static const double colorSwatchSize = 28.0;
}
```

### 7. ResultStickerWidget

结果贴纸组件。

```dart
class ResultStickerWidget extends StatelessWidget {
  final bool isPositive;
  final Color accentColor;
  
  // 正面文案池
  static const positiveTexts = ["PERFECT!", "NICE!", "GO FOR IT!", "YES!"];
  
  // 负面文案池
  static const negativeTexts = ["CHILL~", "WAIT~", "NEXT TIME~", "PAUSE~"];
  
  static const double rotationAngle = 0.15; // 俏皮倾斜
  static const double borderWidth = 4.0;
}
```

### 8. FloatingParticles

漂浮粒子装饰组件。

```dart
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  
  // 使用 CustomPainter 绘制星星/爱心粒子
  // 应用缓慢的上下浮动动画
}
```

### 9. DotGridPainter

手账点阵纹理绘制器。

```dart
class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double dotRadius;
  
  static const double defaultSpacing = 26.0;
  static const double defaultDotRadius = 1.5;
  static const double defaultOpacity = 0.15;
}
```

## Data Models

### FortuneData

```dart
class FortuneData {
  final String mainTitle;      // 主标题（如"去做吧"、"再等等"）
  final String subTitle;       // 副标题（鼓励性文案）
  final int stars;             // 星级评分 (3-5)
  final Color luckyColor;      // 幸运色
  final String luckyColorName; // 幸运色名称
}
```

### HealingColorPalette

```dart
class HealingColorPalette {
  // 背景渐变色
  static const warmGradient = [Color(0xFFFFF5EE), Color(0xFFFFE4E1)];
  static const coolGradient = [Color(0xFFF0FFF0), Color(0xFFE6E6FA)];
  
  // 文字颜色
  static const mainTextColor = Color(0xFF5D4037); // 暖咖色
  
  // 强调色
  static const warmAccent = Color(0xFFFFAB91);  // 珊瑚橙
  static const coolAccent = Color(0xFF81D4FA);  // 天空蓝
  
  // 装饰色
  static const blushPink = Color(0xFFFFB7B2);   // 腮红粉
}
```

### HealingTextStyles

```dart
class HealingTextStyles {
  // 主标题：ZCOOL KuaiLe
  static TextStyle mainTitle(Color color) => GoogleFonts.zcoolKuaiLe(
    fontSize: 64,
    color: color,
    height: 1.1,
  );
  
  // 副标题：Ma Shan Zheng
  static TextStyle subtitle(Color color) => GoogleFonts.maShanZheng(
    fontSize: 22,
    color: color.withOpacity(0.7),
    height: 1.4,
  );
  
  // 日期标签：Ma Shan Zheng
  static TextStyle dateLabel(Color color) => GoogleFonts.maShanZheng(
    fontSize: 14,
    color: color.withOpacity(0.8),
    letterSpacing: 1,
  );
  
  // 徽章文字：Fredoka
  static TextStyle badge(Color color) => GoogleFonts.fredoka(
    fontSize: 12,
    color: color,
    fontWeight: FontWeight.w600,
  );
  
  // 贴纸文字：Fredoka Bold
  static TextStyle sticker() => GoogleFonts.fredoka(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );
}
```

## Error Handling

### 字体加载失败

```dart
// 使用 Google Fonts 的 fallback 机制
GoogleFonts.zcoolKuaiLe().fontFamily ?? 'sans-serif'
```

### 用户数据缺失

```dart
// 提供默认值
final userTitle = user?.getTitleLabel(loc) ?? loc.defaultTitle;
final decisionCount = user?.totalFlips ?? 0;
```

### 动画异常

```dart
// 在 dispose 中安全清理
@override
void dispose() {
  if (_controller.isAnimating) {
    _controller.stop();
  }
  _controller.dispose();
  super.dispose();
}
```

### 截图失败

```dart
try {
  final bytes = await screenshotController.capture(pixelRatio: 3.0);
  if (bytes != null) {
    await Gal.putImageBytes(bytes);
    // 显示成功提示
  }
} catch (e) {
  // 显示错误提示，不崩溃
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("保存失败: $e")),
  );
}
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following correctness properties have been identified for property-based testing:

### Property 1: Gradient Color Selection Based on Result

*For any* decision result (YES or NO), the gradient background colors SHALL be selected from the correct palette - warm colors (peachy-cream to soft-rose) for positive results, cool colors (mint-cream to lavender) for negative results.

**Validates: Requirements 1.1, 1.2, 1.3**

### Property 2: Watermark Icon Selection Based on Result

*For any* decision result, the watermark icon SHALL be a heart icon for positive results and a cloud icon for negative results, with size between 60-80% of card width.

**Validates: Requirements 2.1**

### Property 3: Text Styling Constraints

*For any* text element in the card, the font sizes SHALL be within specified ranges: main title 56-72px, subtitle 20-28px, user info 11-13px, and line-height SHALL be between 1.3-1.5.

**Validates: Requirements 3.1, 3.3, 3.4, 4.5**

### Property 4: Decision Count Formatting

*For any* non-negative integer decision count, the formatted display string SHALL match the pattern "×{count}" where {count} is the integer value.

**Validates: Requirements 4.3**

### Property 5: User Title Truncation

*For any* user title string, if the string length exceeds the maximum display width, the system SHALL truncate with ellipsis and display on a single line without overflow.

**Validates: Requirements 4.4**

### Property 6: Sticker Text Vocabulary

*For any* decision result, the sticker text SHALL be selected from the predefined vocabulary - positive texts ["PERFECT!", "NICE!", "GO FOR IT!", "YES!"] for YES results, negative texts ["CHILL~", "WAIT~", "NEXT TIME~", "PAUSE~"] for NO results.

**Validates: Requirements 6.2, 6.3**

### Property 7: Sticker Styling Constraints

*For any* Result_Sticker rendering, the rotation angle SHALL be between 10-20 degrees (0.17-0.35 radians), border width SHALL be between 3-5 pixels, and shadow color SHALL match the accent color.

**Validates: Requirements 6.4, 6.5, 6.6**

### Property 8: Card Aspect Ratio

*For any* card rendering, the aspect ratio (width/height) SHALL be approximately between 0.6 and 0.8 (corresponding to 3:4 to 4:5 ratios) to ensure social media compatibility.

**Validates: Requirements 8.2**

### Property 9: Encouraging Phrase Vocabulary

*For any* positive decision result, the subtitle message SHALL be selected from a curated healing-style vocabulary that contains only encouraging, warm phrases.

**Validates: Requirements 3.5**

### Property 10: Lucky Color Swatch Size

*For any* Lucky_Pill rendering, the circular color swatch diameter SHALL be between 24-32 pixels.

**Validates: Requirements 5.2**

## Testing Strategy

### Property-Based Testing Framework

本项目使用 **flutter_test** 结合 **dart_quickcheck** 或自定义随机生成器进行属性测试。每个属性测试将运行至少 100 次迭代。

### Property-Based Tests

每个正确性属性将实现为独立的属性测试：

```dart
// 示例：Property 1 - Gradient Color Selection
// **Feature: healing-result-card-redesign, Property 1: Gradient Color Selection Based on Result**
void testGradientColorSelection() {
  for (int i = 0; i < 100; i++) {
    final isYes = Random().nextBool();
    final colors = HealingColorPalette.getGradientColors(isYes);
    
    if (isYes) {
      expect(colors, equals(HealingColorPalette.warmGradient));
    } else {
      expect(colors, equals(HealingColorPalette.coolGradient));
    }
  }
}
```

### Unit Tests

单元测试覆盖以下关键场景：

1. **组件渲染测试**
   - 验证 HealingNoteCard 正确渲染所有子组件
   - 验证 LuckyPillWidget 显示正确的颜色和名称
   - 验证 ResultStickerWidget 显示正确的文案

2. **边界条件测试**
   - 空用户称号处理
   - 超长用户称号截断
   - 决策次数为 0 的显示

3. **颜色映射测试**
   - 正面结果使用暖色调
   - 负面结果使用冷色调

### Widget Tests

```dart
testWidgets('HealingNoteCard renders with correct gradient for YES result', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HealingNoteCard(isYes: true, fortune: mockFortune),
    ),
  );
  
  // 验证渐变背景存在
  final container = tester.widget<Container>(find.byType(Container).first);
  final decoration = container.decoration as BoxDecoration;
  expect(decoration.gradient, isNotNull);
});
```

### Test File Structure

```
test/
├── features/
│   └── decision/
│       └── presentation/
│           └── widgets/
│               ├── healing_note_card_test.dart
│               ├── lucky_pill_widget_test.dart
│               ├── result_sticker_widget_test.dart
│               └── healing_card_properties_test.dart  // 属性测试
```

### Test Tagging Convention

所有属性测试必须使用以下格式标注：

```dart
// **Feature: healing-result-card-redesign, Property {number}: {property_text}**
```

例如：
```dart
// **Feature: healing-result-card-redesign, Property 4: Decision Count Formatting**
test('decision count formatting follows pattern', () {
  // test implementation
});
```
