import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/widgets/estado_vazio.dart';
import 'package:catalogo_pessoal/widgets/item_card.dart';
import 'package:flutter/material.dart';

class CatalogoGrade extends StatelessWidget {
  final List<ItemCatalogo> itens;
  final ValueChanged<String>? onAlternarFavorito;
  final ValueChanged<String>? onRemover;
  final void Function(String id, StatusItem status)? onMudarStatus;
  final ValueChanged<ItemCatalogo>? onAbrirDetalhe;
  final VoidCallback? onAdicionar;

  const CatalogoGrade({
    required this.itens,
    this.onAlternarFavorito,
    this.onRemover,
    this.onMudarStatus,
    this.onAbrirDetalhe,
    this.onAdicionar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) {
      return EstadoVazio(onAdicionar: onAdicionar);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              return ItemCard(
                key: ValueKey(item.id),
                item: item,
                onTap: onAbrirDetalhe != null
                    ? () => onAbrirDetalhe!(item)
                    : null,
                onAlternarFavorito: onAlternarFavorito,
                onRemover: onRemover,
                onMudarStatus: onMudarStatus,
              );
            },
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 440,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 232,
          ),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final item = itens[index];
            return ItemCard(
              key: ValueKey(item.id),
              item: item,
              onTap: onAbrirDetalhe != null
                  ? () => onAbrirDetalhe!(item)
                  : null,
              onAlternarFavorito: onAlternarFavorito,
              onRemover: onRemover,
              onMudarStatus: onMudarStatus,
            );
          },
        );
      },
    );
  }
}
