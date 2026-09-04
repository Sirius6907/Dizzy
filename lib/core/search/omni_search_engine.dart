import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../api/tmdb_api.dart';
import '../../api/music_service.dart';
import '../../api/manga_service.dart';
import '../../api/books_service.dart';
import '../../models/movie.dart';

class OmniSearchResult {
  final String title;
  final String subtitle;
  final String posterUrl;
  final String category; // 'Movie', 'TV', 'Music', 'Manga', 'Book'
  final dynamic rawData;

  OmniSearchResult({
    required this.title,
    required this.subtitle,
    required this.posterUrl,
    required this.category,
    required this.rawData,
  });
}

/// Unified Omni-Search Engine searching Movies, TV, Music, Manga, Books in parallel.
class OmniSearchEngine {
  static final OmniSearchEngine _instance = OmniSearchEngine._internal();
  factory OmniSearchEngine() => _instance;
  OmniSearchEngine._internal();

  final TmdbApi _tmdb = TmdbApi();
  final MusicService _music = MusicService();
  final MangaService _manga = MangaService();
  final BooksService _books = BooksService();

  Future<List<OmniSearchResult>> searchAll(String query) async {
    if (query.trim().isEmpty) return const [];

    try {
      final results = await Future.wait([
        _searchTmdb(query),
        _searchMusic(query),
        _searchManga(query),
        _searchBooks(query),
      ]).timeout(const Duration(seconds: 10));

      return results.expand((x) => x).toList();
    } catch (e) {
      debugPrint('[OmniSearchEngine] Search failed: $e');
      return const [];
    }
  }

  Future<List<OmniSearchResult>> _searchTmdb(String query) async {
    try {
      final hits = await _tmdb.searchMulti(query);
      return hits.map((m) {
        final isTv = m.mediaType == 'tv';
        return OmniSearchResult(
          title: m.title,
          subtitle: '${isTv ? "TV Show" : "Movie"} • ${m.releaseDate.length >= 4 ? m.releaseDate.substring(0, 4) : ""} • ★ ${m.voteAverage.toStringAsFixed(1)}',
          posterUrl: m.posterPath.isNotEmpty ? TmdbApi.getImageUrl(m.posterPath) : '',
          category: isTv ? 'TV Show' : 'Movie',
          rawData: m,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<OmniSearchResult>> _searchMusic(String query) async {
    try {
      final tracks = await _music.searchTracks(query);
      return tracks.take(5).map((t) {
        return OmniSearchResult(
          title: t.title,
          subtitle: 'Music • ${t.artist}${t.album.isNotEmpty ? " (${t.album})" : ""}',
          posterUrl: t.cover,
          category: 'Music',
          rawData: t,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<OmniSearchResult>> _searchManga(String query) async {
    try {
      final mangas = await _manga.search(query);
      return mangas.take(5).map((m) {
        return OmniSearchResult(
          title: m['title'] ?? 'Manga',
          subtitle: 'Manga • ${m['author'] ?? "Unknown"}',
          posterUrl: m['cover'] ?? '',
          category: 'Manga',
          rawData: m,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<OmniSearchResult>> _searchBooks(String query) async {
    try {
      final bList = await _books.search(query);
      return bList.take(5).map((b) {
        return OmniSearchResult(
          title: b['title'] ?? 'Book',
          subtitle: 'Book • ${b['author'] ?? "Unknown"}',
          posterUrl: b['cover'] ?? '',
          category: 'Book',
          rawData: b,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
