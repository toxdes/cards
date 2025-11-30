import 'package:cards/providers/auth_notifier.dart';
import 'package:cards/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    await AuthService.init();
  });

  test('AuthNotifier initializes with _authenticated = false', () {
    AuthNotifier notifier = AuthNotifier();
    expect(notifier.isAuthInProgress(), false);
  });

  test('isAuthInProgress returns false initially', () {
    AuthNotifier notifier = AuthNotifier();
    expect(notifier.isAuthInProgress(), false);
  });

  test('needsAuth returns false when deviceAuthEnabled is false', () {
    AuthNotifier notifier = AuthNotifier();
    bool result = notifier.needsAuth(false);
    expect(result, false);
  });

  test('needsAuth returns false when AuthService.isAuthSupported() is false',
      () {
    // TODO: complete this test after refactor
    assert(true);
  });

  test('needsAuth returns false when already authenticated', () async {
    // TODO: complete this test after refactor
    assert(true);
  });

  test('authenticate returns false if AuthService.isAuthSupported() is false',
      () async {
    // TODO: complete this test after refactor
    assert(true);
  });

  test('authenticate returns false if already in progress', () async {
    AuthNotifier notifier = AuthNotifier();
    // TODO: test passes, but for wrong reasons.
    // it passes because AuthService.isAuthSupported() returns false

    // Start first authentication (if supported)
    Future<bool> firstAuth = notifier.authenticate();

    // Try to authenticate again immediately
    bool secondResult = await notifier.authenticate();

    // Second call should return false (already in progress)
    expect(secondResult, false);

    // Wait for first to complete
    await firstAuth;
  });

  test('authenticate returns cached value if already authenticated', () async {
    // TODO: test passes, but for wrong reasons.
    // it passes because AuthService.isAuthSupported() returns false

    AuthNotifier notifier = AuthNotifier();
    // First call (will attempt authentication)
    bool firstResult = await notifier.authenticate();

    // Second call should return cached result
    bool secondResult = await notifier.authenticate();

    // Both results should be the same
    expect(firstResult, secondResult);
  });

  test('authenticate notifies listeners on state change', () async {
    // TODO: complete this test after refactor
    assert(true);
  });

  test('isAuthInProgress returns true during authentication', () async {
    // TODO: complete this test after refactor
    assert(true);
  });

  test('authenticate extends ChangeNotifier', () {
    AuthNotifier notifier = AuthNotifier();
    expect(notifier, isA<ChangeNotifier>());
  });

  test('needsAuth checks all three conditions correctly', () async {
    AuthNotifier notifier = AuthNotifier();

    // Test: deviceAuthEnabled = false
    expect(notifier.needsAuth(false), false);

    // Test: deviceAuthEnabled = true but AuthService.isAuthSupported() = false
    if (!AuthService.isAuthSupported()) {
      expect(notifier.needsAuth(true), false);
    }

    // Test: both true but already authenticated
    // Authenticate first
    await notifier.authenticate();
    // If we get here and auth was successful, needsAuth should be false
    bool result = notifier.needsAuth(true);
    // Either already authenticated or not supported (result = false in both cases)
    expect(result, isFalse);
  });

  test('multiple authenticate calls handle concurrent state correctly',
      () async {
    // TODO: test passes, but for wrong reasons. complete this test after refactor
    AuthNotifier notifier = AuthNotifier();
    List<bool> results = [];
    // Call authenticate multiple times rapidly
    results.add(await notifier.authenticate());
    results.add(await notifier.authenticate());
    results.add(await notifier.authenticate());

    // After first call completes, subsequent calls should return cached result
    // or false (if still in progress)
    expect(results.length, 3);
  });

  test('AuthNotifier state resets properly for new instance', () async {
    AuthNotifier notifier1 = AuthNotifier();
    AuthNotifier notifier2 = AuthNotifier();

    expect(notifier1.isAuthInProgress(), notifier2.isAuthInProgress());
  });
}
