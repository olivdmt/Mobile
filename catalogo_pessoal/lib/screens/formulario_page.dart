import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter/material.dart';

class FormularioPage extends StatefulWidget {
  final ItemCatalogo? itemInicial;

  const FormularioPage({super.key, this.itemInicial});

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
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _categoriaController.dispose();
    _descricaoController.dispose();
    _categoriaFocus.dispose();
    _descricaoFocus.dispose();
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
    );
  }

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
}

// Alias de conveniência
typedef TelaFormulario = FormularioPage;
