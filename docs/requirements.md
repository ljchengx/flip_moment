# Requirements Document

## Introduction

本规范定义了 Flip Moment 应用中治愈主题（Healing Theme）结果卡片的重新设计方案。基于小红书视觉观感分析文档中关于"治愈系与软性生产力"美学支柱的深度研究，本次重设计旨在将结果卡片从当前的"手账风格"升级为更具"小红书审美"的治愈系设计，强调情绪价值、氛围感和社交货币属性。

核心设计理念：
- **去技术化**：摒弃冷冰冰的数据展示，用温暖的视觉语言包裹信息
- **拟人化情感**：让卡片本身具有"陪伴感"，而非单纯的结果展示
- **出片友好**：设计必须在小红书笔记配图中呈现出高颜值效果

## Glossary

- **Healing_Result_Card**: 治愈主题下显示决策结果的卡片组件
- **Morandi_Palette**: 莫兰迪色系，指低饱和度、高灰度的中间色调配色方案
- **Glassmorphism**: 毛玻璃效果，一种半透明模糊的视觉风格
- **Soft_Gradient**: 柔和渐变，指颜色过渡平滑、不刺眼的渐变效果
- **Washi_Tape**: 和纸胶带，手账装饰元素，用于增添手工感
- **Lucky_Pill**: 幸运药丸，展示幸运色的胶囊形状组件
- **Result_Sticker**: 结果贴纸，显示结果状态的装饰性标签
- **Share_Card**: 分享卡片，用于社交媒体分享的截图区域
- **Atmosphere_Score**: 氛围感评分，衡量设计情绪价值的指标

## Requirements

### Requirement 1

**User Story:** As a user, I want the healing result card to have a dreamy, soft visual atmosphere, so that I feel emotionally comforted when viewing my decision result.

#### Acceptance Criteria

