import 'package:flutter/material.dart';

class EstadoVazio extends StatelessWidget {
  final VoidCallback? onAdicionar;
  final String mensagem;

  const EstadoVazio({
    this.onAdicionar,
    this.mensagem = 'Nenhum item cadastrado',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 72,
              color: theme.colorScheme.primary.withAlpha(150),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comece adicionando itens ao seu catálogo pessoal utilizando o botão abaixo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAdicionar != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdicionar,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar primeiro item'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
