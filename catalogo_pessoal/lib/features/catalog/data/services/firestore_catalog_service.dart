import 'dart:async';

import 'package:catalogo_pessoal/data/status_item.dart';
import 'package:catalogo_pessoal/features/catalog/domain/catalog_failure.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCatalogService {
  FirestoreCatalogService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('itens_catalogo');

  Stream<List<ItemCatalogo>> watchByOwner(String uid) => _items
      .where('ownerId', isEqualTo: uid)
      .orderBy('updatedAt', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => _fromFirestore(document.id, document.data()))
            .toList(growable: false),
      )
      .transform(
        StreamTransformer<List<ItemCatalogo>, List<ItemCatalogo>>.fromHandlers(
          handleError: (error, stackTrace, sink) {
            if (error is FirebaseException) {
              sink.addError(_mapFailure(error.code), stackTrace);
            } else {
              sink.addError(error, stackTrace);
            }
          },
        ),
      );

  Future<ItemCatalogo> create(String uid, ItemCatalogo item) async {
    final reference = _items.doc();
    try {
      await reference
          .set({
            ..._writeableFields(item),
            'ownerId': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 12));
      return item.copyWith(id: reference.id);
    } on FirebaseException catch (error) {
      throw _mapFailure(error.code);
    } on TimeoutException {
      throw const CatalogFailure(CatalogFailureKind.unavailable);
    }
  }

  Future<void> update(String uid, ItemCatalogo item) async {
    try {
      await _items
          .doc(item.id)
          .update({
            ..._writeableFields(item),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 12));
    } on FirebaseException catch (error) {
      throw _mapFailure(error.code);
    } on TimeoutException {
      throw const CatalogFailure(CatalogFailureKind.unavailable);
    }
  }

  Future<void> delete(String uid, String id) async {
    // The explicit UID is checked by the repository/auth gate; rules enforce it
    // again on the server for the document being deleted.
    if (uid.isEmpty) throw const CatalogFailure(CatalogFailureKind.session);
    try {
      await _items.doc(id).delete().timeout(const Duration(seconds: 12));
    } on FirebaseException catch (error) {
      throw _mapFailure(error.code);
    } on TimeoutException {
      throw const CatalogFailure(CatalogFailureKind.unavailable);
    }
  }

  Map<String, Object?> _writeableFields(ItemCatalogo item) => {
    'titulo': item.titulo.trim(),
    'categoria': item.categoria?.trim() ?? '',
    'descricao': item.descricao?.trim() ?? '',
    'status': item.status.name,
    'favorito': item.favorito,
  };

  ItemCatalogo _fromFirestore(String id, Map<String, dynamic> data) {
    final title = data['titulo'];
    final category = data['categoria'];
    final description = data['descricao'];
    final statusName = data['status'];
    final favorite = data['favorito'];
    final status = StatusItem.values.where((value) => value.name == statusName);
    if (title is! String ||
        category is! String ||
        description is! String ||
        status.isEmpty ||
        favorite is! bool) {
      throw const CatalogFailure(CatalogFailureKind.invalidData);
    }
    return ItemCatalogo(
      id: id,
      titulo: title,
      categoria: category,
      descricao: description,
      status: status.first,
      favorito: favorite,
    );
  }

  CatalogFailure _mapFailure(String code) => CatalogFailure(switch (code) {
    'permission-denied' => CatalogFailureKind.permission,
    'unauthenticated' => CatalogFailureKind.session,
    'unavailable' || 'deadline-exceeded' => CatalogFailureKind.unavailable,
    'invalid-argument' => CatalogFailureKind.invalidData,
    _ => CatalogFailureKind.unexpected,
  });
}
