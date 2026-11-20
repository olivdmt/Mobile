enum TaskFailureKind {
  session,
  permission,
  unavailable,
  notFound,
  invalidData,
  unexpected,
}

class TaskFailure implements Exception {
  const TaskFailure(this.kind);

  final TaskFailureKind kind;

  String get publicMessage => switch (kind) {
    TaskFailureKind.session => 'Sua sessão expirou. Entre novamente.',
    TaskFailureKind.permission => 'Não foi possível acessar esta tarefa.',
    TaskFailureKind.unavailable =>
      'O serviço está indisponível. Verifique a conexão e tente novamente.',
    TaskFailureKind.notFound => 'Esta tarefa não está mais disponível.',
    TaskFailureKind.invalidData => 'Uma tarefa contém dados inválidos.',
    TaskFailureKind.unexpected =>
      'Não foi possível concluir a operação. Tente novamente.',
  };
}
