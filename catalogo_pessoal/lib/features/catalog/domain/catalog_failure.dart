enum CatalogFailureKind {
  permission,
  session,
  unavailable,
  invalidData,
  unexpected,
}

class CatalogFailure implements Exception {
  const CatalogFailure(this.kind);

  final CatalogFailureKind kind;

  String get publicMessage => switch (kind) {
    CatalogFailureKind.permission =>
      'Sua conta não tem permissão para alterar este item.',
    CatalogFailureKind.session => 'Entre novamente para acessar seu catálogo.',
    CatalogFailureKind.unavailable => 'Não foi possível conectar. Os dados locais continuam disponíveis; tente novamente quando estiver online.',
    CatalogFailureKind.invalidData =>
      'Confira os dados do item e tente novamente.',
    CatalogFailureKind.unexpected =>
      'Não foi possível concluir a operação. Tente novamente.',
  };
}
