import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final ItemCatalogo item;
  final ValueChanged<String> onAlternarFavorito;
  final ValueChanged<String>? onRemover;
  final void Function(String id, StatusItem status)? onMudarStatus;

  const ItemCard({
    required this.item,
    required this.onAlternarFavorito,
    this.onRemover,
    this.onMudarStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: IconButton(
          tooltip: item.favorito ? 'Remover favorito' : 'Favoritar',
          icon: Icon(
            item.favorito ? Icons.favorite : Icons.favorite_border,
            color: item.favorito ? Theme.of(context).colorScheme.primary : null,
          ),
          onPressed: () => onAlternarFavorito(item.id),
        ),
        title: Text(
          item.titulo,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.descricaoExibicao,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${item.status.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMudarStatus != null)
              PopupMenuButton<StatusItem>(
                tooltip: 'Alterar status',
                icon: const Icon(Icons.more_vert),
                onSelected: (novoStatus) => onMudarStatus!(item.id, novoStatus),
                itemBuilder: (context) => [
                  for (final status in StatusItem.values)
                    PopupMenuItem(value: status, child: Text(status.name)),
                ],
              ),
            if (onRemover != null)
              IconButton(
                tooltip: 'Remover item',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onRemover!(item.id),
              ),
          ],
        ),
      ),
    );
  }
}
