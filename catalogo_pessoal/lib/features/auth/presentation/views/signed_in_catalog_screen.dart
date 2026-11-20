import 'package:flutter/material.dart';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/domain/app_user.dart';
import 'package:catalogo_pessoal/features/auth/presentation/view_models/auth_form_view_model.dart';
import 'package:catalogo_pessoal/features/tasks/data/repositories/task_repository.dart';
import 'package:catalogo_pessoal/features/tasks/presentation/views/task_list_screen.dart';
import 'package:catalogo_pessoal/screens/lista_page.dart';
import 'package:catalogo_pessoal/features/catalog/data/repositories/catalog_repository.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/catalog_photo_picker.dart';
import 'package:catalogo_pessoal/features/catalog/presentation/view_models/catalog_view_model.dart';
import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';

class SignedInCatalogScreen extends StatefulWidget {
  const SignedInCatalogScreen({
    required this.repository,
    required this.taskRepository,
    required this.catalogRepository,
    required this.bookSearchRepository,
    required this.photoPicker,
    required this.user,
    super.key,
  });

  final AuthRepository repository;
  final TaskRepository taskRepository;
  final CatalogRepository catalogRepository;
  final BookSearchRepository bookSearchRepository;
  final CatalogPhotoPicker photoPicker;
  final AppUser user;

  @override
  State<SignedInCatalogScreen> createState() => _SignedInCatalogScreenState();
}

class _SignedInCatalogScreenState extends State<SignedInCatalogScreen> {
  late final AuthFormViewModel _viewModel;
  late final CatalogViewModel _catalog;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthFormViewModel(widget.repository);
    _catalog = CatalogViewModel(widget.catalogRepository, widget.user.id)
      ..start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _catalog.dispose();
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

  Future<void> _signOut() async {
    try {
      await _catalog.clearPrivateCache();
    } on Object {
      // Logout must remain available if local cache cleanup fails.
    } finally {
      await _run(_viewModel.signOut, 'Sessão encerrada.');
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_viewModel, _catalog]),
    builder: (context, _) => ListaPage(
      itens: _catalog.items,
      isLoading:
          _catalog.status == CatalogStatus.loading && _catalog.items.isEmpty,
      isCommandLoading: _catalog.isCommandLoading,
      showingLocalCache: _catalog.isShowingLocalData,
      cacheSavedAt: _catalog.savedAt,
      loadError: _catalog.loadFailure?.publicMessage,
      commandError: _catalog.commandFailure?.publicMessage,
      onRetry: _catalog.retry,
      onSaveItem: (item, {required isNew}) => _catalog.save(item, isNew: isNew),
      onDeleteItem: _catalog.delete,
      bookSearchRepository: widget.bookSearchRepository,
      photoPicker: widget.photoPicker,
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
                _signOut();
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
