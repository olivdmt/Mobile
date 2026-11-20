import 'dart:async';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/tasks/data/services/firestore_task_service.dart';
import 'package:catalogo_pessoal/features/tasks/domain/task.dart';
import 'package:catalogo_pessoal/features/tasks/domain/task_failure.dart';

abstract interface class TaskRepository {
  Stream<List<Task>> watchMine();
  Future<void> createTask(String title);
  Future<void> updateTask({
    required String id,
    required String title,
    required bool isCompleted,
  });
  Future<void> deleteTask(String id);
}

class FirestoreTaskRepository implements TaskRepository {
  const FirestoreTaskRepository(this._service, this._authRepository);

  final FirestoreTaskService _service;
  final AuthRepository _authRepository;

  @override
  Stream<List<Task>> watchMine() {
    final uid = _requireUid();
    return _service
        .watchByOwner(uid)
        .map((records) => records.map(_toDomain).toList(growable: false))
        .transform(
          StreamTransformer<List<Task>, List<Task>>.fromHandlers(
            handleError: (error, stackTrace, sink) =>
                sink.addError(_mapFailure(error), stackTrace),
          ),
        );
  }

  @override
  Future<void> createTask(String title) async {
    final normalized = title.trim();
    _validateTitle(normalized);
    await _run(
      () => _service.create(title: normalized, ownerId: _requireUid()),
    );
  }

  @override
  Future<void> updateTask({
    required String id,
    required String title,
    required bool isCompleted,
  }) async {
    final normalized = title.trim();
    _validateTitle(normalized);
    _requireUid();
    await _run(
      () =>
          _service.update(id: id, title: normalized, isCompleted: isCompleted),
    );
  }

  @override
  Future<void> deleteTask(String id) {
    _requireUid();
    return _run(() => _service.delete(id));
  }

  String _requireUid() {
    final uid = _authRepository.currentUserId;
    if (uid == null || uid.isEmpty) {
      throw const TaskFailure(TaskFailureKind.session);
    }
    return uid;
  }

  void _validateTitle(String title) {
    if (title.isEmpty || title.length > 120) {
      throw const TaskFailure(TaskFailureKind.invalidData);
    }
  }

  Task _toDomain(FirestoreTaskRecord record) {
    final title = record.data['titulo'];
    final completed = record.data['concluida'];
    final ownerId = record.data['ownerId'];
    if (title is! String ||
        title.trim().isEmpty ||
        completed is! bool ||
        ownerId is! String ||
        ownerId.isEmpty) {
      throw const FormatException('Documento de tarefa fora do contrato.');
    }
    return Task(
      id: record.id,
      title: title,
      isCompleted: completed,
      ownerId: ownerId,
    );
  }

  Future<void> _run(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  TaskFailure _mapFailure(Object error) {
    if (error is TaskFailure) return error;
    if (error is FormatException) {
      return const TaskFailure(TaskFailureKind.invalidData);
    }
    if (error is TaskServiceException) {
      return TaskFailure(switch (error.code) {
        'permission-denied' => TaskFailureKind.permission,
        'unauthenticated' => TaskFailureKind.session,
        'unavailable' || 'deadline-exceeded' => TaskFailureKind.unavailable,
        'not-found' => TaskFailureKind.notFound,
        _ => TaskFailureKind.unexpected,
      });
    }
    return const TaskFailure(TaskFailureKind.unexpected);
  }
}
