import 'dart:convert';

import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/features/books/data/book_suggestion.dart';
import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';
import 'package:catalogo_pessoal/features/books/presentation/view_models/book_search_view_model.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/catalog_photo_picker.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class FormularioPage extends StatefulWidget {
  final ItemCatalogo? itemInicial;
  final BookSearchRepository? bookSearchRepository;
  final CatalogPhotoPicker? photoPicker;

  const FormularioPage({
    super.key,
    this.itemInicial,
    this.bookSearchRepository,
    this.photoPicker,
  });

  bool get editando => itemInicial != null;

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _descricaoController;

  final _categoriaFocus = FocusNode();
  final _descricaoFocus = FocusNode();

  late StatusItem _status;
  late bool _favorito;
  String? _fotoLocalBase64;
  BookSearchViewModel? _bookSearchViewModel;
  bool _submetendo = false;

  @override
  void initState() {
    super.initState();
    final item = widget.itemInicial;
    _tituloController = TextEditingController(text: item?.titulo ?? '');
    _categoriaController = TextEditingController(text: item?.categoria ?? '');
    _descricaoController = TextEditingController(text: item?.descricao ?? '');
    _status = item?.status ?? StatusItem.queroConhecer;
    _favorito = item?.favorito ?? false;
    _fotoLocalBase64 = item?.fotoLocalBase64;
    final searchRepository = widget.bookSearchRepository;
    if (searchRepository != null) {
      _bookSearchViewModel = BookSearchViewModel(searchRepository);
    }
    if (!kIsWeb && widget.photoPicker != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recoverLostPhoto());
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _categoriaController.dispose();
    _descricaoController.dispose();
    _categoriaFocus.dispose();
    _descricaoFocus.dispose();
    _bookSearchViewModel?.dispose();
    super.dispose();
  }

  String? _validarTitulo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Informe o título';
    }
    if (texto.length < 3) {
      return 'Use pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validarCategoria(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Informe a categoria';
    }
    if (texto.length < 3) {
      return 'Use pelo menos 3 caracteres';
    }
    return null;
  }

  ItemCatalogo _construirResultado() {
    final inicial = widget.itemInicial;
    return ItemCatalogo(
      id: inicial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      categoria: _categoriaController.text.trim(),
      descricao: _descricaoController.text.trim(),
      status: _status,
      favorito: _favorito,
      fotoLocalBase64: _fotoLocalBase64,
    );
  }

  Future<void> _recoverLostPhoto() async {
    try {
      final photo = await widget.photoPicker?.retrieveLostPhoto();
      if (mounted && photo != null) setState(() => _fotoLocalBase64 = photo);
    } on Object {
      // A recuperação da câmera é uma conveniência; mantém o formulário aberto.
    }
  }

  Future<void> _choosePhoto() async {
    try {
      final photo = await widget.photoPicker?.chooseFromGallery();
      if (mounted && photo != null) setState(() => _fotoLocalBase64 = photo);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a galeria.')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await widget.photoPicker?.takePhoto();
      if (mounted && photo != null) setState(() => _fotoLocalBase64 = photo);
    } on CatalogPhotoPermissionDenied {
      if (!mounted) return;
      final chooseGallery = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissão da câmera negada'),
          content: const Text(
            'A câmera não foi acessada. Você pode escolher uma imagem da galeria ou continuar sem foto.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continuar sem foto'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Escolher da galeria'),
            ),
          ],
        ),
      );
      if (chooseGallery == true) await _choosePhoto();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir a câmera. Você pode salvar sem foto.',
          ),
        ),
      );
    }
  }

  Future<void> _searchBook() async {
    final viewModel = _bookSearchViewModel;
    if (viewModel == null) return;
    await viewModel.search(_tituloController.text);
    if (!mounted) return;
    final selected = await showModalBottomSheet<BookSuggestion>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) => SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: _buildBookResults(context, viewModel),
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _tituloController.text = selected.title;
      if (_categoriaController.text.trim().isEmpty) {
        _categoriaController.text = 'Livro';
      }
      _descricaoController.text = selected.description;
    });
  }

  Widget _buildBookResults(
    BuildContext context,
    BookSearchViewModel viewModel,
  ) => switch (viewModel.status) {
    BookSearchStatus.loading => const Center(
      child: CircularProgressIndicator(),
    ),
    BookSearchStatus.failure => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.errorMessage ?? 'Serviço indisponível.'),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => viewModel.search(_tituloController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
            const Text('Você ainda pode preencher os dados manualmente.'),
          ],
        ),
      ),
    ),
    BookSearchStatus.empty => const Center(
      child: Text('Nenhum livro encontrado. Preencha os dados manualmente.'),
    ),
    BookSearchStatus.success => ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = viewModel.results[index];
        return ListTile(
          leading: book.coverUrl == null
              ? const Icon(Icons.menu_book_outlined)
              : Image.network(
                  book.coverUrl!,
                  width: 44,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.menu_book_outlined),
                ),
          title: Text(book.title),
          subtitle: Text(
            [
              if (book.authors.isNotEmpty) book.authors.join(', '),
              if (book.firstPublishYear != null) '${book.firstPublishYear}',
            ].join(' • '),
          ),
          onTap: () => Navigator.pop(context, book),
        );
      },
    ),
    BookSearchStatus.idle => const SizedBox.shrink(),
  };

  void _salvar() {
    if (_submetendo) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _submetendo = true;
    Navigator.pop(context, _construirResultado());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar Item' : 'Novo Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('titulo'),
                  controller: _tituloController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    hintText: 'Ex.: O Hobbit',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: _validarTitulo,
                  onFieldSubmitted: (_) => _categoriaFocus.requestFocus(),
                ),
                if (_bookSearchViewModel != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _searchBook,
                      icon: const Icon(Icons.travel_explore),
                      label: const Text('Buscar dados do livro'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('categoria'),
                  controller: _categoriaController,
                  focusNode: _categoriaFocus,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    hintText: 'Ex.: Fantasia, Tecnologia',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: _validarCategoria,
                  onFieldSubmitted: (_) => _descricaoFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('descricao'),
                  controller: _descricaoController,
                  focusNode: _descricaoFocus,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Breve resumo ou anotações...',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StatusItem>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status no catálogo',
                    prefixIcon: Icon(Icons.hourglass_empty_rounded),
                  ),
                  items: [
                    for (final status in StatusItem.values)
                      DropdownMenuItem(
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
                  onChanged: (novoStatus) {
                    if (novoStatus != null) {
                      setState(() => _status = novoStatus);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    80,
                  ),
                  child: SwitchListTile(
                    title: const Text('Marcar como Favorito'),
                    subtitle: Text(
                      _favorito ? 'Item destacado na coleção' : 'Item comum',
                      style: theme.textTheme.bodySmall,
                    ),
                    secondary: Icon(
                      _favorito
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _favorito ? Colors.amber[700] : null,
                    ),
                    value: _favorito,
                    onChanged: (val) => setState(() => _favorito = val),
                  ),
                ),
                if (widget.photoPicker != null) ...[
                  const SizedBox(height: 16),
                  _buildLocalPhotoCard(theme),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('salvar_button'),
                        onPressed: _submetendo ? null : _salvar,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.itemInicial == null
                              ? 'Criar item'
                              : 'Salvar alterações',
                        ),
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

  Widget _buildLocalPhotoCard(ThemeData theme) => Card(
    elevation: 0,
    color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foto da capa', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'A foto fica apenas no cache privado deste dispositivo; não é enviada ao Firestore. Você pode salvar sem foto.',
            style: theme.textTheme.bodySmall,
          ),
          if (_fotoLocalBase64?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(_fotoLocalBase64!),
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (!kIsWeb)
                OutlinedButton.icon(
                  onPressed: _submetendo ? null : _takePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Tirar foto'),
                ),
              OutlinedButton.icon(
                onPressed: _submetendo ? null : _choosePhoto,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
              if (_fotoLocalBase64?.isNotEmpty == true)
                TextButton(
                  onPressed: () => setState(() => _fotoLocalBase64 = ''),
                  child: const Text('Remover foto'),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Alias de conveniência
typedef TelaFormulario = FormularioPage;
