import 'package:flutter/material.dart';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/presentation/view_models/auth_session_view_model.dart';
import 'package:catalogo_pessoal/features/auth/presentation/views/sign_in_screen.dart';
import 'package:catalogo_pessoal/features/auth/presentation/views/signed_in_catalog_screen.dart';
import 'package:catalogo_pessoal/features/tasks/data/repositories/task_repository.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    required this.repository,
    required this.taskRepository,
    super.key,
  });

  final AuthRepository repository;
  final TaskRepository taskRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthSessionViewModel _session;

  @override
  void initState() {
    super.initState();
    _session = AuthSessionViewModel(widget.repository)..start();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _session,
    builder: (context, _) => switch (_session.status) {
      SessionStatus.checking => const _SessionSplash(),
      SessionStatus.signedOut => SignInScreen(repository: widget.repository),
      SessionStatus.signedIn =>
        _session.user == null
            ? const _SessionSplash()
            : SignedInCatalogScreen(
                repository: widget.repository,
                taskRepository: widget.taskRepository,
                user: _session.user!,
              ),
    },
  );
}

class _SessionSplash extends StatelessWidget {
  const _SessionSplash();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verificando sessão...'),
        ],
      ),
    ),
  );
}
