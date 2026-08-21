import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/Item_catalogo.dart';


void main() {

  final item = ItemCatalogo(
    id: '1',
    titulo: 'Clean Code',
    descricao: 'Praticas para codigo legivel',
    status: StatusItem.emAndamento,
    favorito: true,
  );

    final outroItem = ItemCatalogo(
    id: '2',
    titulo: 'Dart em pratica',
    descricao: 'Praticas para codigo legivel',
    status: StatusItem.concluido,
    favorito: false,
  );

  final itens = <ItemCatalogo>[item, outroItem];

  final favoritos = itens
      .where((item) => item.favorito)
      .toList(growable: false);

  final titulos = itens.map((item) => item.titulo).toList(growable: false);

  print(favoritos.length);
  print(titulos);
}
