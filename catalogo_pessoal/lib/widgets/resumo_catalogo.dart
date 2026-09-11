import 'package:flutter/material.dart';

class ResumoCatalogo extends StatelessWidget {
  final int totalItens;
  final int totalFavoritos;

  const ResumoCatalogo({
    required this.totalItens,
    required this.totalFavoritos,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Catálogo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Itens: $totalItens',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Favoritos: $totalFavoritos',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 32),
            Text(
              'Painel lateral exibido em telas amplas para informações adicionais e detalhes rápidos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
