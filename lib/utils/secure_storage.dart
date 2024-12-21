import 'package:cards/core/storage/storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureStorage implements Storage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  const SecureStorage();
  @override
  Future<bool> containsKey({required String key}) {
    return _storage.containsKey(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() {
    return _storage.deleteAll();
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<Map<String, String>> readAll() {
    return _storage.readAll();
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }
}
