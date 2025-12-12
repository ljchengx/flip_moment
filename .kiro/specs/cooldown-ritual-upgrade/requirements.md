# Requirements Document

## Introduction

本规范定义了 Flip Moment 应用中冷却系统的仪式感升级方案。基于小红书视觉观感分析文档中关于"仪式感设计：延迟满足与过程美学"的深度研究，本次升级旨在将当前简单的倒计时指示器转变为一个具有情感价值、仪式感和决策重要性的沉浸式等待体验。

核心设计理念：
- **延迟满足的美学**：将等待时间转化为一种有意义的"充能"过程，而非单纯的限制
- **决策的神圣感**：通过视觉语言强调每一次决策的珍贵与重要性
- **情绪价值**：用温暖的动画和文案陪伴用户度过等待时间
- **皮肤适配**：每种主题皮肤都有独特的仪式感表达方式

当前问题：
- 现有冷却指示器只是一个简单的圆形进度条 + 数字倒计时
- 缺乏情感连接，用户感受到的是"被限制"而非"在准备"
- 没有体现决策的重要性和稀缺性
- 视觉设计过于技术化，缺乏氛围感

## Glossary

- **Cooldown_Ritual_Screen**: 冷却仪式全屏界面，在冷却期间显示的沉浸式等待体验
- **Energy_Orb**: 能量球，核心视觉元素，随时间充能并发光
- **Ritual_Progress**: 仪式进度，以非线性方式展示冷却进度的视觉组件
- **Wisdom_Quote**: 智慧语录，在等待期间显示的治愈系/哲理文案
- **Particle_Aura**: 粒子光环，围绕能量球的装饰性粒子效果
- **Breath_Animation**: 呼吸动画，模拟生命体呼吸的缓慢脉动效果
- **Countdown_Poetry**: 倒计时诗意化，将剩余时间转化为诗意表达
- **Decision_Counter**: 决策计数器，显示用户历史决策次数的组件
- **Ambient_Sound**: 环境音效，配合视觉的轻柔背景音
- **Unlock_Celebration**: 解锁庆祝，冷却结束时的庆祝动画

## Requirements

### Requirement 1

**User Story:** As a user, I want to see a beautiful full-screen ritual experience during cooldown, so that waiting feels like meaningful preparation rather than restriction.

#### Acceptance Criteria

1. WHEN cooldown is active THEN the system SHALL display a Cooldown_Ritual_Screen that covers the main decision area
2. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL render a central Energy_Orb as the focal point with diameter between 120-180 pixels
3. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL apply a soft gradient background matching the current skin theme
4. WHEN the user taps the screen during cooldown THEN the system SHALL display a gentle reminder message instead of blocking interaction
5. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL maintain smooth 60fps animation performance

### Requirement 2

**User Story:** As a user, I want to see the energy orb gradually fill and glow as time passes, so that I feel progress toward my next decision.

#### Acceptance Criteria

1. WHEN cooldown progresses THEN the Energy_Orb SHALL visually fill from 0% to 100% corresponding to elapsed time
2. WHEN the Energy_Orb fills THEN the system SHALL increase its glow intensity proportionally from 0.2 to 1.0 opacity
3. WHEN the Energy_Orb is below 50% filled THEN the system SHALL display a dim, dormant appearance
4. WHEN the Energy_Orb exceeds 80% filled THEN the system SHALL display pulsing glow effects indicating near-ready state
5. WHEN the Energy_Orb reaches 100% THEN the system SHALL trigger an Unlock_Celebration animation

### Requirement 3

**User Story:** As a user, I want to see floating particles around the energy orb, so that the waiting experience feels magical and alive.

#### Acceptance Criteria

1. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL render 8-15 floating particles around the Energy_Orb
2. WHEN particles animate THEN the system SHALL move them in gentle orbital or floating patterns
3. WHEN cooldown progresses THEN the system SHALL increase particle brightness and speed proportionally
4. WHEN the Energy_Orb reaches 100% THEN the system SHALL accelerate particles toward the center in a convergence effect
5. WHEN rendering particles THEN the system SHALL use colors from the current skin's accent palette

### Requirement 4

**User Story:** As a user, I want to see inspiring wisdom quotes during the wait, so that the time feels enriching rather than wasted.

#### Acceptance Criteria

1. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL show a Wisdom_Quote below the Energy_Orb
2. WHEN displaying Wisdom_Quote THEN the system SHALL rotate through a curated list of healing/philosophical quotes
3. WHEN the quote changes THEN the system SHALL apply a gentle fade transition over 500-800ms
4. WHEN displaying quotes THEN the system SHALL change to a new quote every 15-20 seconds
5. WHEN displaying Wisdom_Quote THEN the system SHALL use a handwritten or elegant serif font style

