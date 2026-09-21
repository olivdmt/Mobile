import 'package:catalogo_pessoal/widgets/estado_vazio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EstadoVazio Widget', () {
    testWidgets('renderiza mensagem de estado vazio e botão de ação', (
      tester,
    ) async {
      var clicou = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EstadoVazio(onAdicionar: () => clicou = true)),
        ),
      );

      expect(find.text('Nenhum item cadastrado'), findsOneWidget);
      expect(find.text('Adicionar primeiro item'), findsOneWidget);
      expect(find.byIcon(Icons.collections_bookmark_outlined), findsOneWidget);

      await tester.tap(find.text('Adicionar primeiro item'));
      await tester.pump();

      expect(clicou, isTrue);
    });

    testWidgets(
      'renderiza mensagem personalizada sem botão quando callback é nulo',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EstadoVazio(mensagem: 'Nenhum resultado encontrado'),
            ),
          ),
        );

        expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
      },
    );
  });
}
