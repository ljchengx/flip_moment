# Design Document: Result Card Text Layout Optimization

## Overview

本设计文档详细描述结果卡片中长文本内容的排版优化方案，重点解决副标题文本出现"孤字"（单个字符独占一行）的问题。

设计核心原则：
- **消除孤字** - 确保任何情况下都不会出现单字独行
- **主题差异化** - 复古主题紧凑单行，治愈主题柔软多行
- **响应式适配** - 不同屏幕宽度下保持良好排版

## Architecture

### Text Layout Strategy

```
TextLayoutStrategy (Abstract)
├── VintageTextLayout
│   ├── SingleLineFittedBox (优先)
│   └── BalancedTwoLineBreak (降级)
└── HealingTextLayout
    ├── SoftWrapWithMinChars
    └── OrphanPreventionBreak
```

### Component Hierarchy

```
ResultCard
├── MainTitleSection
│   └── FittedBox + Text (缩放适配)
└── SubTitleSection
    ├── VintageSubTitle (复古主题)
    │   └── FittedBox + Container(背景) + Text
    └── HealingSubTitle (治愈主题)
        └── LayoutBuilder + CustomTextPainter
```

## Components and Interfaces

### 1. OrphanPreventionText Widget

通用的防孤字文本组件，作为基础工具类。

```dart
class OrphanPreventionText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int minCharsPerLine;  // 每行最少字符数
  final TextAlign textAlign;
  
  // 核心算法：计算最优换行点
  String _preventOrphans(String text, double maxWidth, TextStyle style) {
    // 1. 测量文本宽度
    // 2. 如果需要换行，找到最优换行点
    // 3. 确保每行至少 minCharsPerLine 个字符
  }
}
```

### 2. VintageSubTitleText Widget

复古主题专用的副标题组件。

```dart
class VintageSubTitleText extends StatelessWidget {
  final String text;
  
  static const double maxFontSize = 20.0;
  static const double minFontSize = 14.0;
  static const double letterSpacing = 1.2;
  static const double backgroundOpacity = 0.05;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: Colors.black.withOpacity(backgroundOpacity),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: GoogleFonts.maShanZheng(
              fontSize: maxFontSize,
              color: Colors.black54,
              letterSpacing: letterSpacing,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3. HealingSubTitleText Widget

治愈主题专用的副标题组件。

```dart
class HealingSubTitleText extends StatelessWidget {
  final String text;
  final Color textColor;
  
  static const double fontSize = 24.0;
  static const double lineHeight = 1.5;
  static const int minCharsPerLine = 4;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final processedText = _balanceLineBreaks(
          text, 
          constraints.maxWidth,
          minCharsPerLine,
        );
        
        return Text(
          processedText,
          textAlign: TextAlign.center,
          style: GoogleFonts.maShanZheng(
            fontSize: fontSize,
            color: textColor,
            height: lineHeight,
          ),
        );
      },
    );
  }
  
  /// 平衡换行算法
  /// 确保每行至少有 minChars 个字符
  String _balanceLineBreaks(String text, double maxWidth, int minChars) {
    // 实现细节见下方算法说明
  }
}
```

### 4. 换行平衡算法

```dart
/// 核心算法：防止孤字的智能换行
class TextBreakBalancer {
  /// 计算最优换行方案
  /// 
  /// [text] 原始文本
  /// [maxWidth] 容器最大宽度
  /// [style] 文本样式
  /// [minCharsPerLine] 每行最少字符数
  /// 
  /// 返回处理后的文本（可能包含手动换行符 \n）
  static String balance(
    String text,
    double maxWidth,
    TextStyle style,
    int minCharsPerLine,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    
    // 1. 测量单行宽度
    textPainter.layout(maxWidth: double.infinity);
    final singleLineWidth = textPainter.width;
    
    // 2. 如果单行能放下，直接返回
    if (singleLineWidth <= maxWidth) {
      return text;
    }
    
    // 3. 计算需要几行
    textPainter.layout(maxWidth: maxWidth);
    final lineMetrics = textPainter.computeLineMetrics();
    
    // 4. 检查最后一行字符数
    if (lineMetrics.isNotEmpty) {
      final lastLineStart = _getLastLineStartIndex(text, textPainter);
      final lastLineChars = text.length - lastLineStart;
      
      // 5. 如果最后一行字符太少，重新分配
      if (lastLineChars < minCharsPerLine) {
        return _redistributeLines(text, maxWidth, style, minCharsPerLine);
      }
    }
    
    return text;
  }
  
