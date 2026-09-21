import 'package:catalogo_pessoal/data/itens_iniciais.dart';
import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/screens/detalhe_page.dart';
import 'package:catalogo_pessoal/screens/formulario_page.dart';
import 'package:catalogo_pessoal/widgets/catalogo_grade.dart';
import 'package:catalogo_pessoal/widgets/resumo_catalogo.dart';
import 'package:flutter/material.dart';

class ListaPage extends StatefulWidget {
  final List<ItemCatalogo>? itens;

  const ListaPage({this.itens, super.key});

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

  Future<void> _abrirCriacao() async {
    final resultado = await Navigator.push<ItemCatalogo>(
      context,
      MaterialPageRoute<ItemCatalogo>(builder: (_) => const FormularioPage()),
    );

    if (!mounted || resultado == null) return;

    setState(() => _aplicarResultado(resultado));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Item salvo.')));
  }

  Future<void> _abrirDetalhe(ItemCatalogo item) async {
    final resultado = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(builder: (_) => DetalhePage(item: item)),
    );

    if (!mounted || resultado == null) return;

    if (resultado is Map && resultado['acao'] == 'excluir') {
      _remover(resultado['id'] as String);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item removido.')));
    } else if (resultado is ItemCatalogo) {
      setState(() => _aplicarResultado(resultado));
    }
  }

  void _alternarFavorito(String id) {
    setState(() {
      _itens = [
        for (final item in _itens)
          if (item.id == id) item.copyWith(favorito: !item.favorito) else item,
      ];
    });
  }

  void _mudarStatus(String id, StatusItem novoStatus) {
    setState(() {
      _itens = [
        for (final item in _itens)
          if (item.id == id) item.copyWith(status: novoStatus) else item,
      ];
    });
  }

  void _remover(String id) {
    setState(() {
      _itens = _itens.where((item) => item.id != id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo Pessoal'),
        actions: [
          IconButton(
            tooltip: 'Criar novo item',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _abrirCriacao,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final grade = CatalogoGrade(
              itens: _itens,
              onAbrirDetalhe: _abrirDetalhe,
              onAlternarFavorito: _alternarFavorito,
              onRemover: _remover,
              onMudarStatus: _mudarStatus,
              onAdicionar: _abrirCriacao,
            );

            if (constraints.maxWidth < 900) {
              return grade;
            }

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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCriacao,
        icon: const Icon(Icons.add),
        label: const Text('Novo Item'),
      ),
    );
  }
}

// Alias de compatibilidade
typedef HomeScreen = ListaPage;
