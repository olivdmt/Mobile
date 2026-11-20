import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:catalogo_pessoal/features/tasks/data/repositories/task_repository.dart';
import 'package:catalogo_pessoal/features/tasks/domain/task.dart';
import 'package:catalogo_pessoal/features/tasks/domain/task_failure.dart';

enum TaskListStatus { loading, empty, success, failure }

class TaskListViewModel extends ChangeNotifier {
  TaskListViewModel(this._repository);

  final TaskRepository _repository;
  StreamSubscription<List<Task>>? _subscription;
  bool _disposed = false;

  TaskListStatus status = TaskListStatus.loading;
  List<Task> tasks = const [];
  TaskFailure? loadFailure;
  TaskFailure? commandFailure;
  bool isCommandLoading = false;

  void start() {
    if (_subscription != null || _disposed) return;
    status = TaskListStatus.loading;
    _notify();
    try {
      _subscription = _repository.watchMine().listen(
        (items) {
          tasks = items;
          status = items.isEmpty
              ? TaskListStatus.empty
              : TaskListStatus.success;
          loadFailure = null;
          _notify();
        },
        onError: (Object error) {
          loadFailure = error is TaskFailure
              ? error
              : const TaskFailure(TaskFailureKind.unexpected);
          status = TaskListStatus.failure;
          _notify();
        },
      );
    } catch (error) {
      loadFailure = error is TaskFailure
          ? error
          : const TaskFailure(TaskFailureKind.unexpected);
      status = TaskListStatus.failure;
      _notify();
    }
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    _subscription = null;
    start();
  }

  Future<bool> createTask(String title) =>
      _runCommand(() => _repository.createTask(title));

  Future<bool> updateTask(Task task, String title, bool isCompleted) =>
      _runCommand(
        () => _repository.updateTask(
          id: task.id,
          title: title,
          isCompleted: isCompleted,
        ),
      );

  Future<bool> toggleTask(Task task, bool isCompleted) =>
      updateTask(task, task.title, isCompleted);

  Future<bool> deleteTask(Task task) =>
      _runCommand(() => _repository.deleteTask(task.id));

  Future<bool> _runCommand(Future<void> Function() command) async {
    if (isCommandLoading || _disposed) return false;
    isCommandLoading = true;
    commandFailure = null;
    _notify();
    try {
      await command();
      return true;
    } catch (error) {
      commandFailure = error is TaskFailure
          ? error
          : const TaskFailure(TaskFailureKind.unexpected);
      return false;
    } finally {
      isCommandLoading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
