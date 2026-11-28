import 'dart:convert';

import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/formulario_page.dart';
import 'package:catalogo_pessoal/screens/lista_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the offline cache banner and item', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(
      const MaterialApp(
        home: ListaPage(
          itens: [
            ItemCatalogo(
              id: 'offline-evidence',
              titulo: 'Livro recuperado do cache',
              categoria: 'Leitura',
              status: StatusItem.emAndamento,
            ),
          ],
          showingLocalCache: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Livro recuperado do cache'), findsOneWidget);
    expect(
      find.text('Dados do cache local. Alterações precisam de conexão.'),
      findsOneWidget,
    );
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('converts an Open Library result from MockClient', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final repository = OpenLibraryBookRepository(
      client: MockClient((request) async {
        expect(request.url.host, 'openlibrary.org');
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'docs': [
                {
                  'key': '/works/OL123W',
                  'title': 'Dom Casmurro',
                  'author_name': ['Machado de Assis'],
                  'first_publish_year': 1899,
                },
              ],
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    await tester.pumpWidget(
      MaterialApp(home: FormularioPage(bookSearchRepository: repository)),
    );
    await tester.enterText(find.byKey(const Key('titulo')), 'Dom Casmurro');
    await tester.tap(find.text('Buscar dados do livro'));
    await tester.pumpAndSettle();

    expect(find.text('Dom Casmurro'), findsNWidgets(2));
    expect(find.textContaining('Machado de Assis'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('shows HTTP 503 and retries the Open Library request', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    var requests = 0;
    final repository = OpenLibraryBookRepository(
      client: MockClient((_) async {
        requests++;
        return http.Response('temporarily unavailable', 503);
      }),
    );
    await tester.pumpWidget(
      MaterialApp(home: FormularioPage(bookSearchRepository: repository)),
    );
    await tester.enterText(find.byKey(const Key('titulo')), 'Duna');
    await tester.tap(find.text('Buscar dados do livro'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Serviço de livros indisponível'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(requests, 2);
    expect(
      find.textContaining('Serviço de livros indisponível'),
      findsOneWidget,
    );
    expect(
      find.text('Você ainda pode preencher os dados manualmente.'),
      findsOneWidget,
    );
    await tester.binding.setSurfaceSize(null);
  });
}
