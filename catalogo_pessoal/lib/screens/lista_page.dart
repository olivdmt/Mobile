import 'package:catalogo_pessoal/data/itens_iniciais.dart';
import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/catalog_photo_picker.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/detalhe_page.dart';
import 'package:catalogo_pessoal/screens/formulario_page.dart';
import 'package:catalogo_pessoal/widgets/catalogo_grade.dart';
import 'package:catalogo_pessoal/widgets/resumo_catalogo.dart';
import 'package:flutter/material.dart';

class ListaPage extends StatefulWidget {
  final List<ItemCatalogo>? itens;
  final String? accountEmail;
  final List<Widget> accountActions;
  final Future<bool> Function(ItemCatalogo item, {required bool isNew})?
  onSaveItem;
  final Future<bool> Function(ItemCatalogo item)? onDeleteItem;
  final BookSearchRepository? bookSearchRepository;
  final CatalogPhotoPicker? photoPicker;
  final bool isLoading;
  final bool isCommandLoading;
  final bool showingLocalCache;
  final DateTime? cacheSavedAt;
  final String? loadError;
  final String? commandError;
  final Future<void> Function()? onRetry;

  const ListaPage({
    this.itens,
    this.accountEmail,
    this.accountActions = const [],
    this.onSaveItem,
    this.onDeleteItem,
    this.bookSearchRepository,
    this.photoPicker,
    this.isLoading = false,
    this.isCommandLoading = false,
    this.showingLocalCache = false,
    this.cacheSavedAt,
    this.loadError,
    this.commandError,
    this.onRetry,
    super.key,
  });

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  late List<ItemCatalogo> _itens;

  @override
  void initState() {
    super.initState();
    _itens = widget.itens != null ? [...widget.itens!] : [...itensIniciais];
  }

