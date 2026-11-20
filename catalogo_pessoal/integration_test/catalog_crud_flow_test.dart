import 'package:catalogo_pessoal/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('registers, creates, edits and deletes a private catalog item', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    final email =
        'catalog-${DateTime.now().millisecondsSinceEpoch}@example.test';
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'senha123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirme a senha'),
      'senha123',
    );
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Catálogo Pessoal'), findsOneWidget);
    await tester.tap(find.text('Novo Item'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('titulo')),
      'Livro de integração',
    );
    await tester.enterText(find.byKey(const Key('categoria')), 'Teste');
    await tester.tap(find.byKey(const Key('salvar_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Livro de integração'), findsOneWidget);

    await tester.tap(find.text('Livro de integração').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('titulo')), 'Livro alterado');
    await tester.tap(find.byKey(const Key('salvar_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Livro alterado'), findsOneWidget);

    await tester.tap(find.text('Livro alterado').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Excluir item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Livro alterado'), findsNothing);
  });
}
