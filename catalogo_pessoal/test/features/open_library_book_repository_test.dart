import 'dart:convert';

import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses Open Library results and builds cover data', () async {
    late Uri requestedUri;
    final repository = OpenLibraryBookRepository(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          jsonEncode({
            'docs': [
              {
                'key': '/works/OL1W',
                'title': 'Dom Casmurro',
                'author_name': ['Machado de Assis'],
                'first_publish_year': 1899,
                'cover_i': 123,
              },
              {'key': 'bad-row', 'title': ''},
            ],
          }),
          200,
        );
      }),
    );
    final books = await repository.search('Dom Casmurro');
    expect(requestedUri.host, 'openlibrary.org');
    expect(requestedUri.queryParameters['limit'], '6');
    expect(books, hasLength(1));
    expect(books.single.title, 'Dom Casmurro');
    expect(books.single.authors, ['Machado de Assis']);
    expect(books.single.coverUrl, contains('123'));
  });

  test('reports service failure with a user-facing fallback', () async {
    final repository = OpenLibraryBookRepository(
      client: MockClient((_) async => http.Response('offline', 503)),
    );
    await expectLater(
      repository.search('Fundação'),
      throwsA(
        isA<BookSearchException>()
            .having((e) => e.code, 'code', 'service-unavailable')
            .having((e) => e.publicMessage, 'message', contains('manualmente')),
      ),
    );
  });

  test('rejects too short query before making a request', () async {
    final repository = OpenLibraryBookRepository(
      client: MockClient((_) async => throw StateError('should not send')),
    );
    await expectLater(
      repository.search('ab'),
      throwsA(
        isA<BookSearchException>().having(
          (e) => e.code,
          'code',
          'invalid-query',
        ),
      ),
    );
  });
}
