import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/widgets/item_card.dart';
import 'package:flutter/material.dart';

class CatalogoGrade extends StatelessWidget {
  final List<ItemCatalogo> itens;
  final ValueChanged<String> onAlternarFavorito;
  final ValueChanged<String>? onRemover;
  final void Function(String id, StatusItem status)? onMudarStatus;

  const CatalogoGrade({
    required this.itens,
    required this.onAlternarFavorito,
    this.onRemover,
    this.onMudarStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) {
      return const Center(child: Text('Nenhum item no catálogo.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: itens.length,
      itemBuilder: (context, index) {
        return ItemCard(
          item: itens[index],
          onAlternarFavorito: onAlternarFavorito,
          onRemover: onRemover,
          onMudarStatus: onMudarStatus,
        );
      },
    );
  }
}
