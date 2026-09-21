import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/detalhe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetalhePage Screen', () {
    const item = ItemCatalogo(
      id: 'livro-001',
      titulo: 'O Senhor dos Anéis',
      categoria: 'Fantasia Épica',
      descricao: 'Uma grande aventura na Terra Média.',
      status: StatusItem.concluido,
      favorito: true,
    );

    testWidgets('exibe detalhes completos do item selecionado', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DetalhePage(item: item)));

      expect(find.text('O Senhor dos Anéis'), findsWidgets);
      expect(find.text('Fantasia Épica'), findsOneWidget);
      expect(find.text('Uma grande aventura na Terra Média.'), findsOneWidget);
      expect(find.text('Concluído'), findsOneWidget);
      expect(find.text('Favorito'), findsOneWidget);
      expect(find.text('Voltar'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
    });
  });
}