1. WHEN the Healing_Result_Card displays THEN the system SHALL render a Soft_Gradient background using Morandi_Palette colors with opacity between 0.8 and 1.0
2. WHEN the result is positive (YES) THEN the system SHALL use warm gradient colors transitioning from peachy-cream (#FFF5EE) to soft-rose (#FFE4E1)
3. WHEN the result is negative (NO) THEN the system SHALL use cool gradient colors transitioning from mint-cream (#F0FFF0) to lavender-mist (#E6E6FA)
4. WHEN the card renders THEN the system SHALL apply a border-radius of 32 pixels or greater to achieve super-ellipse rounded corners
5. WHEN the card renders THEN the system SHALL display a subtle white inner glow border with 2-3 pixel spread to simulate jelly texture

### Requirement 2

**User Story:** As a user, I want the result card to feature cute decorative elements, so that the experience feels playful and healing rather than clinical.

#### Acceptance Criteria

1. WHEN the Healing_Result_Card displays THEN the system SHALL render a large semi-transparent watermark icon (heart for YES, cloud for NO) at 60-80% of card width
2. WHEN the card displays THEN the system SHALL position the watermark icon in the bottom-left corner with -30 to -50 pixel offset
3. WHEN the card displays THEN the system SHALL render a Washi_Tape style date label at the top with slight rotation (-3 to 3 degrees)
4. WHEN the card displays THEN the system SHALL show floating decorative particles (stars, hearts, or sparkles) with subtle animation
5. WHEN the card displays THEN the system SHALL render a dot-grid pattern background with 0.1-0.2 opacity as hand-journal texture

### Requirement 3

**User Story:** As a user, I want to see my decision result in a warm, friendly typography style, so that the message feels encouraging rather than judgmental.

#### Acceptance Criteria

1. WHEN displaying the main result title THEN the system SHALL use a rounded, playful Chinese font (ZCOOL KuaiLe or similar) at 56-72 pixels
2. WHEN displaying the main result title THEN the system SHALL use warm brown color (#5D4037) instead of pure black
3. WHEN displaying the subtitle message THEN the system SHALL use a handwritten-style font (Ma Shan Zheng or similar) at 20-28 pixels
4. WHEN displaying text THEN the system SHALL ensure line-height of 1.3-1.5 for comfortable reading
5. WHEN the result is positive THEN the system SHALL display encouraging phrases from a curated healing-style vocabulary

### Requirement 4

**User Story:** As a user, I want to see my user profile information integrated naturally into the result card, so that the card feels personalized to me.

#### Acceptance Criteria

1. WHEN the card displays THEN the system SHALL show the user's title/rank in a subtle, non-intrusive position
2. WHEN displaying user information THEN the system SHALL use a pill-shaped badge with soft accent color background
3. WHEN displaying decision count THEN the system SHALL format it as "×{count}" with a sparkle icon prefix
4. WHEN the user title is too long THEN the system SHALL truncate with ellipsis and limit to single line
5. WHEN displaying user info THEN the system SHALL use font size 11-13 pixels to maintain visual hierarchy

### Requirement 5

**User Story:** As a user, I want to see a lucky color recommendation displayed in a cute pill format, so that I have an additional fun element to share.

#### Acceptance Criteria

1. WHEN the card displays THEN the system SHALL render a Lucky_Pill component in the bottom-left area
2. WHEN rendering Lucky_Pill THEN the system SHALL display a circular color swatch (24-32 pixels) with the lucky color
3. WHEN rendering Lucky_Pill THEN the system SHALL display the color name in a friendly font (Fredoka or similar)
4. WHEN rendering Lucky_Pill THEN the system SHALL wrap the component in a white pill-shaped container with subtle shadow
5. WHEN rendering Lucky_Pill THEN the system SHALL include a small sparkle icon inside the color swatch

### Requirement 6

**User Story:** As a user, I want to see a playful result sticker that clearly indicates my decision outcome, so that the result is immediately recognizable.

#### Acceptance Criteria

1. WHEN the card displays THEN the system SHALL render a Result_Sticker in the bottom-right area
2. WHEN the result is positive THEN the system SHALL display sticker text such as "PERFECT!", "NICE!", or "GO FOR IT!"
3. WHEN the result is negative THEN the system SHALL display sticker text such as "CHILL~", "WAIT~", or "NEXT TIME~"
4. WHEN rendering Result_Sticker THEN the system SHALL apply 10-20 degree rotation for playful appearance
5. WHEN rendering Result_Sticker THEN the system SHALL use accent color background with thick white border (3-5 pixels)
6. WHEN rendering Result_Sticker THEN the system SHALL apply a colored drop shadow matching the accent color

### Requirement 7

**User Story:** As a user, I want the result card to have smooth, delightful animations, so that the reveal experience feels magical and healing.

#### Acceptance Criteria

1. WHEN the card appears THEN the system SHALL animate with scale-in effect from 0.9 to 1.0 over 500-700ms
2. WHEN the card appears THEN the system SHALL apply fade-in animation over 300-400ms
3. WHEN the card appears THEN the system SHALL trigger a subtle shimmer effect after initial animation completes
4. WHEN decorative particles display THEN the system SHALL animate them with gentle floating motion
5. WHEN the card is fully visible THEN the system SHALL apply elastic overshoot curve (Curves.elasticOut) for bouncy feel

### Requirement 8

**User Story:** As a user, I want the result card to be optimized for social media sharing, so that my screenshots look beautiful on Xiaohongshu.

#### Acceptance Criteria

1. WHEN capturing screenshot THEN the system SHALL render at 3x pixel ratio for high-definition output
2. WHEN the card renders THEN the system SHALL maintain aspect ratio suitable for social media (approximately 3:4 or 4:5)
3. WHEN the card renders THEN the system SHALL ensure all decorative elements are contained within card bounds
4. WHEN the card renders THEN the system SHALL include subtle app branding in a non-intrusive location
5. WHEN saving to gallery THEN the system SHALL provide haptic feedback and success toast notification
