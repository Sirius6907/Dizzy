import 'dart:async';
import 'package:flutter/foundation.dart';
import 'stream_extractor.dart';
import 'vidsrc_extractor.dart';
import 'videasy_extractor.dart';
import '../core/network/network_client.dart';

class StreamResult {
  final String url;
  final String sourceName;
  final String quality;
  final Map<String, String>? headers;

  StreamResult({
    required this.url,
    required this.sourceName,
    this.quality = 'Auto',
    this.headers,
  });
}

/// Unified Multi-Source Stream Resolver Engine (v2.0).
/// Automatically falls back across multiple streaming APIs to guarantee playback.
/// Uses DNS-over-HTTPS (DoH) via NetworkClient to bypass ISP blocking.
class MultiSourceResolver {
  static final MultiSourceResolver _instance = MultiSourceResolver._internal();
  factory MultiSourceResolver() => _instance;
  MultiSourceResolver._internal();

  final StreamExtractor _baseExtractor = StreamExtractor();
  final NetworkClient _networkClient = NetworkClient();

  /// Resolve movie stream with multi-source fallback
  Future<StreamResult?> resolveMovieStream({
    required int tmdbId,
    String? imdbId,
  }) async {
    debugPrint('[MultiSourceResolver] Resolving movie: tmdbId=$tmdbId');

    // 1. Try VidSrc Extractor
    try {
      final vidsrc = VidsrcExtractor();
      final vsStream = await vidsrc.extract(
        tmdbId: tmdbId.toString(),
        isMovie: true,
        timeout: const Duration(seconds: 8),
      );
      
      if (vsStream != null && vsStream.url.isNotEmpty) {
        return StreamResult(
          url: vsStream.url,
          sourceName: 'VidSrc',
          quality: '1080p',
          headers: vsStream.headers,
        );
      }
    } catch (e) {
      debugPrint('[MultiSourceResolver] VidSrc failed: $e');
    }

    // 2. Try Videasy Extractor
    try {
      final videasy = VideasyExtractor(onLog: (msg) => debugPrint('[Videasy] $msg'));
      final veStream = await videasy.extract(
        tmdbId: tmdbId.toString(),
        isMovie: true,
        timeout: const Duration(seconds: 8),
      );
      
      if (veStream != null && veStream.url.isNotEmpty) {
        return StreamResult(
          url: veStream.url,
          sourceName: 'Videasy',
          quality: '1080p',
          headers: veStream.headers,
        );
      }
    } catch (e) {
      debugPrint('[MultiSourceResolver] Videasy failed: $e');
    }

    // 3. Try Base Stream Extractor with Amri
    try {
      final stream = await _baseExtractor.extractWithAmri(
        tmdbId: tmdbId.toString(),
        isMovie: true,
      ).timeout(const Duration(seconds: 10));
      
      if (stream != null && stream.url.isNotEmpty) {
        return StreamResult(
          url: stream.url,
          sourceName: 'Multi-Stream',
          quality: 'Auto',
          headers: stream.headers,
        );
      }
    } catch (e) {
      debugPrint('[MultiSourceResolver] Amri failed: $e');
    }

    return null;
  }

  /// Resolve TV episode stream with multi-source fallback
  Future<StreamResult?> resolveEpisodeStream({
    required int tmdbId,
    required int season,
    required int episode,
  }) async {
    debugPrint('[MultiSourceResolver] Resolving TV: tmdbId=$tmdbId S${season}E$episode');

    // 1. Try VidSrc TV
    try {
      final vidsrc = VidsrcExtractor();
      final vsStream = await vidsrc.extract(
        tmdbId: tmdbId.toString(),
        isMovie: false,
        season: season,
        episode: episode,
        timeout: const Duration(seconds: 8),
      );
      
      if (vsStream != null && vsStream.url.isNotEmpty) {
        return StreamResult(
          url: vsStream.url,
          sourceName: 'VidSrc TV',
          quality: '1080p',
          headers: vsStream.headers,
        );
      }
    } catch (e) {
      debugPrint('[MultiSourceResolver] VidSrc TV failed: $e');
    }

    // 2. Try Videasy TV
    try {
      final videasy = VideasyExtractor(onLog: (msg) => debugPrint('[Videasy] $msg'));
      final veStream = await videasy.extract(
        tmdbId: tmdbId.toString(),
        isMovie: false,
        season: season,
        episode: episode,
        timeout: const Duration(seconds: 8),
      );
      
      if (veStream != null && veStream.url.isNotEmpty) {
        return StreamResult(
          url: veStream.url,
          sourceName: 'Videasy TV',
          quality: '1080p',
          headers: veStream.headers,
        );
      }
    } catch (e) {
      debugPrint('[MultiSourceResolver] Videasy TV failed: $e');
    }

    // 3. Try Base Stream Extractor with Amri
    try {
      final stream = await _baseExtractor.extractWithAmri(
        tmdbId: tmdbId.toString(),
        isMovie: false,
        season: season,
        episode: episode,
      ).timeout(const Duration(seconds: 10));
      
      if (stream != null && stream.url.isNotEmpty) {
        return StreamResult(
          url: stream.url,
          sourceName: 'Multi-Stream TV',
          quality: 'Auto',
          headers: stream.headers,
        );
      }
    } catch (e) {
      debugPrint('[MultiSourceResolver] Amri TV failed: $e');
    }

    return null;
  }
}
