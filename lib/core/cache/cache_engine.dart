import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight persistent JSON cache with Stale-While-Revalidate pattern.
/// Keeps Dizzy UI instantaneous by serving cached data immediately while fetching fresh data.
class CacheEngine {
  static final CacheEngine _instance = CacheEngine._internal();
  factory CacheEngine() => _instance;
  CacheEngine._internal();

  Directory? _cacheDir;

  Future<Directory> get _dir async {
    _cacheDir ??= await getTemporaryDirectory();
    final d = Directory('${_cacheDir!.path}/dizzy_cache');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  /// Get cached data if available and within TTL.
  /// If stale, returns cached data but sets [isStale] = true.
  Future<({dynamic data, bool isStale})?> get(String key, {Duration maxAge = const Duration(hours: 12)}) async {
    try {
      final sanitized = _sanitizeKey(key);
      final d = await _dir;
      final file = File('${d.path}/$sanitized.json');

      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final map = json.decode(content) as Map<String, dynamic>;
      final timestamp = DateTime.parse(map['timestamp'] as String);
      final isStale = DateTime.now().difference(timestamp) > maxAge;

      return (data: map['data'], isStale: isStale);
    } catch (e) {
      debugPrint('[CacheEngine] Error reading cache key "$key": $e');
      return null;
    }
  }

  /// Save data to persistent cache with current timestamp
  Future<void> set(String key, dynamic data) async {
    try {
      final sanitized = _sanitizeKey(key);
      final d = await _dir;
      final file = File('${d.path}/$sanitized.json');

      final payload = json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      });

      await file.writeAsString(payload);
    } catch (e) {
      debugPrint('[CacheEngine] Error writing cache key "$key": $e');
    }
  }

  /// Clear all cache files
  Future<void> clearAll() async {
    try {
      final d = await _dir;
      if (await d.exists()) {
        await d.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[CacheEngine] Clear failed: $e');
    }
  }
}
