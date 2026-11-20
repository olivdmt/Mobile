enum AuthFailureKind {
  invalidInput,
  weakPassword,
  invalidCredential,
  rateLimited,
  network,
  emailInUse,
  noSession,
  unexpected,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthFailureKind kind;

  String get publicMessage => switch (kind) {
    AuthFailureKind.invalidInput => 'Confira o e-mail informado.',
    AuthFailureKind.weakPassword =>
      'Use uma senha com pelo menos 6 caracteres.',
    AuthFailureKind.invalidCredential =>
      'Não foi possível entrar. Confira os dados e tente novamente.',
    AuthFailureKind.rateLimited =>
      'Muitas tentativas. Aguarde um pouco e tente novamente.',
    AuthFailureKind.network =>
      'Não foi possível conectar. Verifique sua conexão e tente novamente.',
    AuthFailureKind.emailInUse => 'Não foi possível concluir o cadastro. Tente entrar ou recuperar o acesso.',
    AuthFailureKind.noSession => 'Sua sessão não está ativa. Entre novamente.',
    AuthFailureKind.unexpected =>
      'Não foi possível concluir a operação. Tente novamente mais tarde.',
  };
}
