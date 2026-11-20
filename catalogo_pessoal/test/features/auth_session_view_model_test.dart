import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/domain/app_user.dart';
import 'package:catalogo_pessoal/features/auth/presentation/view_models/auth_session_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores a session from the repository and reacts to logout', () async {
    final user = AppUser(
      id: 'fake-user-1',
      email: 'aluno@example.com',
      emailVerified: false,
    );
    final repository = FakeAuthRepository(initialUser: user);
    final viewModel = AuthSessionViewModel(repository);
    addTearDown(viewModel.dispose);
    addTearDown(repository.dispose);

    expect(viewModel.status, SessionStatus.checking);
    viewModel.start();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.status, SessionStatus.signedIn);
    expect(viewModel.user?.id, user.id);

    await repository.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.status, SessionStatus.signedOut);
    expect(viewModel.user, isNull);
  });
}
