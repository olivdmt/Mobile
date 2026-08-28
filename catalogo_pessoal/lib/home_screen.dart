import 'package:catalogo_pessoal/data/itens_iniciais.dart';
import 'package:catalogo_pessoal/widgets/catalogo_grade.dart';
import 'package:catalogo_pessoal/widgets/resumo_catalogo.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Catálogo'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final grade = CatalogoGrade(itens: itensIniciais);

            if (constraints.maxWidth < 900) {
              return grade;
            }

            return Row(
              children: [
                Expanded(child: grade),
                const SizedBox(
                  width: 320,
                  child: ResumoCatalogo(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
