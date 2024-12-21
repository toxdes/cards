import 'dart:collection';

import 'package:cards/core/storage/storage.dart';

class MockStorage implements Storage {
  final Map<String, String> map = HashMap();
  MockStorage();
  @override
  Future<bool> containsKey({required String key}) async {
    return map.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    map.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    map.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return map[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    HashMap<String, String> result = HashMap();
    for (MapEntry<String, String> element in map.entries) {
      result[element.key] = element.value;
    }
    return result;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    map[key] = value;
  }
}
