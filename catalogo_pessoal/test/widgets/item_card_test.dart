import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemCard Widget', () {
    const item = ItemCatalogo(
      id: 'livro-001',
      titulo: 'Clean Code',
      categoria: 'Programação',
      descricao: 'Guia de boas práticas',
      status: StatusItem.emAndamento,
      favorito: true,
    );

    testWidgets('exibe informações do item, status e estrela de favorito', (
      tester,
    ) async {
      String? idFavorito;
      var abriuDetalhe = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: item,
              onAlternarFavorito: (id) => idFavorito = id,
              onTap: () => abriuDetalhe = true,
            ),
          ),
        ),
      );

      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.text('Guia de boas práticas'), findsOneWidget);
      expect(find.text('Em Andamento'), findsOneWidget);
      expect(find.text('Programação'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);

      await tester.tap(find.byTooltip('Remover dos favoritos'));
      await tester.pump();
      expect(idFavorito, 'livro-001');

      await tester.tap(find.text('Clean Code'));
      await tester.pump();
      expect(abriuDetalhe, isTrue);
    });
  });
}
