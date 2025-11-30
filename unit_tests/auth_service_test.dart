import 'package:cards/services/auth_service.dart';
import 'package:test/test.dart';

void main() {
  test('isAuthSupported throws if called before init', () {
    expect(() {
      AuthService.isAuthSupported();
    },
        throwsA(predicate((e) =>
            e is AuthServiceException &&
            e.errorCode == AuthServiceErrorCodes.calledWithoutInit)));
  });

  test('authenticate throws if called before init', () async {
    expect(() async {
      await AuthService.authenticate();
    },
        throwsA(predicate((e) =>
            e is AuthServiceException &&
            e.errorCode == AuthServiceErrorCodes.calledWithoutInit)));
  });

  test('init sets initialized flag', () async {
    await AuthService.init();
    // After init, isAuthSupported should not throw
    expect(() {
      AuthService.isAuthSupported();
    }, returnsNormally);
  });

  test('isAuthSupported returns bool after init', () async {
    await AuthService.init();
    bool supported = AuthService.isAuthSupported();
    expect(supported, isA<bool>());
  });

  test('authenticate returns bool after init', () async {
    await AuthService.init();
    bool result = await AuthService.authenticate();
    expect(result, isA<bool>());
  });

  test('AuthServiceException toString includes error code and message',
      () async {
    AuthServiceException exception = AuthServiceException(
        AuthServiceErrorCodes.calledWithoutInit, 'test message');
    String exceptionString = exception.toString();
    expect(exceptionString, contains('AuthServiceException'));
    expect(exceptionString, contains('257')); // 0x101 in decimal
    expect(exceptionString, contains('test message'));
  });
}
