import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/cache/cache_engine.dart';

class TmdbService {
  static const String apiKey = 'ef0d35fe298492270fcd565215e1901c';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  
  final CacheEngine _cache = CacheEngine();

  Future<Map<String, dynamic>> getMovieDetails(String tmdbId) async {
    final cacheKey = 'tmdb_svc_movie_$tmdbId';
    
    // Try cache first
    try {
      final cached = await _cache.get(cacheKey, maxAge: const Duration(hours: 24));
      if (cached != null) {
        if (cached.isStale) _refreshMovieInBackground(tmdbId, cacheKey);
        return cached.data;
      }
    } catch (_) {}
    
    // Fetch fresh
    final url = '$baseUrl/movie/$tmdbId?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _cache.set(cacheKey, data);
      return data;
    } else {
      throw Exception('Failed to fetch movie details: ${response.statusCode}');
    }
  }
  
  void _refreshMovieInBackground(String tmdbId, String cacheKey) {
    Future.delayed(Duration.zero, () async {
      try {
        final url = '$baseUrl/movie/$tmdbId?api_key=$apiKey';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await _cache.set(cacheKey, jsonDecode(response.body));
        }
      } catch (_) {}
    });
  }

  Future<Map<String, dynamic>> getTvShowDetails(String tmdbId) async {
    final cacheKey = 'tmdb_svc_tv_$tmdbId';
    
    // Try cache first
    try {
      final cached = await _cache.get(cacheKey, maxAge: const Duration(hours: 24));
      if (cached != null) {
        if (cached.isStale) _refreshTvInBackground(tmdbId, cacheKey);
        return cached.data;
      }
    } catch (_) {}
    
    // Fetch fresh
    final url = '$baseUrl/tv/$tmdbId?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _cache.set(cacheKey, data);
      return data;
    } else {
      throw Exception('Failed to fetch TV show details: ${response.statusCode}');
    }
  }
  
  void _refreshTvInBackground(String tmdbId, String cacheKey) {
    Future.delayed(Duration.zero, () async {
      try {
        final url = '$baseUrl/tv/$tmdbId?api_key=$apiKey';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await _cache.set(cacheKey, jsonDecode(response.body));
        }
      } catch (_) {}
    });
  }

  String getMovieTitle(Map<String, dynamic> movieData) {
    return movieData['title'] ?? '';
  }

  String getTvShowTitle(Map<String, dynamic> tvData) {
    return tvData['name'] ?? '';
  }

  String getReleaseYear(Map<String, dynamic> data) {
    final releaseDate = data['release_date'] ?? data['first_air_date'] ?? '';
    if (releaseDate.isNotEmpty) {
      return releaseDate.split('-')[0];
    }
    return '';
  }

  /// Fetches season details including all episodes for a given TV show season.
  /// Returns the TMDB season object with an 'episodes' list.
  Future<Map<String, dynamic>> getTvSeasonDetails(int tvId, int seasonNumber) async {
    final cacheKey = 'tmdb_svc_season_${tvId}_$seasonNumber';
    
    // Try cache first (seasons change rarely, 7-day TTL)
    try {
      final cached = await _cache.get(cacheKey, maxAge: const Duration(days: 7));
      if (cached != null) {
        if (cached.isStale) _refreshSeasonInBackground(tvId, seasonNumber, cacheKey);
        return cached.data;
      }
    } catch (_) {}
    
    // Fetch fresh
    final url = '$baseUrl/tv/$tvId/season/$seasonNumber?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _cache.set(cacheKey, data);
      return data;
    } else {
      throw Exception('Failed to fetch season details: ${response.statusCode}');
    }
  }
  
  void _refreshSeasonInBackground(int tvId, int seasonNumber, String cacheKey) {
    Future.delayed(Duration.zero, () async {
      try {
        final url = '$baseUrl/tv/$tvId/season/$seasonNumber?api_key=$apiKey';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await _cache.set(cacheKey, jsonDecode(response.body));
        }
      } catch (_) {}
    });
  }

  /// Returns the total number of seasons for a TV show.
  Future<int> getTvSeasonCount(int tvId) async {
    final data = await getTvShowDetails(tvId.toString());
    return (data['number_of_seasons'] as int?) ?? 0;
  }
}
