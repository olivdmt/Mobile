import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemCatalogo Model', () {
    test('criação com valores padrão e getters de fallback', () {
      const item = ItemCatalogo(id: '1', titulo: 'Flutter na Prática');

      expect(item.id, '1');
      expect(item.titulo, 'Flutter na Prática');
      expect(item.descricaoExibicao, 'Sem descrição');
      expect(item.categoriaExibicao, 'Geral');
      expect(item.status, StatusItem.queroConhecer);
      expect(item.favorito, false);
      expect(item.tituloValido, true);
    });

    test('tituloValido retorna false para títulos curtos ou vazios', () {
      const itemCurto = ItemCatalogo(id: '2', titulo: 'AB');
      const itemVazio = ItemCatalogo(id: '3', titulo: '   ');

      expect(itemCurto.tituloValido, false);
      expect(itemVazio.tituloValido, false);
    });

    test('copyWith preserva identidade e atualiza campos selecionados', () {
      const original = ItemCatalogo(
        id: '10',
        titulo: 'Livro Original',
        categoria: 'Ficção',
        status: StatusItem.emAndamento,
        favorito: false,
      );

      final atualizado = original.copyWith(
        titulo: 'Livro Atualizado',
        status: StatusItem.concluido,
        favorito: true,
      );

      expect(atualizado.id, '10');
      expect(atualizado.titulo, 'Livro Atualizado');
      expect(atualizado.categoria, 'Ficção');
      expect(atualizado.status, StatusItem.concluido);
      expect(atualizado.favorito, true);
    });

    test('igualdade e hashCode funcionam por valor', () {
      const itemA = ItemCatalogo(
        id: '1',
        titulo: 'Dart',
        status: StatusItem.concluido,
      );
      const itemB = ItemCatalogo(
        id: '1',
        titulo: 'Dart',
        status: StatusItem.concluido,
      );
      const itemC = ItemCatalogo(
        id: '2',
        titulo: 'Dart',
        status: StatusItem.concluido,
      );

      expect(itemA, equals(itemB));
      expect(itemA.hashCode, equals(itemB.hashCode));
      expect(itemA, isNot(equals(itemC)));
    });
  });
}
