import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, super.key});

  final ItemCatalogo item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          item.favorito ? Icons.favorite : Icons.bookmark_border,
          color: item.favorito ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          item.titulo,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          item.descricaoExibicao,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: item.favorito ? 'Remover favorito' : 'Adicionar favorito',
          onPressed: () {},
          icon: Icon(
            item.favorito ? Icons.favorite : Icons.favorite_border,
          ),
        ),
      ),
    );
  }
}
