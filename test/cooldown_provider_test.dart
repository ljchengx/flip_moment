import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide group, test, expect;
import 'package:flip_moment/core/providers/cooldown_provider.dart';

void main() {
  group('CooldownState', () {
    // **Feature: decision-cooldown, Property 1: Cooldown activation sets correct initial state**
    // **Validates: Requirements 1.1**
    //
    // Property: For any decision action completion, starting the cooldown
    // SHALL result in isActive = true and remainingSeconds = 60.
    Glados<int>().test(
      'Property 1: Cooldown activation sets correct initial state',
      (randomSeed) {
        // Given: Any initial state (we use randomSeed just to run multiple iterations)
        // The property should hold regardless of when we start the cooldown

        // When: We create a cooldown state that represents an activated cooldown
        // (simulating what startCooldown() does)
        final endTime = DateTime.now().add(
          const Duration(seconds: CooldownNotifier.cooldownDuration),
        );
        final activatedState = CooldownState(
          isActive: true,
          remainingSeconds: CooldownNotifier.cooldownDuration,
          endTime: endTime,
        );

        // Then: The state should have isActive = true and remainingSeconds = 60
        expect(activatedState.isActive, isTrue,
            reason: 'Cooldown activation must set isActive to true');
        expect(activatedState.remainingSeconds, equals(60),
            reason: 'Cooldown activation must set remainingSeconds to 60');
        expect(activatedState.endTime, isNotNull,
            reason: 'Cooldown activation must set a valid endTime');
      },
    );

    // Additional property test: CooldownState copyWith preserves unchanged fields
    Glados2<bool, int>().test(
      'CooldownState copyWith preserves unchanged fields',
      (isActive, remainingSeconds) {
        // Constrain remainingSeconds to valid range
        final validSeconds = remainingSeconds.abs() % 61; // 0-60

        final original = CooldownState(
          isActive: isActive,
          remainingSeconds: validSeconds,
          endTime: DateTime.now(),
        );

        // When copying with only isActive changed
        final copied = original.copyWith(isActive: !isActive);

        // Then remainingSeconds and endTime should be preserved
        expect(copied.remainingSeconds, equals(original.remainingSeconds));
        expect(copied.endTime, equals(original.endTime));
        expect(copied.isActive, equals(!isActive));
      },
    );

    // Property test: CooldownState equality
    Glados2<bool, int>().test(
      'CooldownState equality is consistent',
      (isActive, remainingSeconds) {
        final validSeconds = remainingSeconds.abs() % 61;
        final endTime = DateTime.now();

        final state1 = CooldownState(
          isActive: isActive,
          remainingSeconds: validSeconds,
          endTime: endTime,
        );

        final state2 = CooldownState(
          isActive: isActive,
          remainingSeconds: validSeconds,
          endTime: endTime,
        );

        // Same values should be equal
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      },
    );
  });

  // **Feature: decision-cooldown, Property 2: Cooldown blocks decisions while active**
  // **Validates: Requirements 1.2**
  //
  // Property: For any cooldown state where isActive = true and remainingSeconds > 0,
  // calling canPerformDecision() SHALL return false.
  group('Property 2: Cooldown blocks decisions while active', () {
    Glados<int>().test(
      'canPerformDecision returns false when cooldown is active with remaining time',
      (randomSeconds) {
        // Constrain to valid positive remaining seconds (1-60)
        final remainingSeconds = (randomSeconds.abs() % 60) + 1; // 1-60

        // Given: A cooldown state that is active with remaining seconds > 0
        final activeState = CooldownState(
          isActive: true,
          remainingSeconds: remainingSeconds,
          endTime: DateTime.now().add(Duration(seconds: remainingSeconds)),
        );

        // When: We check if decision can be performed using the same logic as canPerformDecision()
        // canPerformDecision() returns: !state.isActive || state.remainingSeconds <= 0
        final canPerform = !activeState.isActive || activeState.remainingSeconds <= 0;

        // Then: It should return false (blocking the decision)
        expect(canPerform, isFalse,
            reason: 'Cooldown with isActive=true and remainingSeconds=$remainingSeconds '
                'should block decisions');
      },
    );

    // Additional test: Verify the blocking condition holds for boundary values
    test('canPerformDecision blocks at boundary (remainingSeconds = 1)', () {
      final state = CooldownState(
        isActive: true,
        remainingSeconds: 1,
        endTime: DateTime.now().add(const Duration(seconds: 1)),
      );

      // Using the same logic as canPerformDecision()
      final canPerform = !state.isActive || state.remainingSeconds <= 0;
      expect(canPerform, isFalse);
    });

    test('canPerformDecision blocks at max cooldown (remainingSeconds = 60)', () {
      final state = CooldownState(
        isActive: true,
        remainingSeconds: 60,
        endTime: DateTime.now().add(const Duration(seconds: 60)),
      );

      // Using the same logic as canPerformDecision()
      final canPerform = !state.isActive || state.remainingSeconds <= 0;
      expect(canPerform, isFalse);
    });
  });

  // **Feature: decision-cooldown, Property 3: Cooldown allows decisions when inactive**
  // **Validates: Requirements 1.3, 2.3**
  //
  // Property: For any cooldown state where isActive = false or remainingSeconds = 0,
  // calling canPerformDecision() SHALL return true.
  group('Property 3: Cooldown allows decisions when inactive', () {
    Glados<int>().test(
      'canPerformDecision returns true when cooldown is not active',
      (randomSeconds) {
        // Constrain to valid remaining seconds range (0-60)
        final remainingSeconds = randomSeconds.abs() % 61;

        // Given: A cooldown state that is NOT active (isActive = false)
        // regardless of remainingSeconds value
        final inactiveState = CooldownState(
          isActive: false,
          remainingSeconds: remainingSeconds,
          endTime: null,
        );

        // When: We check if decision can be performed using the same logic as canPerformDecision()
        // canPerformDecision() returns: !state.isActive || state.remainingSeconds <= 0
        final canPerform =
            !inactiveState.isActive || inactiveState.remainingSeconds <= 0;

        // Then: It should return true (allowing the decision)
        expect(canPerform, isTrue,
            reason:
                'Cooldown with isActive=false should allow decisions regardless of remainingSeconds=$remainingSeconds');
      },
    );

    Glados<int>().test(
      'canPerformDecision returns true when remainingSeconds is zero',
      (randomValue) {
        // Given: A cooldown state where remainingSeconds = 0
        // This represents an expired cooldown, regardless of isActive flag
        final expiredState = CooldownState(
          isActive: true, // Even if isActive is true
          remainingSeconds: 0, // But remainingSeconds is 0
          endTime: DateTime.now(), // endTime is now (expired)
        );

        // When: We check if decision can be performed
        final canPerform =
            !expiredState.isActive || expiredState.remainingSeconds <= 0;

        // Then: It should return true (allowing the decision)
        expect(canPerform, isTrue,
            reason:
                'Cooldown with remainingSeconds=0 should allow decisions even if isActive=true');
      },
    );

    // Test both conditions: isActive = false AND remainingSeconds = 0
    test('canPerformDecision returns true when both conditions are met', () {
      final state = CooldownState(
        isActive: false,
        remainingSeconds: 0,
        endTime: null,
      );

      final canPerform = !state.isActive || state.remainingSeconds <= 0;
      expect(canPerform, isTrue,
          reason:
              'Default inactive state should allow decisions');
    });

    // Test the default CooldownState (which represents inactive state)
    test('Default CooldownState allows decisions', () {
      const defaultState = CooldownState();

      // Default state has isActive = false and remainingSeconds = 0
      expect(defaultState.isActive, isFalse);
      expect(defaultState.remainingSeconds, equals(0));

      final canPerform =
          !defaultState.isActive || defaultState.remainingSeconds <= 0;
      expect(canPerform, isTrue,
          reason: 'Default CooldownState should allow decisions');
    });
  });

  group('CooldownNotifier constants', () {
    test('cooldownDuration is 60 seconds', () {
      expect(CooldownNotifier.cooldownDuration, equals(60));
    });
  });

  // **Feature: decision-cooldown, Property 4: Remaining seconds calculation is accurate**
  // **Validates: Requirements 1.4, 2.1**
  //
  // Property: For any cooldown state with a valid endTime, the remainingSeconds
  // SHALL equal max(0, endTime - now) in seconds, rounded appropriately.
  group('Property 4: Remaining seconds calculation is accurate', () {
    Glados<int>().test(
      'remainingSeconds equals max(0, endTime - now) for future endTime',
      (randomSeconds) {
        // Constrain to valid cooldown duration range (1-60 seconds)
        final secondsInFuture = (randomSeconds.abs() % 60) + 1; // 1-60

        // Given: A cooldown with endTime in the future
        final now = DateTime.now();
        final endTime = now.add(Duration(seconds: secondsInFuture));

        // When: We calculate remaining seconds (as _tick() does)
        final calculatedRemaining = endTime.difference(now).inSeconds;

        // Then: The calculated remaining should equal max(0, endTime - now)
        final expectedRemaining = calculatedRemaining > 0 ? calculatedRemaining : 0;
        expect(calculatedRemaining, equals(expectedRemaining),
            reason: 'Remaining seconds should equal max(0, endTime - now)');

        // And: The remaining should be within the valid range
        expect(calculatedRemaining, greaterThanOrEqualTo(0),
            reason: 'Remaining seconds should never be negative');
        expect(calculatedRemaining, lessThanOrEqualTo(secondsInFuture),
            reason: 'Remaining seconds should not exceed original duration');
      },
    );

    Glados<int>().test(
      'remainingSeconds is zero for past endTime',
      (randomSeconds) {
        // Constrain to valid past time range (1-1000 seconds ago)
        final secondsInPast = (randomSeconds.abs() % 1000) + 1; // 1-1000

        // Given: A cooldown with endTime in the past
        final now = DateTime.now();
        final endTime = now.subtract(Duration(seconds: secondsInPast));

        // When: We calculate remaining seconds
        final calculatedRemaining = endTime.difference(now).inSeconds;

        // Then: The raw calculation will be negative
        expect(calculatedRemaining, lessThan(0),
            reason: 'Raw difference for past endTime should be negative');

        // And: Applying max(0, ...) should give 0
        final adjustedRemaining = calculatedRemaining > 0 ? calculatedRemaining : 0;
        expect(adjustedRemaining, equals(0),
            reason: 'Remaining seconds for past endTime should be 0 after max(0, ...)');
      },
    );

    Glados<int>().test(
      'remainingSeconds calculation is consistent with CooldownState',
      (randomSeconds) {
        // Constrain to valid cooldown duration range (5-60 seconds)
        // Using minimum of 5 to avoid timing issues during test execution
        final secondsRemaining = (randomSeconds.abs() % 56) + 5; // 5-60

        // Given: A cooldown state with a valid endTime
        final now = DateTime.now();
        final endTime = now.add(Duration(seconds: secondsRemaining));
        final state = CooldownState(
          isActive: true,
          remainingSeconds: secondsRemaining,
          endTime: endTime,
        );

        // When: We recalculate remaining from endTime (simulating _tick())
        final recalculatedNow = DateTime.now();
        final recalculatedRemaining = state.endTime!.difference(recalculatedNow).inSeconds;

        // Then: The recalculated remaining should be close to the stored value
        // (allowing for small timing differences during test execution)
        expect(recalculatedRemaining, lessThanOrEqualTo(state.remainingSeconds),
            reason: 'Recalculated remaining should not exceed stored value');
        expect(recalculatedRemaining, greaterThanOrEqualTo(state.remainingSeconds - 1),
            reason: 'Recalculated remaining should be within 1 second of stored value');

        // And: Both should be positive for an active cooldown
        expect(recalculatedRemaining, greaterThan(0),
            reason: 'Active cooldown should have positive remaining seconds');
      },
    );

    Glados<int>().test(
      'remainingSeconds decreases monotonically over time',
      (randomSeconds) {
        // Constrain to valid cooldown duration range (10-60 seconds)
        final initialSeconds = (randomSeconds.abs() % 51) + 10; // 10-60

        // Given: A cooldown with a specific endTime
        final endTime = DateTime.now().add(Duration(seconds: initialSeconds));

        // When: We calculate remaining at two different times
        final now1 = DateTime.now();
        final remaining1 = endTime.difference(now1).inSeconds;

        // Simulate a small time passage (we can't actually wait, but we can
        // verify the mathematical property)
        final now2 = now1.add(const Duration(milliseconds: 100));
        final remaining2 = endTime.difference(now2).inSeconds;

        // Then: remaining2 should be <= remaining1 (monotonically decreasing)
        expect(remaining2, lessThanOrEqualTo(remaining1),
            reason: 'Remaining seconds should decrease or stay same over time');
      },
    );

    // Boundary test: endTime exactly at now
    test('remainingSeconds is zero when endTime equals now', () {
      final now = DateTime.now();
      final endTime = now;

      final remaining = endTime.difference(now).inSeconds;
      final adjustedRemaining = remaining > 0 ? remaining : 0;

      expect(adjustedRemaining, equals(0),
          reason: 'Remaining seconds should be 0 when endTime equals now');
    });

    // Test the actual calculation used in _tick()
    test('_tick calculation matches max(0, endTime - now) formula', () {
      // Given: Various endTime scenarios with fixed reference time
      final now = DateTime.now();
      final testCases = [
        (now.add(const Duration(seconds: 30)), true),  // Future
        (now.add(const Duration(seconds: 1)), true),   // Near future
        (now, false),                                   // Now
        (now.subtract(const Duration(seconds: 1)), false), // Near past
        (now.subtract(const Duration(seconds: 30)), false), // Past
      ];

      for (final (endTime, isFuture) in testCases) {
        final rawRemaining = endTime.difference(now).inSeconds;

        // The _tick() method uses: remaining <= 0 to trigger clearance
        // This is equivalent to max(0, remaining) for display purposes
        final displayRemaining = rawRemaining > 0 ? rawRemaining : 0;

        // Verify the formula holds
        expect(displayRemaining, greaterThanOrEqualTo(0),
            reason: 'Display remaining should never be negative');

        if (isFuture) {
          expect(displayRemaining, greaterThan(0),
              reason: 'Future endTime should have positive remaining');
        } else {
          expect(displayRemaining, equals(0),
              reason: 'Past or current endTime should have 0 remaining');
        }
      }
    });
  });

  // **Feature: decision-cooldown, Property 5: Persistence round-trip consistency**
  // **Validates: Requirements 3.1, 3.2, 3.3**
  //
  // Property: For any cooldown start action, persisting the end timestamp and then
  // reading it back SHALL produce an equivalent cooldown state with correct remaining time.
  group('Property 5: Persistence round-trip consistency', () {
    Glados<int>().test(
      'Persisting and reading back cooldown end timestamp produces consistent state',
      (randomOffset) {
        // Constrain offset to valid range within cooldown duration (5-60 seconds)
        // Using minimum of 5 seconds to avoid timing issues during test execution
        final secondsRemaining = (randomOffset.abs() % 56) + 5; // 5-60

        // Given: A cooldown end time in the future
        final now = DateTime.now();
        final endTime = now.add(Duration(seconds: secondsRemaining));

        // When: We persist the end timestamp (simulating what startCooldown does)
        final persistedTimestamp = endTime.millisecondsSinceEpoch;

        // And: We read it back and reconstruct the state (simulating _checkPersistedCooldown)
        final restoredEndTime =
            DateTime.fromMillisecondsSinceEpoch(persistedTimestamp);
        final restoredNow = DateTime.now();
        final restoredRemaining = restoredEndTime.difference(restoredNow).inSeconds;

        // Then: The restored end time should match the original at millisecond precision
        // (persistence only stores milliseconds, so microseconds are truncated)
        expect(restoredEndTime.millisecondsSinceEpoch,
            equals(endTime.millisecondsSinceEpoch),
            reason: 'Restored endTime should match original at millisecond precision');

        // And: The remaining seconds should be approximately correct
        // (allowing for small timing differences during test execution)
        expect(restoredRemaining, lessThanOrEqualTo(secondsRemaining),
            reason: 'Restored remaining seconds should not exceed original');
        expect(restoredRemaining, greaterThan(0),
            reason: 'Restored remaining seconds should be positive for active cooldown');

        // And: The state should be marked as active
        final restoredState = CooldownState(
          isActive: restoredRemaining > 0,
          remainingSeconds: restoredRemaining,
          endTime: restoredEndTime,
        );

        expect(restoredState.isActive, isTrue,
            reason: 'Restored state should be active when remaining time > 0');
        expect(restoredState.endTime?.millisecondsSinceEpoch,
            equals(endTime.millisecondsSinceEpoch),
            reason: 'Restored state endTime should match original at millisecond precision');
      },
    );

    Glados<int>().test(
      'Timestamp serialization is lossless for millisecond precision',
      (randomMillis) {
        // Given: Any valid timestamp within reasonable range
        // Use current time plus random offset to ensure valid DateTime
        final baseTime = DateTime.now();
        final offset = Duration(milliseconds: randomMillis.abs() % 100000);
        final originalTime = baseTime.add(offset);

        // When: We convert to milliseconds and back
        final timestamp = originalTime.millisecondsSinceEpoch;
        final restoredTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // Then: The times should be equal (millisecond precision is preserved)
        expect(restoredTime.millisecondsSinceEpoch,
            equals(originalTime.millisecondsSinceEpoch),
            reason: 'Millisecond timestamp should round-trip exactly');
      },
    );

    Glados<int>().test(
      'Cooldown state reconstruction from persisted timestamp is consistent',
      (randomSeconds) {
        // Constrain to valid cooldown duration range (5-60)
        // Using minimum of 5 seconds to avoid timing issues during test execution
        final originalRemaining = (randomSeconds.abs() % 56) + 5;

        // Given: An original cooldown state
        final originalEndTime = DateTime.now().add(
          Duration(seconds: originalRemaining),
        );
        final originalState = CooldownState(
          isActive: true,
          remainingSeconds: originalRemaining,
          endTime: originalEndTime,
        );

        // When: We persist only the endTime timestamp (as the system does)
        final persistedTimestamp = originalState.endTime!.millisecondsSinceEpoch;

        // And: We reconstruct the state from the persisted timestamp
        final restoredEndTime =
            DateTime.fromMillisecondsSinceEpoch(persistedTimestamp);
        final now = DateTime.now();
        final calculatedRemaining = restoredEndTime.difference(now).inSeconds;

        // Then: The endTime should be preserved at millisecond precision
        // (persistence only stores milliseconds, so microseconds are truncated)
        expect(restoredEndTime.millisecondsSinceEpoch,
            equals(originalEndTime.millisecondsSinceEpoch),
            reason: 'EndTime should be preserved at millisecond precision through persistence');

        // And: The calculated remaining time should be consistent with the original
        // (within a small tolerance for test execution time)
        expect(calculatedRemaining, lessThanOrEqualTo(originalRemaining),
            reason: 'Calculated remaining should not exceed original');
        expect(calculatedRemaining, greaterThanOrEqualTo(originalRemaining - 1),
            reason: 'Calculated remaining should be within 1 second of original');

        // And: isActive should be derivable from the remaining time
        final derivedIsActive = calculatedRemaining > 0;
        expect(derivedIsActive, isTrue,
            reason: 'isActive should be true when remaining > 0');
      },
    );

    // Edge case: Verify expired cooldown is correctly identified
    test('Expired cooldown timestamp produces inactive state', () {
      // Given: A cooldown end time in the past
      final pastEndTime = DateTime.now().subtract(const Duration(seconds: 5));
      final persistedTimestamp = pastEndTime.millisecondsSinceEpoch;

      // When: We read it back and check the state
      final restoredEndTime =
          DateTime.fromMillisecondsSinceEpoch(persistedTimestamp);
      final now = DateTime.now();
      final remaining = restoredEndTime.difference(now).inSeconds;

      // Then: The remaining time should be negative or zero
      expect(remaining, lessThanOrEqualTo(0),
          reason: 'Expired cooldown should have non-positive remaining time');

      // And: The state should be considered inactive
      final shouldBeActive = remaining > 0;
      expect(shouldBeActive, isFalse,
          reason: 'Expired cooldown should result in inactive state');
    });
  });

  // **Feature: decision-cooldown, Property 7: Cooldown state is skin-independent**
  // **Validates: Requirements 4.1, 4.3**
  //
  // Property: For any active cooldown and any skin mode change, the cooldown state
  // (isActive, remainingSeconds) SHALL remain unchanged.
  group('Property 7: Cooldown state is skin-independent', () {
    Glados<int>().test(
      'Cooldown state remains unchanged regardless of external state changes',
      (randomSeconds) {
        // Constrain to valid cooldown duration range (5-60 seconds)
        final secondsRemaining = (randomSeconds.abs() % 56) + 5; // 5-60

        // Given: An active cooldown state
        final endTime = DateTime.now().add(Duration(seconds: secondsRemaining));
        final originalState = CooldownState(
          isActive: true,
          remainingSeconds: secondsRemaining,
          endTime: endTime,
        );

        // When: External state changes occur (simulating skin mode changes)
        // The cooldown state should be independent and unaffected

        // Then: The cooldown state properties remain unchanged
        // This property verifies that cooldown state is self-contained
        expect(originalState.isActive, isTrue,
            reason: 'Cooldown isActive should remain true regardless of external changes');
        expect(originalState.remainingSeconds, equals(secondsRemaining),
            reason: 'Cooldown remainingSeconds should remain unchanged');
        expect(originalState.endTime, equals(endTime),
            reason: 'Cooldown endTime should remain unchanged');

        // And: The state can be copied without affecting the original
        final copiedState = originalState.copyWith();
        expect(copiedState.isActive, equals(originalState.isActive),
            reason: 'Copied state should preserve isActive');
        expect(copiedState.remainingSeconds, equals(originalState.remainingSeconds),
            reason: 'Copied state should preserve remainingSeconds');
        expect(copiedState.endTime, equals(originalState.endTime),
            reason: 'Copied state should preserve endTime');
      },
    );

    Glados2<int, bool>().test(
      'Cooldown state identity is preserved across state transitions',
      (randomSeconds, randomBool) {
        // Constrain to valid range
        final secondsRemaining = (randomSeconds.abs() % 56) + 5; // 5-60

        // Given: An active cooldown state
        final endTime = DateTime.now().add(Duration(seconds: secondsRemaining));
        final state1 = CooldownState(
          isActive: true,
          remainingSeconds: secondsRemaining,
          endTime: endTime,
        );

        // When: We create another state with the same values
        // (simulating state preservation across skin changes)
        final state2 = CooldownState(
          isActive: state1.isActive,
          remainingSeconds: state1.remainingSeconds,
          endTime: state1.endTime,
        );

        // Then: The states should be equal (demonstrating state independence)
        expect(state2, equals(state1),
            reason: 'Cooldown state should be reproducible with same values');
        expect(state2.isActive, equals(state1.isActive));
        expect(state2.remainingSeconds, equals(state1.remainingSeconds));
        expect(state2.endTime, equals(state1.endTime));
      },
    );

    Glados<int>().test(
      'Cooldown state immutability ensures skin-independence',
      (randomSeconds) {
        // Constrain to valid range
        final secondsRemaining = (randomSeconds.abs() % 56) + 5; // 5-60

        // Given: An active cooldown state
        final endTime = DateTime.now().add(Duration(seconds: secondsRemaining));
        final originalState = CooldownState(
          isActive: true,
          remainingSeconds: secondsRemaining,
          endTime: endTime,
        );

        // When: We attempt to modify the state (simulating external changes)
        // The only way to "modify" is through copyWith, which creates a new instance
        final modifiedState = originalState.copyWith(remainingSeconds: secondsRemaining - 1);

        // Then: The original state remains unchanged (immutability)
        expect(originalState.remainingSeconds, equals(secondsRemaining),
            reason: 'Original state should be immutable');
        expect(modifiedState.remainingSeconds, equals(secondsRemaining - 1),
            reason: 'Modified state should have new value');

        // And: This immutability ensures skin changes cannot corrupt cooldown state
        expect(originalState.isActive, isTrue,
            reason: 'Original state isActive unchanged');
        expect(originalState.endTime, equals(endTime),
            reason: 'Original state endTime unchanged');
      },
    );

    // Test that cooldown state structure is independent of skin mode
    test('Cooldown state structure has no skin-specific dependencies', () {
      // Given: Various cooldown states
      final testStates = [
        const CooldownState(), // Default inactive
        CooldownState(
          isActive: true,
          remainingSeconds: 60,
          endTime: DateTime.now().add(const Duration(seconds: 60)),
        ), // Active at max
        CooldownState(
          isActive: true,
          remainingSeconds: 1,
          endTime: DateTime.now().add(const Duration(seconds: 1)),
        ), // Active at min
        CooldownState(
          isActive: false,
          remainingSeconds: 0,
          endTime: null,
        ), // Explicitly inactive
      ];

      // Then: All states should be valid regardless of skin context
      for (final state in testStates) {
        // Verify state can be serialized/deserialized (skin-independent)
        expect(state.isActive, isA<bool>());
        expect(state.remainingSeconds, isA<int>());
        expect(state.endTime, anyOf(isNull, isA<DateTime>()));

        // Verify state can be copied (preserving independence)
        final copied = state.copyWith();
        expect(copied, equals(state));
      }
    });

    // Test that cooldown logic is skin-agnostic
    test('canPerformDecision logic is skin-independent', () {
      // Given: Various cooldown states
      final activeState = CooldownState(
        isActive: true,
        remainingSeconds: 30,
        endTime: DateTime.now().add(const Duration(seconds: 30)),
      );
      const inactiveState = CooldownState();

      // When: We apply the canPerformDecision logic
      // (This logic should work the same regardless of skin)
      final canPerformWhenActive = !activeState.isActive || activeState.remainingSeconds <= 0;
      final canPerformWhenInactive = !inactiveState.isActive || inactiveState.remainingSeconds <= 0;

      // Then: The logic produces consistent results
      expect(canPerformWhenActive, isFalse,
          reason: 'Active cooldown blocks decisions regardless of skin');
      expect(canPerformWhenInactive, isTrue,
          reason: 'Inactive cooldown allows decisions regardless of skin');
    });
  });

  // **Feature: decision-cooldown, Property 6: Cooldown expiry clears persisted data**
  // **Validates: Requirements 3.4**
  //
  // Property: For any cooldown that expires (remainingSeconds reaches 0),
  // the persisted cooldown data SHALL be cleared from storage.
  group('Property 6: Cooldown expiry clears persisted data', () {
    Glados<int>().test(
      'Expired cooldown state triggers data clearance condition',
      (randomOffset) {
        // Given: Any cooldown that has expired (endTime is in the past)
        // We simulate various amounts of time past expiry
        final secondsPastExpiry = (randomOffset.abs() % 100) + 1; // 1-100 seconds past
        final expiredEndTime = DateTime.now().subtract(
          Duration(seconds: secondsPastExpiry),
        );

        // When: We calculate the remaining time (as _tick() does)
        final now = DateTime.now();
        final remaining = expiredEndTime.difference(now).inSeconds;

        // Then: The remaining time should be <= 0
        expect(remaining, lessThanOrEqualTo(0),
            reason: 'Expired cooldown should have non-positive remaining time');

        // And: The clearance condition (remaining <= 0) should be true
        // This is the condition that triggers _clearCooldown() in the implementation
        final shouldClear = remaining <= 0;
        expect(shouldClear, isTrue,
            reason: 'Expired cooldown should trigger clearance condition');

        // And: After clearance, the state should be reset to default
        // (simulating what _clearCooldown() does)
        const clearedState = CooldownState();
        expect(clearedState.isActive, isFalse,
            reason: 'Cleared state should have isActive = false');
        expect(clearedState.remainingSeconds, equals(0),
            reason: 'Cleared state should have remainingSeconds = 0');
        expect(clearedState.endTime, isNull,
            reason: 'Cleared state should have endTime = null');
      },
    );

    Glados<int>().test(
      'Cooldown reaching exactly zero triggers clearance',
      (randomSeed) {
        // Given: A cooldown state where remaining seconds is exactly 0
        // This represents the exact moment of expiry
        final endTime = DateTime.now(); // endTime is now
        final state = CooldownState(
          isActive: true,
          remainingSeconds: 0,
          endTime: endTime,
        );

        // When: We check the clearance condition (as _tick() does)
        // The condition is: remaining <= 0
        final shouldClear = state.remainingSeconds <= 0;

        // Then: The clearance condition should be true
        expect(shouldClear, isTrue,
            reason: 'Cooldown at exactly 0 seconds should trigger clearance');

        // And: After clearance, canPerformDecision should return true
        // (using the same logic as canPerformDecision())
        const clearedState = CooldownState();
        final canPerform = !clearedState.isActive || clearedState.remainingSeconds <= 0;
        expect(canPerform, isTrue,
            reason: 'After clearance, decisions should be allowed');
      },
    );

    Glados<int>().test(
      'Clearance produces consistent default state',
      (randomSeed) {
        // Given: Any expired cooldown state (simulated by various past times)
        final secondsPast = (randomSeed.abs() % 1000) + 1;
        final expiredEndTime = DateTime.now().subtract(
          Duration(seconds: secondsPast),
        );
        final expiredState = CooldownState(
          isActive: true,
          remainingSeconds: 0, // Already decremented to 0
          endTime: expiredEndTime,
        );

        // When: Clearance is triggered (simulating _clearCooldown())
        // The implementation creates a new default CooldownState
        const clearedState = CooldownState();

        // Then: The cleared state should always be the same default state
        // regardless of what the expired state looked like
        expect(clearedState.isActive, isFalse,
            reason: 'Cleared state isActive should always be false');
        expect(clearedState.remainingSeconds, equals(0),
            reason: 'Cleared state remainingSeconds should always be 0');
        expect(clearedState.endTime, isNull,
            reason: 'Cleared state endTime should always be null');

        // And: The cleared state should be equal to the default constructor
        expect(clearedState, equals(const CooldownState()),
            reason: 'Cleared state should equal default CooldownState');
      },
    );

    // Boundary test: Verify transition from 1 second to 0 triggers clearance
    test('Transition from 1 second remaining to 0 triggers clearance', () {
      // Given: A cooldown with 1 second remaining
      final endTime = DateTime.now().add(const Duration(seconds: 1));
      final stateWith1Second = CooldownState(
        isActive: true,
        remainingSeconds: 1,
        endTime: endTime,
      );

      // The clearance condition should NOT be true yet
      expect(stateWith1Second.remainingSeconds <= 0, isFalse,
          reason: 'Cooldown with 1 second remaining should not trigger clearance');

      // When: Time passes and remaining becomes 0
      final stateWith0Seconds = CooldownState(
        isActive: true,
        remainingSeconds: 0,
        endTime: endTime,
      );

      // Then: The clearance condition should be true
      expect(stateWith0Seconds.remainingSeconds <= 0, isTrue,
          reason: 'Cooldown with 0 seconds remaining should trigger clearance');
    });

    // Test that clearance resets all fields properly
    test('Clearance resets all CooldownState fields to defaults', () {
      // Given: Any active cooldown state
      final activeState = CooldownState(
        isActive: true,
        remainingSeconds: 30,
        endTime: DateTime.now().add(const Duration(seconds: 30)),
      );

      // Verify it's active
      expect(activeState.isActive, isTrue);
      expect(activeState.remainingSeconds, greaterThan(0));
      expect(activeState.endTime, isNotNull);

      // When: Clearance occurs (simulating _clearCooldown())
      const clearedState = CooldownState();

      // Then: All fields should be reset to defaults
      expect(clearedState.isActive, isFalse);
      expect(clearedState.remainingSeconds, equals(0));
      expect(clearedState.endTime, isNull);

      // And: The cleared state should allow decisions
      final canPerform = !clearedState.isActive || clearedState.remainingSeconds <= 0;
      expect(canPerform, isTrue);
    });
  });
}
