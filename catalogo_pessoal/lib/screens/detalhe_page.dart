import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/formulario_page.dart';
import 'package:flutter/material.dart';

class DetalhePage extends StatefulWidget {
  final ItemCatalogo item;

  const DetalhePage({required this.item, super.key});

  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  late ItemCatalogo _itemAtual;

  @override
  void initState() {
    super.initState();
    _itemAtual = widget.item;
  }

  Future<void> _abrirEdicao() async {
    final editado = await Navigator.push<ItemCatalogo>(
      context,
      MaterialPageRoute<ItemCatalogo>(
        builder: (_) => FormularioPage(itemInicial: _itemAtual),
      ),
    );

    if (!mounted || editado == null) return;
    setState(() => _itemAtual = editado);
  }

  void _alternarFavorito() {
    setState(() {
      _itemAtual = _itemAtual.copyWith(favorito: !_itemAtual.favorito);
    });
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text(
          'Deseja realmente excluir "${_itemAtual.titulo}" do catálogo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;
    Navigator.pop(context, {'acao': 'excluir', 'id': _itemAtual.id});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _itemAtual);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_itemAtual.titulo),
          actions: [
            IconButton(
              tooltip: _itemAtual.favorito
                  ? 'Remover dos favoritos'
                  : 'Favoritar',
              icon: Icon(
                _itemAtual.favorito
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: _itemAtual.favorito ? Colors.amber[300] : null,
              ),
              onPressed: _alternarFavorito,
            ),
            IconButton(
              tooltip: 'Editar item',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _abrirEdicao,
            ),
            IconButton(
              tooltip: 'Excluir item',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmarExclusao,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _itemAtual.titulo,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _itemAtual.categoriaExibicao,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_itemAtual.favorito)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withAlpha(120),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber[800],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Favorito',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.amber[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withAlpha(100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _itemAtual.status.icone,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Situação atual',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _itemAtual.status.rotulo,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Descrição e Notas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(60),
                    ),
                  ),
                  child: Text(
                    _itemAtual.descricaoExibicao,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context, _itemAtual),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _abrirEdicao,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Alias de conveniência
typedef TelaDetalhe = DetalhePage;
