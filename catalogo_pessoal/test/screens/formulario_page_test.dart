import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/catalog_photo_picker.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/formulario_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DeniedCameraPicker implements CatalogPhotoPicker {
  bool galleryOpened = false;

  @override
  Future<String?> takePhoto() async =>
      throw const CatalogPhotoPermissionDenied();

  @override
  Future<String?> chooseFromGallery() async {
    galleryOpened = true;
    return null;
  }

  @override
  Future<String?> retrieveLostPhoto() async => null;
}

void main() {
  group('FormularioPage Screen', () {
    testWidgets('valida campos obrigatorios e exibe erro', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FormularioPage()));

      await tester.enterText(find.byKey(const Key('titulo')), '');
      await tester.tap(find.byKey(const Key('salvar_button')));
      await tester.pump();

      expect(find.text('Informe o título'), findsOneWidget);
    });

    testWidgets('valida tamanho minimo do titulo e da categoria', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: FormularioPage()));

      await tester.enterText(find.byKey(const Key('titulo')), 'Ab');
      await tester.enterText(find.byKey(const Key('categoria')), 'X');
      await tester.tap(find.byKey(const Key('salvar_button')));
      await tester.pump();

      expect(find.text('Use pelo menos 3 caracteres'), findsNWidgets(2));
    });

    testWidgets('inicia campos preenchidos no modo edicao', (tester) async {
      const item = ItemCatalogo(
        id: '123',
        titulo: 'Duna',
        categoria: 'Ficção',
        descricao: 'Livro clássico de ficção científica',
        status: StatusItem.emAndamento,
        favorito: true,
      );

      await tester.pumpWidget(
        const MaterialApp(home: FormularioPage(itemInicial: item)),
      );

      expect(find.text('Editar Item'), findsOneWidget);
      expect(find.text('Duna'), findsOneWidget);
      expect(find.text('Ficção'), findsOneWidget);
      expect(find.text('Livro clássico de ficção científica'), findsOneWidget);
      expect(find.text('Salvar alterações'), findsOneWidget);
    });

    testWidgets('camera negada oferece galeria ou continuar sem foto', (
      tester,
    ) async {
      final picker = _DeniedCameraPicker();
      await tester.pumpWidget(
        MaterialApp(home: FormularioPage(photoPicker: picker)),
      );
      await tester.ensureVisible(find.text('Tirar foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tirar foto'));
      await tester.pumpAndSettle();

      expect(find.text('Permissão da câmera negada'), findsOneWidget);
      expect(
        find.text(
          'A câmera não foi acessada. Você pode escolher uma imagem da galeria ou continuar sem foto.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Escolher da galeria'));
      await tester.pumpAndSettle();
      expect(picker.galleryOpened, isTrue);

      await tester.ensureVisible(find.text('Tirar foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tirar foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar sem foto'));
      await tester.pumpAndSettle();
      expect(find.text('Tirar foto'), findsOneWidget);
    });
  });
}
