import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Única camada de tarefas que importa cloud_firestore.
class FirestoreTaskService {
  FirestoreTaskService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tarefas');

  Stream<List<FirestoreTaskRecord>> watchByOwner(String uid) => _tasks
      .where('ownerId', isEqualTo: uid)
      .orderBy('updatedAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) =>
                  FirestoreTaskRecord(id: document.id, data: document.data()),
            )
            .toList(growable: false),
      )
      .transform(
        StreamTransformer<
          List<FirestoreTaskRecord>,
          List<FirestoreTaskRecord>
        >.fromHandlers(
          handleError: (error, stackTrace, sink) {
            if (error is FirebaseException) {
              sink.addError(TaskServiceException(error.code), stackTrace);
            } else {
              sink.addError(error, stackTrace);
            }
          },
        ),
      );

  Future<void> create({required String title, required String ownerId}) =>
      _run(() async {
        await _tasks.add({
          'titulo': title.trim(),
          'concluida': false,
          'ownerId': ownerId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

  Future<void> update({
    required String id,
    required String title,
    required bool isCompleted,
  }) => _run(
    () => _tasks.doc(id).update({
      'titulo': title.trim(),
      'concluida': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  Future<void> delete(String id) => _run(() => _tasks.doc(id).delete());

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw TaskServiceException(error.code);
    }
  }
}

class FirestoreTaskRecord {
  const FirestoreTaskRecord({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class TaskServiceException implements Exception {
  const TaskServiceException(this.code);

  final String code;
}
