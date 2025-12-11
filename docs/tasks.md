# Implementation Plan

- [x] 1. Create CooldownState data model and CooldownNotifier provider





  - [x] 1.1 Create `lib/core/providers/cooldown_provider.dart` with CooldownState class


    - Define CooldownState with isActive, remainingSeconds, endTime fields
    - Implement copyWith method for immutable updates
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 1.2 Implement CooldownNotifier with Riverpod annotation

    - Implement build() method to check persisted cooldown on init
    - Implement startCooldown() to activate 60-second cooldown
    - Implement _tick() for countdown logic
    - Implement canPerformDecision() helper method
    - _Requirements: 1.1, 1.2, 1.3, 3.2_
  - [x] 1.3 Write property test for cooldown activation






    - **Property 1: Cooldown activation sets correct initial state**
    - **Validates: Requirements 1.1**
  - [x] 1.4 Write property test for cooldown blocking






    - **Property 2: Cooldown blocks decisions while active**
    - **Validates: Requirements 1.2**

  - [x] 1.5 Write property test for cooldown allowing decisions





    - **Property 3: Cooldown allows decisions when inactive**
    - **Validates: Requirements 1.3, 2.3**

- [x] 2. Implement persistence logic for cooldown state





  - [x] 2.1 Add Hive persistence in CooldownNotifier


    - Persist endTime timestamp when cooldown starts
    - Read and restore cooldown state on app launch
    - Clear persisted data when cooldown expires
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - [x] 2.2 Write property test for persistence round-trip






    - **Property 5: Persistence round-trip consistency**
    - **Validates: Requirements 3.1, 3.2, 3.3**
  - [x] 2.3 Write property test for expiry cleanup






    - **Property 6: Cooldown expiry clears persisted data**
    - **Validates: Requirements 3.4**

- [x] 3. Checkpoint - Ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Create CooldownIndicator UI component








  - [x] 4.1 Create `lib/core/ui/cooldown_indicator.dart`

    - Build circular progress indicator with countdown text
    - Adapt styling to current skin theme
    - Implement smooth animation for countdown updates
    - _Requirements: 2.1, 2.4_
  - [x] 4.2 Write property test for remaining seconds calculation





    - **Property 4: Remaining seconds calculation is accurate**
    - **Validates: Requirements 1.4, 2.1**

- [x] 5. Integrate cooldown system into DecisionScreen





  - [x] 5.1 Update DecisionScreen to watch cooldown state


    - Add cooldownProvider watch in build method
    - Show CooldownIndicator when cooldown is active
    - _Requirements: 2.1, 2.3_

  - [x] 5.2 Update _handleDecisionEnd to trigger cooldown

    - Call startCooldown() after decision result is recorded
    - _Requirements: 1.1_

- [x] 6. Update Interactive Hero components to respect cooldown



  - [x] 6.1 Update CoinFlipper to check cooldown before flip


    - Check canPerformDecision() in _flip() method
    - Show disabled visual state during cooldown
    - _Requirements: 1.2, 2.2_
  - [x] 6.2 Update other skin interactive components


    - Apply same cooldown check pattern to MochiCharacter, LiquidMetalBall, WishPond
    - _Requirements: 4.1_
  - [x] 6.3 Write property test for skin independence
    - **Property 7: Cooldown state is skin-independent**
    - **Validates: Requirements 4.1, 4.3**

- [x] 7. Final Checkpoint - Ensure all tests pass
  - All 31 cooldown system tests pass successfully (100% pass rate)
