import 'dart:convert';

import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final ItemCatalogo item;
  final ValueChanged<String>? onAlternarFavorito;
  final ValueChanged<String>? onRemover;
  final void Function(String id, StatusItem status)? onMudarStatus;
  final VoidCallback? onTap;

  const ItemCard({
    required this.item,
    this.onAlternarFavorito,
    this.onRemover,
    this.onMudarStatus,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.fotoLocalBase64?.isNotEmpty == true) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    base64Decode(item.fotoLocalBase64!),
                    width: 48,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 48,
                      height: 64,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              IconButton(
                tooltip: item.favorito
                    ? 'Remover dos favoritos'
                    : 'Marcar como favorito',
                icon: Icon(
                  item.favorito
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: item.favorito
                      ? Colors.amber[700]
                      : colorScheme.outline,
                  size: 28,
                ),
                onPressed: onAlternarFavorito != null
                    ? () => onAlternarFavorito!(item.id)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.descricaoExibicao,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          avatar: Icon(
                            item.status.icone,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          label: Text(
                            item.status.rotulo,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (item.categoria != null &&
                            item.categoria!.trim().isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.label_outline, size: 16),
                            label: Text(
                              item.categoriaExibicao,
                              style: theme.textTheme.labelSmall,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onMudarStatus != null)
                    PopupMenuButton<StatusItem>(
                      tooltip: 'Alterar status',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (novoStatus) =>
                          onMudarStatus!(item.id, novoStatus),
                      itemBuilder: (context) => [
                        for (final status in StatusItem.values)
                          PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(status.icone, size: 18),
                                const SizedBox(width: 8),
                                Text(status.rotulo),
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (onRemover != null)
                    IconButton(
                      tooltip: 'Remover item',
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: () => onRemover!(item.id),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
