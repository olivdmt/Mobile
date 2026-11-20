import 'dart:async';
import 'dart:convert';

import 'package:catalogo_pessoal/features/books/data/book_suggestion.dart';
import 'package:http/http.dart' as http;

abstract interface class BookSearchRepository {
  Future<List<BookSuggestion>> search(String title);
}

class OpenLibraryBookRepository implements BookSearchRepository {
  OpenLibraryBookRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<BookSuggestion>> search(String title) async {
    final query = title.trim();
    if (query.length < 3) throw const BookSearchException('invalid-query');

    final uri = Uri.https('openlibrary.org', '/search.json', {
      'title': query,
      'fields': 'key,title,author_name,first_publish_year,cover_i',
      'limit': '6',
      'lang': 'pt',
    });
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw const BookSearchException('service-unavailable');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['docs'] is! List) {
        throw const BookSearchException('invalid-response');
      }
      return (decoded['docs'] as List)
          .whereType<Map<String, dynamic>>()
          .map(_parseSuggestion)
          .whereType<BookSuggestion>()
          .toList(growable: false);
    } on TimeoutException {
      throw const BookSearchException('timeout');
    } on http.ClientException {
      throw const BookSearchException('network');
    } on FormatException {
      throw const BookSearchException('invalid-response');
    }
  }

  BookSuggestion? _parseSuggestion(Map<String, dynamic> json) {
    final key = json['key'];
    final title = json['title'];
    if (key is! String || title is! String || title.trim().isEmpty) return null;
    final rawAuthors = json['author_name'];
    final authors = rawAuthors is List
        ? rawAuthors
              .whereType<String>()
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final year = json['first_publish_year'];
    final coverId = json['cover_i'];
    return BookSuggestion(
      key: key,
      title: title.trim(),
      authors: authors,
      firstPublishYear: year is int ? year : null,
      coverId: coverId is int ? coverId : null,
    );
  }
}

class BookSearchException implements Exception {
  const BookSearchException(this.code);

  final String code;

  String get publicMessage => switch (code) {
    'invalid-query' => 'Digite ao menos três caracteres para pesquisar.',
    'timeout' || 'network' || 'service-unavailable' => 'Serviço de livros indisponível. Você ainda pode preencher os dados manualmente.',
    _ => 'A resposta do serviço de livros não pôde ser lida. Tente novamente.',
  };
}