  @override
  void didUpdateWidget(covariant ListaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itens != null && !identical(widget.itens, oldWidget.itens)) {
      _itens = [...widget.itens!];
    }
  }

  int get _totalItens => _itens.length;
  int get _totalFavoritos => _itens.where((item) => item.favorito).length;
  int get _totalConcluidos =>
      _itens.where((item) => item.status == StatusItem.concluido).length;
  int get _totalEmAndamento =>
      _itens.where((item) => item.status == StatusItem.emAndamento).length;

  void _aplicarResultado(ItemCatalogo resultado) {
    final indice = _itens.indexWhere((item) => item.id == resultado.id);
    _itens = indice == -1
        ? [..._itens, resultado]
        : [
            for (final item in _itens)
              item.id == resultado.id ? resultado : item,
          ];
  }

  ItemCatalogo? _findItem(String id) {
    for (final item in _itens) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _abrirCriacao() async {
    final resultado = await Navigator.push<ItemCatalogo>(
      context,
      MaterialPageRoute<ItemCatalogo>(
        builder: (_) => FormularioPage(
          bookSearchRepository: widget.bookSearchRepository,
          photoPicker: widget.photoPicker,
        ),
      ),
    );

    if (!mounted || resultado == null) return;
    final saved = await _persistir(resultado, isNew: true);
    _showCommandResult(saved, 'Item salvo.');
  }

  Future<void> _abrirDetalhe(ItemCatalogo item) async {
    final resultado = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (_) => DetalhePage(
          item: item,
          bookSearchRepository: widget.bookSearchRepository,
          photoPicker: widget.photoPicker,
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    if (resultado is Map && resultado['acao'] == 'excluir') {
      final id = resultado['id'] as String;
      final item = _findItem(id);
      if (item == null) return;
      final removed = await _excluir(item);
      _showCommandResult(removed, 'Item removido.');
    } else if (resultado is ItemCatalogo) {
      final saved = await _persistir(resultado, isNew: false);
      _showCommandResult(saved, 'Alterações salvas.');
    }
  }

  Future<void> _alternarFavorito(String id) async {
    final item = _findItem(id);
    if (item == null) return;
    final saved = await _persistir(
      item.copyWith(favorito: !item.favorito),
      isNew: false,
    );
    if (widget.onSaveItem != null) {
      _showCommandResult(saved, 'Favorito atualizado.');
    }
  }

  Future<void> _mudarStatus(String id, StatusItem novoStatus) async {
    final item = _findItem(id);
    if (item == null) return;
    final saved = await _persistir(
      item.copyWith(status: novoStatus),
      isNew: false,
    );
    if (widget.onSaveItem != null) {
      _showCommandResult(saved, 'Status atualizado.');
    }
  }

  Future<void> _remover(String id) async {
    final item = _findItem(id);
    if (item == null) return;
    final removed = await _excluir(item);
    _showCommandResult(removed, 'Item removido.');
  }

  Future<bool> _persistir(ItemCatalogo item, {required bool isNew}) async {
    final save = widget.onSaveItem;
    if (save != null) return save(item, isNew: isNew);
    setState(() => _aplicarResultado(item));
    return true;
  }

  Future<bool> _excluir(ItemCatalogo item) async {
    final delete = widget.onDeleteItem;
    if (delete != null) return delete(item);
    setState(() => _removerLocal(item.id));
    return true;
  }

  void _removerLocal(String id) {
    setState(() => _itens = _itens.where((item) => item.id != id).toList());
  }

  void _showCommandResult(bool success, String successMessage) {
    if (!mounted) return;
    final message = success
        ? successMessage
        : widget.commandError ?? 'Não foi possível salvar. Tente novamente.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildLoadFailure() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 52),
          const SizedBox(height: 12),
          Text(widget.loadError ?? 'Não foi possível carregar o catálogo.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );

  Widget _buildCacheBanner() {
    final savedAt = widget.cacheSavedAt?.toLocal();
    final time = savedAt == null
        ? ''
        : ' • ${savedAt.day.toString().padLeft(2, '0')}/${savedAt.month.toString().padLeft(2, '0')} ${savedAt.hour.toString().padLeft(2, '0')}:${savedAt.minute.toString().padLeft(2, '0')}';
    return MaterialBanner(
      leading: const Icon(Icons.offline_bolt_outlined),
      content: Text(
        'Dados do cache local$time. Alterações precisam de conexão.',
      ),
      actions: [
        TextButton(onPressed: widget.onRetry, child: const Text('Sincronizar')),
      ],
    );
  }

  Widget _buildErrorBanner() => MaterialBanner(
    leading: const Icon(Icons.sync_problem_outlined),
    content: Text(widget.loadError ?? 'Não foi possível atualizar o catálogo.'),
    actions: [
      TextButton(
        onPressed: widget.onRetry,
        child: const Text('Tentar novamente'),
      ),
    ],
  );

  Widget _buildCatalogBody(BoxConstraints constraints) {
    if (widget.isLoading && _itens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.loadError != null && _itens.isEmpty) return _buildLoadFailure();

    final grade = CatalogoGrade(
      itens: _itens,
      onAbrirDetalhe: _abrirDetalhe,
      onAlternarFavorito: widget.isCommandLoading ? null : _alternarFavorito,
      onRemover: widget.isCommandLoading ? null : _remover,
      onMudarStatus: widget.isCommandLoading ? null : _mudarStatus,
      onAdicionar: widget.isCommandLoading ? null : _abrirCriacao,
    );
    if (constraints.maxWidth < 900) return grade;
    return Row(
      children: [
        Expanded(child: grade),
        SizedBox(
          width: 320,
          child: ResumoCatalogo(
            totalItens: _totalItens,
            totalFavoritos: _totalFavoritos,
            totalConcluidos: _totalConcluidos,
            totalEmAndamento: _totalEmAndamento,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Catálogo Pessoal'),
            if (widget.accountEmail case final email?)
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
        actions: [
          ...widget.accountActions,
          IconButton(
            tooltip: 'Criar novo item',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: widget.isCommandLoading ? null : _abrirCriacao,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showingLocalCache) _buildCacheBanner(),
            if (widget.loadError != null && _itens.isNotEmpty)
              _buildErrorBanner(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    _buildCatalogBody(constraints),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.isCommandLoading ? null : _abrirCriacao,
        icon: const Icon(Icons.add),
        label: const Text('Novo Item'),
      ),
    );
  }
}

// Alias de compatibilidade
typedef HomeScreen = ListaPage;
