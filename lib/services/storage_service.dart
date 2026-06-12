// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setString(String key, String value) async =>
      (await _p).setString(key, value);

  Future<String?> getString(String key) async =>
      (await _p).getString(key);

  Future<void> setInt(String key, int value) async =>
      (await _p).setInt(key, value);

  Future<int?> getInt(String key) async =>
      (await _p).getInt(key);

  Future<void> setBool(String key, bool value) async =>
      (await _p).setBool(key, value);

  Future<bool?> getBool(String key) async =>
      (await _p).getBool(key);

  Future<void> setJson(String key, Map<String, dynamic> value) async =>
      (await _p).setString(key, jsonEncode(value));

  Future<Map<String, dynamic>?> getJson(String key) async {
    final s = (await _p).getString(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async =>
      (await _p).setString(key, jsonEncode(value));

  Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final s = (await _p).getString(key);
    if (s == null) return null;
    return (jsonDecode(s) as List).cast<Map<String, dynamic>>();
  }

  Future<void> remove(String key) async => (await _p).remove(key);

  Future<void> clear() async => (await _p).clear();
}