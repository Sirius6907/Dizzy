import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Robust networking client with DNS-over-HTTPS (DoH) support and automatic retry/fallback.
/// Bypasses ISP DNS blocking for scraped media sources and metadata APIs.
class NetworkClient {
  static final NetworkClient _instance = NetworkClient._internal();
  factory NetworkClient() => _instance;
  NetworkClient._internal();

  final http.Client _client = http.Client();

  // Cloudflare & Google DoH endpoints
  static const List<String> _dohEndpoints = [
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/resolve',
  ];

  /// Perform a GET request with automatic retry and timeout
  Future<http.Response?> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _client.get(uri, headers: headers).timeout(timeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        if (response.statusCode == 404 || response.statusCode == 403) {
          return response; // Return client error immediately without retry
        }
      } catch (e) {
        debugPrint('[NetworkClient] Attempt $attempt failed for ${uri.host}: $e');
        if (attempt == maxRetries) {
          return null;
        }
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
    return null;
  }

  /// Perform a POST request with retry
  Future<http.Response?> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _client.post(uri, headers: headers, body: body).timeout(timeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
      } catch (e) {
        debugPrint('[NetworkClient] POST Attempt $attempt failed for ${uri.host}: $e');
        if (attempt == maxRetries) return null;
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
    return null;
  }

  /// Resolve hostname via DNS-over-HTTPS (Cloudflare / Google)
  Future<String?> resolveDoH(String hostname) async {
    for (final doh in _dohEndpoints) {
      try {
        final uri = Uri.parse('$doh?name=$hostname&type=A');
        final resp = await get(uri, headers: {'Accept': 'application/dns-json'});
        if (resp != null && resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final answer = data['Answer'] as List?;
          if (answer != null && answer.isNotEmpty) {
            return answer.first['data'] as String?;
          }
        }
      } catch (_) {}
    }
    return null;
  }
}