### Requirement 5

**User Story:** As a user, I want to see the remaining time displayed in a poetic way, so that the countdown feels less clinical and more meaningful.

#### Acceptance Criteria

1. WHEN displaying remaining time THEN the system SHALL show Countdown_Poetry instead of raw seconds
2. WHEN remaining time exceeds 45 seconds THEN the system SHALL display phrases like "静心片刻..." or "Gathering energy..."
3. WHEN remaining time is between 20-45 seconds THEN the system SHALL display phrases like "即将准备好..." or "Almost ready..."
4. WHEN remaining time is below 20 seconds THEN the system SHALL display the actual countdown with decorative styling
5. WHEN displaying countdown numbers THEN the system SHALL use large, elegant typography with subtle animation

### Requirement 6

**User Story:** As a user, I want to see my decision history count displayed during cooldown, so that I feel the weight and significance of each decision.

#### Acceptance Criteria

1. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL show a Decision_Counter in a subtle position
2. WHEN displaying Decision_Counter THEN the system SHALL format as "第 {n} 次决策" or "Decision #{n}"
3. WHEN displaying Decision_Counter THEN the system SHALL use a pill-shaped badge with semi-transparent background
4. WHEN the decision count increases THEN the system SHALL briefly highlight the counter with a sparkle effect
5. WHEN displaying Decision_Counter THEN the system SHALL position it at the top of the screen without obstructing the Energy_Orb

### Requirement 7

**User Story:** As a user, I want the cooldown experience to adapt to each skin theme, so that the ritual feels cohesive with my chosen aesthetic.

#### Acceptance Criteria

1. WHEN the current skin is Healing THEN the system SHALL render Energy_Orb with soft pink/peach glow and heart-shaped particles
2. WHEN the current skin is Vintage THEN the system SHALL render Energy_Orb with warm amber glow and star-shaped particles
3. WHEN the current skin is Cyber THEN the system SHALL render Energy_Orb with neon cyan/green glow and geometric particles
4. WHEN the current skin is Wish THEN the system SHALL render Energy_Orb with ethereal purple/blue glow and sparkle particles
5. WHEN switching skins THEN the system SHALL smoothly transition the ritual visuals within 300ms

### Requirement 8

**User Story:** As a user, I want to experience a celebration when cooldown ends, so that I feel excited and ready for my next decision.

#### Acceptance Criteria

1. WHEN cooldown reaches zero THEN the system SHALL trigger an Unlock_Celebration animation lasting 800-1200ms
2. WHEN Unlock_Celebration plays THEN the system SHALL expand the Energy_Orb briefly before fading
3. WHEN Unlock_Celebration plays THEN the system SHALL emit a burst of particles outward from the center
4. WHEN Unlock_Celebration plays THEN the system SHALL display a "Ready!" or "准备好了!" message
5. WHEN Unlock_Celebration completes THEN the system SHALL smoothly transition back to the decision interface

### Requirement 9

**User Story:** As a user, I want subtle haptic feedback during the ritual, so that the experience feels more tangible and connected.

#### Acceptance Criteria

1. WHEN the Energy_Orb pulses at 80%+ fill THEN the system SHALL trigger light haptic feedback
2. WHEN Unlock_Celebration plays THEN the system SHALL trigger medium haptic feedback
3. WHEN the user taps during cooldown THEN the system SHALL trigger selection haptic feedback
4. WHEN providing haptic feedback THEN the system SHALL respect the user's haptic settings preference
5. WHEN haptic feedback is disabled THEN the system SHALL skip all haptic triggers gracefully

### Requirement 10

**User Story:** As a user, I want the ritual screen to show a gentle breathing animation, so that the waiting experience feels calming and meditative.

#### Acceptance Criteria

1. WHEN the Cooldown_Ritual_Screen displays THEN the system SHALL apply Breath_Animation to the Energy_Orb
2. WHEN Breath_Animation plays THEN the system SHALL scale the orb between 0.95 and 1.05 over 3-4 second cycles
3. WHEN Breath_Animation plays THEN the system SHALL synchronize opacity changes with scale changes
4. WHEN cooldown is below 20 seconds THEN the system SHALL accelerate Breath_Animation to indicate urgency
5. WHEN Breath_Animation plays THEN the system SHALL use ease-in-out curves for smooth, natural motion

