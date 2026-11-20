import 'package:catalogo_pessoal/data/status_item.dart';

class ItemCatalogo {
  final String id;
  final String titulo;
  final String? descricao;
  final String? categoria;
  final StatusItem status;
  final bool favorito;

  /// Base64 reduzido, mantido somente no cache privado do dispositivo.
  /// Imagens nunca são enviadas ao Firestore.
  final String? fotoLocalBase64;

  const ItemCatalogo({
    required this.id,
    required this.titulo,
    this.descricao,
    this.categoria,
    this.status = StatusItem.queroConhecer,
    this.favorito = false,
    this.fotoLocalBase64,
  });

  String get descricaoExibicao {
    final texto = descricao?.trim();
    return texto == null || texto.isEmpty ? 'Sem descrição' : texto;
  }

  String get categoriaExibicao {
    final texto = categoria?.trim();
    return texto == null || texto.isEmpty ? 'Geral' : texto;
  }

  bool get tituloValido => titulo.trim().length >= 3;

  ItemCatalogo copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? categoria,
    StatusItem? status,
    bool? favorito,
    String? fotoLocalBase64,
    bool removerFotoLocal = false,
  }) {
    return ItemCatalogo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      status: status ?? this.status,
      favorito: favorito ?? this.favorito,
      fotoLocalBase64: removerFotoLocal
          ? null
          : fotoLocalBase64 ?? this.fotoLocalBase64,
    );
  }

  Map<String, Object?> toCacheJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'categoria': categoria,
    'status': status.name,
    'favorito': favorito,
    'fotoLocalBase64': fotoLocalBase64,
  };

  factory ItemCatalogo.fromCacheJson(Map<String, dynamic> json) {
    final statusName = json['status'];
    final status = StatusItem.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => throw const FormatException('Status de catálogo inválido.'),
    );
    final id = json['id'];
    final titulo = json['titulo'];
    final descricao = json['descricao'];
    final categoria = json['categoria'];
    final favorito = json['favorito'];
    final fotoLocalBase64 = json['fotoLocalBase64'];
    if (id is! String ||
        titulo is! String ||
        (descricao != null && descricao is! String) ||
        (categoria != null && categoria is! String) ||
        favorito is! bool ||
        (fotoLocalBase64 != null && fotoLocalBase64 is! String)) {
      throw const FormatException('Item em cache fora do contrato.');
    }
    return ItemCatalogo(
      id: id,
      titulo: titulo,
      descricao: descricao as String?,
      categoria: categoria as String?,
      status: status,
      favorito: favorito,
      fotoLocalBase64: fotoLocalBase64 as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemCatalogo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titulo == other.titulo &&
          descricao == other.descricao &&
          categoria == other.categoria &&
          status == other.status &&
          favorito == other.favorito &&
          fotoLocalBase64 == other.fotoLocalBase64;

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    descricao,
    categoria,
    status,
    favorito,
    fotoLocalBase64,
  );

  @override
  String toString() =>
      'ItemCatalogo(id: $id, titulo: $titulo, categoria: $categoria, status: ${status.name}, favorito: $favorito)';
}
