import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';

const itensIniciais = <ItemCatalogo>[
  ItemCatalogo(
    id: 'livro-001',
    titulo: 'Clean Code',
    categoria: 'Engenharia de Software',
    descricao: 'Práticas para código legível, testável e manutenível.',
    status: StatusItem.emAndamento,
    favorito: true,
  ),
  ItemCatalogo(
    id: 'livro-002',
    titulo: 'The Pragmatic Programmer',
    categoria: 'Desenvolvimento',
    descricao: 'Da jornada do artesão ao mestre programador.',
    status: StatusItem.queroConhecer,
    favorito: false,
  ),
  ItemCatalogo(
    id: 'livro-003',
    titulo: 'Refactoring',
    categoria: 'Engenharia de Software',
    descricao: 'Aperfeiçoando o design de código existente com segurança.',
    status: StatusItem.concluido,
    favorito: true,
  ),
];
