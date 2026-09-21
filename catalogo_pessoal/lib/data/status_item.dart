import 'package:flutter/material.dart';

enum StatusItem {
  queroConhecer('Quero Conhecer', Icons.bookmark_outline),
  emAndamento('Em Andamento', Icons.hourglass_top_rounded),
  concluido('Concluído', Icons.check_circle_outline);

  final String rotulo;
  final IconData icone;

  const StatusItem(this.rotulo, this.icone);
}