  /// 重新分配行内容，确保每行至少有 minChars 个字符
  static String _redistributeLines(
    String text,
    double maxWidth,
    TextStyle style,
    int minChars,
  ) {
    final totalChars = text.length;
    
    // 计算理想的每行字符数
    // 目标：让每行字符数尽量均匀
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    final lineCount = textPainter.computeLineMetrics().length;
    
    if (lineCount <= 1) return text;
    
    // 计算每行理想字符数
    final idealCharsPerLine = (totalChars / lineCount).ceil();
    
    // 找到最佳换行点（在标点或空格处）
    final breakPoints = <int>[];
    int currentPos = 0;
    
    for (int i = 1; i < lineCount; i++) {
      int targetPos = currentPos + idealCharsPerLine;
      targetPos = targetPos.clamp(currentPos + minChars, totalChars - minChars);
      
      // 在目标位置附近找最佳换行点
      int bestBreak = _findBestBreakPoint(text, targetPos, minChars);
      breakPoints.add(bestBreak);
      currentPos = bestBreak;
    }
    
    // 插入换行符
    final buffer = StringBuffer();
    int lastBreak = 0;
    for (final bp in breakPoints) {
      buffer.write(text.substring(lastBreak, bp));
      buffer.write('\n');
      lastBreak = bp;
    }
    buffer.write(text.substring(lastBreak));
    
    return buffer.toString();
  }
  
  /// 在目标位置附近找最佳换行点
  /// 优先在标点符号后换行
  static int _findBestBreakPoint(String text, int target, int minChars) {
    const punctuation = '，。！？、；：""''）】》';
    
    // 在 target 附近 ±3 个字符范围内寻找标点
    for (int offset = 0; offset <= 3; offset++) {
      // 先检查 target + offset
      if (target + offset < text.length - minChars) {
        if (punctuation.contains(text[target + offset])) {
          return target + offset + 1;
        }
      }
      // 再检查 target - offset
      if (target - offset > minChars && offset > 0) {
        if (punctuation.contains(text[target - offset])) {
          return target - offset + 1;
        }
      }
    }
    
    // 没找到标点，直接在 target 处换行
    return target.clamp(minChars, text.length - minChars);
  }
}
```

## Data Models

### TextLayoutConfig

```dart
class TextLayoutConfig {
  final double minFontSize;
  final double maxFontSize;
  final double lineHeight;
  final double letterSpacing;
  final int minCharsPerLine;
  final bool allowScaling;
  
  const TextLayoutConfig({
    required this.minFontSize,
    required this.maxFontSize,
    required this.lineHeight,
    required this.letterSpacing,
    required this.minCharsPerLine,
    required this.allowScaling,
  });
  
  // 复古主题配置
  static const vintage = TextLayoutConfig(
    minFontSize: 14.0,
    maxFontSize: 20.0,
    lineHeight: 1.3,
    letterSpacing: 1.2,
    minCharsPerLine: 2,
    allowScaling: true,
  );
  
  // 治愈主题配置
  static const healing = TextLayoutConfig(
    minFontSize: 20.0,
    maxFontSize: 24.0,
    lineHeight: 1.5,
    letterSpacing: 0.5,
    minCharsPerLine: 4,
    allowScaling: false,
  );
}
```

### ResponsiveTextConfig

```dart
class ResponsiveTextConfig {
  final double screenWidth;
  
  ResponsiveTextConfig(this.screenWidth);
  
  double get fontSizeMultiplier {
    if (screenWidth < 360) return 0.85;  // 小屏幕缩小15%
    if (screenWidth > 400) return 1.0;
    return 1.0;
  }
  
