import 'package:catalogo_pessoal/screens/lista_page.dart';
import 'package:catalogo_pessoal/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CatalogoApp());
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo Pessoal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ListaPage(),
    );
  }
}
