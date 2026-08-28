import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';

const itensIniciais = <ItemCatalogo>[
  ItemCatalogo(
    id: 'livro-001',
    titulo: 'Clean Code',
    descricao: 'Praticas para codigo legivel',
    status: StatusItem.emAndamento,
    favorito: true,
  ),
  ItemCatalogo(
    id: 'livro-002',
    titulo: 'The Pragmatic Programmer',
    status: StatusItem.emAndamento,
  ),
];
