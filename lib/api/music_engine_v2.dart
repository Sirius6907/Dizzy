import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'music_service.dart';
import '../services/youtube_audio_extractor.dart';

/// Next-Gen Music Engine aggregating Deezer + YouTube Music.
class MusicEngineV2 {
  static final MusicEngineV2 _instance = MusicEngineV2._internal();
  factory MusicEngineV2() => _instance;
  MusicEngineV2._internal();

  final MusicService _deezer = MusicService();

  /// Search tracks across Deezer
  Future<List<MusicTrack>> search(String query) async {
    final deezerResults = await _deezer.searchTracks(query);
    if (deezerResults.isNotEmpty) {
      return deezerResults;
    }
    return <MusicTrack>[];
  }

  /// Get direct audio stream URL for a track
  Future<String?> getAudioStreamUrl(MusicTrack track) async {
    // 1. If local track exists, use it
    if (track.localPath != null && track.localPath!.isNotEmpty) {
      return track.localPath;
    }

    // 2. Try YouTube audio extraction
    try {
      final ytExtractor = YoutubeAudioExtractor.instance;
      final result = await ytExtractor.extract(track.title, track.artist);
      
      if (result != null && result.audioUrl.isNotEmpty) {
        debugPrint('[MusicEngineV2] Resolved via YouTube: ${result.videoId}');
        return result.audioUrl;
      }
    } catch (e) {
      debugPrint('[MusicEngineV2] YouTube extraction failed: $e');
    }

    return null;
  }

  /// Get trending tracks with caching
  Future<List<MusicTrack>> getTrending({int index = 0, int limit = 20}) async {
    return _deezer.getTrendingTracks(index: index, limit: limit);
  }
}
