import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

class CacheManager {
  static final CacheManager instance = CacheManager._();
  CacheManager._();

  late Box<dynamic> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<dynamic>(AppConstants.cacheBoxName);
  }

  /// Get cached data with TTL check (Stale-While-Revalidate pattern)
  T? get<T>({
    required String key,
    required T Function(dynamic) fromJson,
    required int ttlHours,
  }) {
    try {
      final timestampKey = '${key}_ts';
      final cachedData = _cacheBox.get(key);
      final cachedTimestamp = _cacheBox.get(timestampKey) as int?;

      if (cachedData == null || cachedTimestamp == null) {
        return null;
      }

      final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTimestamp;
      final ttlMillis = ttlHours * 60 * 60 * 1000;

      final result = fromJson(cachedData);

      if (cacheAge > ttlMillis) {
        debugPrint('Cache EXPIRED (returning stale): $key');
      } else {
        debugPrint('Cache HIT (FRESH): $key');
      }

      return result;
    } catch (e) {
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  /// Save data with timestamp
  Future<void> set(String key, dynamic value) async {
    final timestampKey = '${key}_ts';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _cacheBox.put(key, value);
    await _cacheBox.put(timestampKey, timestamp);
  }

  /// Check if cache is valid (not expired)
  bool isValid(String key, int ttlHours) {
    final timestampKey = '${key}_ts';
    final cachedTimestamp = _cacheBox.get(timestampKey) as int?;

    if (cachedTimestamp == null) return false;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTimestamp;
    final ttlMillis = ttlHours * 60 * 60 * 1000;

    return cacheAge <= ttlMillis;
  }

  /// Clear specific cache
  Future<void> clear(String key) async {
    final timestampKey = '${key}_ts';
    await _cacheBox.delete(key);
    await _cacheBox.delete(timestampKey);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _cacheBox.clear();
  }
}
