import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/lista_page.dart';
import 'package:catalogo_pessoal/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListaPage Screen', () {
    testWidgets('mostra o estado vazio', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ListaPage(itens: [])));

      expect(find.text('Nenhum item cadastrado'), findsOneWidget);
      expect(find.byType(ItemCard), findsNothing);
    });

    testWidgets('mostra itens na lista quando a colecao nao esta vazia', (
      tester,
    ) async {
      const itensTeste = [
        ItemCatalogo(
          id: '1',
          titulo: 'O Hobbit',
          categoria: 'Fantasia',
          status: StatusItem.concluido,
        ),
        ItemCatalogo(
          id: '2',
          titulo: 'Duna',
          categoria: 'Ficção',
          status: StatusItem.emAndamento,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(home: ListaPage(itens: itensTeste)),
      );

      expect(find.byType(ItemCard), findsNWidgets(2));
      expect(find.text('O Hobbit'), findsOneWidget);
      expect(find.text('Duna'), findsOneWidget);
    });

    testWidgets('mostra loading, erro recuperável e cache offline', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        const MaterialApp(home: ListaPage(itens: [], isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ListaPage(
            itens: const [],
            loadError: 'Sem conexão',
            onRetry: () async => retried = true,
          ),
        ),
      );
      expect(find.text('Sem conexão'), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();
      expect(retried, isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: ListaPage(
            itens: [ItemCatalogo(id: 'cache-1', titulo: 'Livro offline')],
            showingLocalCache: true,
          ),
        ),
      );
      expect(
        find.text('Dados do cache local. Alterações precisam de conexão.'),
        findsOneWidget,
      );
      expect(find.text('Livro offline'), findsOneWidget);
    });
  });
}
