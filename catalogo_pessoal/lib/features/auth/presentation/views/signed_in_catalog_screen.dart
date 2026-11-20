import 'package:flutter/material.dart';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/domain/app_user.dart';
import 'package:catalogo_pessoal/features/auth/presentation/view_models/auth_form_view_model.dart';
import 'package:catalogo_pessoal/features/tasks/data/repositories/task_repository.dart';
import 'package:catalogo_pessoal/features/tasks/presentation/views/task_list_screen.dart';
import 'package:catalogo_pessoal/screens/lista_page.dart';

class SignedInCatalogScreen extends StatefulWidget {
  const SignedInCatalogScreen({
    required this.repository,
    required this.taskRepository,
    required this.user,
    super.key,
  });

  final AuthRepository repository;
  final TaskRepository taskRepository;
  final AppUser user;

  @override
  State<SignedInCatalogScreen> createState() => _SignedInCatalogScreenState();
}

class _SignedInCatalogScreenState extends State<SignedInCatalogScreen> {
  late final AuthFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthFormViewModel(widget.repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action,
    String successMessage,
  ) async {
    await action();
    if (!mounted) return;
    final message = _viewModel.failure?.publicMessage ?? successMessage;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTasks() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskListScreen(repository: widget.taskRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => ListaPage(
      accountEmail: widget.user.email,
      accountActions: [
        PopupMenuButton<String>(
          tooltip: 'Conta e tarefas',
          enabled: !_viewModel.isLoading,
          onSelected: (value) {
            switch (value) {
              case 'tasks':
                _openTasks();
                break;
              case 'verify':
                _run(
                  _viewModel.sendVerificationEmail,
                  'Enviamos uma mensagem de verificação, se necessário.',
                );
                break;
              case 'refresh':
                _run(
                  _viewModel.reloadCurrentUser,
                  'Status do e-mail atualizado.',
                );
                break;
              case 'signOut':
                _run(_viewModel.signOut, 'Sessão encerrada.');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'tasks', child: Text('Minhas tarefas')),
            if (!widget.user.emailVerified) ...[
              const PopupMenuItem(
                value: 'verify',
                child: Text('Enviar verificação de e-mail'),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Atualizar status do e-mail'),
              ),
            ],
            const PopupMenuItem(value: 'signOut', child: Text('Sair da conta')),
          ],
          icon: _viewModel.isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.account_circle_outlined),
        ),
      ],
    ),
  );
}
