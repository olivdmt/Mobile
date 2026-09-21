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
  });
}
