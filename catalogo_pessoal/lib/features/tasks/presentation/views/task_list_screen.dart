import 'package:flutter/material.dart';

import 'package:catalogo_pessoal/features/tasks/data/repositories/task_repository.dart';
import 'package:catalogo_pessoal/features/tasks/domain/task.dart';
import 'package:catalogo_pessoal/features/tasks/presentation/view_models/task_list_view_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({required this.repository, super.key});

  final TaskRepository repository;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TaskListViewModel(widget.repository)..start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _showEditor({Task? task}) async {
    final result = await showDialog<_TaskDraft>(
      context: context,
      builder: (_) => _TaskEditorDialog(task: task),
    );
    if (!mounted || result == null) return;

    final saved = task == null
        ? await _viewModel.createTask(result.title)
        : await _viewModel.updateTask(task, result.title, result.isCompleted);
    if (!mounted) return;
    _showResult(saved, task == null ? 'Tarefa criada.' : 'Tarefa atualizada.');
  }

  Future<void> _toggle(Task task, bool completed) async {
    final saved = await _viewModel.toggleTask(task, completed);
    if (!mounted) return;
    _showResult(saved, 'Tarefa atualizada.');
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('A tarefa “${task.title}” será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final deleted = await _viewModel.deleteTask(task);
    if (!mounted) return;
    _showResult(deleted, 'Tarefa excluída.');
  }

  void _showResult(bool success, String successMessage) {
    final message = success
        ? successMessage
        : _viewModel.commandFailure?.publicMessage ??
              'Não foi possível concluir a operação.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        actions: [
          if (_viewModel.isCommandLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _viewModel.isCommandLoading ? null : () => _showEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    ),
  );

  Widget _buildBody() => switch (_viewModel.status) {
    TaskListStatus.loading => const Center(child: CircularProgressIndicator()),
    TaskListStatus.empty => _EmptyTasks(onCreate: () => _showEditor()),
    TaskListStatus.failure => _LoadFailure(
      message:
          _viewModel.loadFailure?.publicMessage ??
          'Não foi possível carregar as tarefas.',
      onRetry: _viewModel.retry,
    ),
    TaskListStatus.success => ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: _viewModel.tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _TaskTile(
        task: _viewModel.tasks[index],
        enabled: !_viewModel.isCommandLoading,
        onToggle: (value) => _toggle(_viewModel.tasks[index], value),
        onEdit: () => _showEditor(task: _viewModel.tasks[index]),
        onDelete: () => _delete(_viewModel.tasks[index]),
      ),
    ),
  };
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.enabled,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: enabled ? (value) => onToggle(value ?? false) : null,
      ),
      title: Text(
        task.title,
        style: task.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(task.isCompleted ? 'Concluída' : 'Pendente'),
      trailing: Wrap(
        children: [
          IconButton(
            tooltip: 'Editar tarefa',
            onPressed: enabled ? onEdit : null,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Excluir tarefa',
            onPressed: enabled ? onDelete : null,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    ),
  );
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa ainda',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Crie uma tarefa para começar sua lista.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Criar tarefa'),
          ),
        ],
      ),
    ),
  );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}

class _TaskDraft {
  const _TaskDraft({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;
}

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog({this.task});

  final Task? task;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _title,
            autofocus: true,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final title = value?.trim() ?? '';
              if (title.isEmpty) return 'Informe o título da tarefa.';
              if (title.length > 120) return 'Use até 120 caracteres.';
              return null;
            },
          ),
          if (widget.task != null)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Concluída'),
              value: _isCompleted,
              onChanged: (value) =>
                  setState(() => _isCompleted = value ?? false),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            _TaskDraft(title: _title.text.trim(), isCompleted: _isCompleted),
          );
        },
        child: const Text('Salvar'),
      ),
    ],
  );
}
