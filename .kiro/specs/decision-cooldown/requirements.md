# Requirements Document

## Introduction

本功能为 Flip Moment 应用增加"决策冷却期"机制。每次用户完成一次决策（抛硬币/交互）后，系统将进入 60 秒的冷却状态，在此期间禁止再次触发决策操作。此设计旨在增强每次决策的仪式感和庄重性，让用户更加珍视每一次选择。冷却状态为全局共享，跨皮肤、跨页面生效。

## Glossary

- **Cooldown_System**: 决策冷却系统，负责管理和追踪冷却状态的核心模块
- **Cooldown_Period**: 冷却时长，固定为 60 秒
- **Decision_Action**: 决策操作，指用户触发抛硬币/交互并获得结果的完整流程
- **Interactive_Hero**: 各皮肤模式下的核心交互组件（硬币、麻糬、液态金属球等）
- **Cooldown_Indicator**: 冷却状态指示器，向用户展示剩余冷却时间的 UI 组件

## Requirements

### Requirement 1

**User Story:** As a user, I want the app to prevent rapid consecutive decisions, so that each decision feels more meaningful and ceremonial.

#### Acceptance Criteria

1. WHEN a user completes a Decision_Action THEN the Cooldown_System SHALL start a 60-second Cooldown_Period
2. WHILE the Cooldown_Period is active THEN the Cooldown_System SHALL block all new Decision_Action attempts
3. WHEN the Cooldown_Period expires THEN the Cooldown_System SHALL restore the ability to perform Decision_Action
4. IF a user attempts a Decision_Action during Cooldown_Period THEN the Cooldown_System SHALL display the remaining cooldown time

### Requirement 2

**User Story:** As a user, I want to see a clear visual indicator of the cooldown status, so that I know when I can make my next decision.

#### Acceptance Criteria

1. WHILE the Cooldown_Period is active THEN the Cooldown_Indicator SHALL display the remaining seconds in a countdown format
2. WHEN the Cooldown_Period is active THEN the Interactive_Hero SHALL display a visually disabled or dimmed state
3. WHEN the Cooldown_Period expires THEN the Cooldown_Indicator SHALL disappear and the Interactive_Hero SHALL restore to its normal interactive state
4. WHEN displaying the countdown THEN the Cooldown_Indicator SHALL update every second with smooth visual transitions

### Requirement 3

**User Story:** As a user, I want the cooldown state to persist across app restarts, so that I cannot bypass the cooldown by closing and reopening the app.

#### Acceptance Criteria

1. WHEN a Cooldown_Period starts THEN the Cooldown_System SHALL persist the cooldown end timestamp to local storage
2. WHEN the app launches THEN the Cooldown_System SHALL check for any active Cooldown_Period from persisted data
3. IF an active Cooldown_Period exists on app launch THEN the Cooldown_System SHALL resume the countdown from the remaining time
4. WHEN the Cooldown_Period expires THEN the Cooldown_System SHALL clear the persisted cooldown data

### Requirement 4

**User Story:** As a user, I want the cooldown to apply globally across all skins and screens, so that the ritual feeling is consistent throughout the app.

#### Acceptance Criteria

1. WHEN a Cooldown_Period is active THEN the Cooldown_System SHALL enforce the cooldown across all SkinMode variants (vintage, healing, cyber, wish)
2. WHEN navigating between screens during Cooldown_Period THEN the Cooldown_System SHALL maintain the cooldown state
3. WHEN switching skins during Cooldown_Period THEN the Cooldown_System SHALL preserve the remaining cooldown time
