import 'package:flutter/material.dart';

class ResumoCatalogo extends StatelessWidget {
  final int totalItens;
  final int totalFavoritos;
  final int totalConcluidos;
  final int totalEmAndamento;

  const ResumoCatalogo({
    required this.totalItens,
    required this.totalFavoritos,
    this.totalConcluidos = 0,
    this.totalEmAndamento = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Painel do Catálogo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildLinhaMetrica(
                context,
                icone: Icons.collections_bookmark_outlined,
                rotulo: 'Total de itens',
                valor: totalItens.toString(),
              ),
              const SizedBox(height: 10),
              _buildLinhaMetrica(
                context,
                icone: Icons.star_rounded,
                rotulo: 'Favoritos',
                valor: totalFavoritos.toString(),
                corIcone: Colors.amber[700],
              ),
              const SizedBox(height: 10),
              _buildLinhaMetrica(
                context,
                icone: Icons.hourglass_top_rounded,
                rotulo: 'Em andamento',
                valor: totalEmAndamento.toString(),
              ),
              const SizedBox(height: 10),
              _buildLinhaMetrica(
                context,
                icone: Icons.check_circle_outline,
                rotulo: 'Concluídos',
                valor: totalConcluidos.toString(),
                corIcone: Colors.green,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Painel lateral para telas amplas.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinhaMetrica(
    BuildContext context, {
    required IconData icone,
    required String rotulo,
    required String valor,
    Color? corIcone,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icone, size: 20, color: corIcone ?? theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(rotulo, style: theme.textTheme.bodyMedium)),
        Text(
          valor,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
