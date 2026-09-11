import 'package:catalogo_pessoal/data/itens_iniciais.dart';
import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:catalogo_pessoal/widgets/catalogo_grade.dart';
import 'package:catalogo_pessoal/widgets/resumo_catalogo.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ItemCatalogo> _itens = [...itensIniciais];
  final _tituloController = TextEditingController();

  int get _totalItens => _itens.length;
  int get _totalFavoritos => _itens.where((item) => item.favorito).length;

  void _adicionar(String titulo) {
    final novo = ItemCatalogo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo,
      status: StatusItem.queroConhecer,
    );
    setState(() {
      _itens = [..._itens, novo];
    });
  }

  void _adicionarDigitado() {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) return;
    _adicionar(titulo);
    _tituloController.clear();
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
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Catálogo')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Novo item',
                        hintText: 'Digite o título...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _adicionarDigitado(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _adicionarDigitado,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final grade = CatalogoGrade(
                    itens: _itens,
                    onAlternarFavorito: _alternarFavorito,
                    onRemover: _remover,
                    onMudarStatus: _mudarStatus,
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
