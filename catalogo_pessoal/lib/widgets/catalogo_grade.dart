import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/widgets/item_card.dart';
import 'package:flutter/material.dart';

class CatalogoGrade extends StatelessWidget {
  final List<ItemCatalogo> itens;

  const CatalogoGrade({required this.itens, super.key});

  @override
  Widget build(BuildContext context) {
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
        return ItemCard(item: itens[index]);
      },
    );
  }
}
