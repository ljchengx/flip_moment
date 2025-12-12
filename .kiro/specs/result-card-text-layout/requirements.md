# Requirements Document

## Introduction

本规范定义了 Flip Moment 应用中结果卡片（Result Card）长文本内容的排版优化方案。当前问题是副标题（subTitle）文本在显示时经常出现"孤字"现象——即最后一个字被单独换行到下一行，破坏了视觉美感和阅读体验。

本次优化将针对复古主题（Vintage）和治愈主题（Healing）两种不同的设计风格，分别制定差异化的文本排版策略：
- **复古主题**：强调经典、庄重、杂志感，采用紧凑的单行或受控换行布局
- **治愈主题**：强调柔软、手账感、呼吸感，采用更宽松但避免孤字的布局

核心设计目标：
- **消除孤字**：确保文本换行时不会出现单个字符独占一行
- **主题差异化**：两种主题采用不同的排版策略以匹配各自的视觉风格
- **响应式适配**：在不同屏幕宽度下都能保持良好的排版效果

## Glossary

- **Orphan_Character**: 孤字，指在文本换行时单独出现在一行的单个字符
- **Vintage_Result_Card**: 复古主题结果卡片组件
- **Healing_Result_Card**: 治愈主题结果卡片组件
- **SubTitle_Text**: 副标题文本，显示在主标题下方的鼓励性文案
- **Text_Overflow_Strategy**: 文本溢出策略，处理文本超出容器时的显示方式
- **Line_Break_Control**: 换行控制，管理文本在何处换行的机制
- **FittedBox**: Flutter组件，用于缩放子组件以适应可用空间
- **AutoSizeText**: 自动调整字号的文本组件

## Requirements

### Requirement 1

**User Story:** As a user, I want the subtitle text to never show a single character on its own line, so that the result card looks professionally designed and visually balanced.

#### Acceptance Criteria

1. WHEN the SubTitle_Text renders in any Result_Card THEN the system SHALL ensure no line contains fewer than 2 characters
2. WHEN the SubTitle_Text would result in an Orphan_Character THEN the system SHALL apply Line_Break_Control to prevent the orphan
3. WHEN the text container width changes THEN the system SHALL recalculate line breaks to maintain the no-orphan rule
4. IF the SubTitle_Text is too long to fit without orphans THEN the system SHALL reduce font size proportionally rather than create orphans

### Requirement 2

**User Story:** As a user viewing the Vintage theme, I want the subtitle text to have a classic magazine-style layout, so that it matches the sophisticated vintage aesthetic.

#### Acceptance Criteria

1. WHEN the Vintage_Result_Card displays SubTitle_Text THEN the system SHALL render text in a single line when possible using FittedBox scaling
2. WHEN the Vintage_Result_Card SubTitle_Text exceeds container width THEN the system SHALL scale down font size to fit within bounds (minimum 14px)
3. WHEN the Vintage_Result_Card renders THEN the system SHALL center-align the SubTitle_Text with letter-spacing of 1.0-1.5px
4. WHEN the Vintage_Result_Card SubTitle_Text renders THEN the system SHALL use a semi-transparent background highlight (5% opacity black)
5. WHEN the Vintage_Result_Card SubTitle_Text cannot fit in single line at minimum font size THEN the system SHALL allow controlled two-line break with balanced character distribution

### Requirement 3

**User Story:** As a user viewing the Healing theme, I want the subtitle text to feel soft and hand-written, so that it maintains the cozy journal aesthetic.

#### Acceptance Criteria

1. WHEN the Healing_Result_Card displays SubTitle_Text THEN the system SHALL allow natural multi-line wrapping with soft line breaks
2. WHEN the Healing_Result_Card SubTitle_Text wraps to multiple lines THEN the system SHALL ensure each line has at least 4 characters
3. WHEN the Healing_Result_Card renders THEN the system SHALL use line-height of 1.5-1.6 for comfortable reading
4. WHEN the Healing_Result_Card SubTitle_Text renders THEN the system SHALL maintain font size between 20-24px without scaling
5. WHEN the Healing_Result_Card SubTitle_Text would create an orphan THEN the system SHALL insert a soft line break earlier to balance line lengths

### Requirement 4

**User Story:** As a user, I want the text layout to adapt smoothly to different screen sizes, so that the result card looks good on any device.

#### Acceptance Criteria

1. WHEN the screen width is less than 360px THEN the system SHALL reduce SubTitle_Text font size by 15-20%
2. WHEN the screen width is greater than 400px THEN the system SHALL increase horizontal padding to maintain optimal line length
3. WHEN the device orientation changes THEN the system SHALL recalculate text layout within 100ms
4. WHEN rendering on any screen size THEN the system SHALL maintain minimum 16px horizontal padding from card edges

### Requirement 5

**User Story:** As a user, I want the main title text to always display completely without truncation, so that I can clearly see my decision result.

#### Acceptance Criteria

1. WHEN the main title text renders THEN the system SHALL use FittedBox to scale text to fit container width
2. WHEN the main title text scales THEN the system SHALL maintain minimum font size of 48px for Vintage and 56px for Healing
3. WHEN the main title contains more than 4 characters THEN the system SHALL allow proportional scaling down
4. WHEN the main title renders THEN the system SHALL never truncate or use ellipsis