  double get horizontalPadding {
    if (screenWidth > 400) return 32.0;  // 大屏幕增加padding
    return 24.0;  // 默认padding
  }
}
```

## Error Handling

### 文本测量失败

```dart
try {
  final textPainter = TextPainter(...)..layout(maxWidth: maxWidth);
  // 使用测量结果
} catch (e) {
  // 降级：直接返回原文本，让系统自动换行
  return text;
}
```

### 极端长文本

```dart
// 如果文本超过50个字符，强制截断并添加省略号
if (text.length > 50) {
  text = '${text.substring(0, 47)}...';
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following correctness properties have been identified:

### Property 1: No Orphan Characters

*For any* subtitle text string and any container width between 200-500px, when the text is rendered, no line in the output SHALL contain fewer than 2 characters.

**Validates: Requirements 1.1, 1.3**

### Property 2: Vintage Theme Font Size Bounds

*For any* subtitle text in Vintage theme, the rendered font size SHALL be between 14px (minimum) and 20px (maximum), and letter-spacing SHALL be between 1.0-1.5px.

**Validates: Requirements 2.2, 2.3**

### Property 3: Healing Theme Text Constraints

*For any* subtitle text in Healing theme that wraps to multiple lines, each line SHALL contain at least 4 characters, line-height SHALL be between 1.5-1.6, and font size SHALL be between 20-24px.

**Validates: Requirements 3.2, 3.3, 3.4**

### Property 4: Minimum Horizontal Padding

*For any* screen width, the horizontal padding from card edges to text content SHALL be at least 16px.

**Validates: Requirements 4.4**

### Property 5: Main Title No Truncation

*For any* main title text, the rendered output SHALL contain the complete original text without truncation or ellipsis, and minimum font size SHALL be 48px for Vintage and 56px for Healing.

**Validates: Requirements 5.2, 5.3, 5.4**

### Property 6: Balanced Line Distribution (Vintage)

*For any* Vintage theme subtitle that requires two lines, the character count difference between the two lines SHALL be no more than 4 characters.

**Validates: Requirements 2.5**

## Testing Strategy

### Property-Based Testing Framework

本项目使用 **flutter_test** 进行属性测试。每个属性测试将运行至少 100 次迭代，使用随机生成的中文文本字符串。

### Property-Based Tests

每个正确性属性将实现为独立的属性测试：

```dart
// **Feature: result-card-text-layout, Property 1: No Orphan Characters**
void testNoOrphanCharacters() {
  final random = Random();
  
  for (int i = 0; i < 100; i++) {
    // 生成随机中文文本 (5-30字符)
    final text = _generateRandomChineseText(5 + random.nextInt(25));
    final containerWidth = 200.0 + random.nextDouble() * 300; // 200-500px
    
    final result = TextBreakBalancer.balance(
      text,
      containerWidth,
      testStyle,
      2, // minCharsPerLine
    );
    
    // 验证每行至少2个字符
    final lines = result.split('\n');
    for (final line in lines) {
      expect(line.length, greaterThanOrEqualTo(2));
    }
  }
}
```

### Unit Tests

单元测试覆盖以下关键场景：

1. **换行算法测试**
   - 短文本（无需换行）
   - 中等文本（需要换行但无孤字风险）
   - 长文本（需要多行且有孤字风险）
   - 边界情况（恰好在标点处换行）

2. **主题差异测试**
   - Vintage主题使用FittedBox缩放
   - Healing主题使用固定字号+智能换行

3. **响应式测试**
   - 小屏幕（<360px）字号缩小
   - 大屏幕（>400px）padding增加

### Widget Tests

```dart
testWidgets('VintageSubTitleText renders without orphans', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: VintageSubTitleText(text: '这是一段测试文本，用于验证换行效果。'),
        ),
      ),
    ),
  );
  
  // 验证文本完整显示
  expect(find.text('这是一段测试文本，用于验证换行效果。'), findsOneWidget);
});
```

### Test File Structure

```
test/
├── features/
│   └── decision/
│       └── presentation/
│           └── widgets/
│               └── result_cards/
│                   ├── text_break_balancer_test.dart
│                   ├── vintage_subtitle_text_test.dart
│                   ├── healing_subtitle_text_test.dart
│                   └── text_layout_properties_test.dart
```

### Test Tagging Convention

所有属性测试必须使用以下格式标注：

```dart
// **Feature: result-card-text-layout, Property {number}: {property_text}**
```

