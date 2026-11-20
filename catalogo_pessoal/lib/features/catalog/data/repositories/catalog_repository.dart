import 'dart:async';

import 'package:catalogo_pessoal/features/catalog/data/services/firestore_catalog_service.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/local_catalog_cache.dart';
import 'package:catalogo_pessoal/features/catalog/domain/catalog_failure.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';

enum CatalogDataSource { localCache, firestore }

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.items,
    required this.source,
    this.savedAt,
  });

  final List<ItemCatalogo> items;
  final CatalogDataSource source;
  final DateTime? savedAt;
}

abstract interface class CatalogRepository {
  Stream<CatalogSnapshot> watchMine(String uid);
  Future<ItemCatalogo> create(String uid, ItemCatalogo item);
  Future<void> update(String uid, ItemCatalogo item);
  Future<void> delete(String uid, String id);
  Future<void> clearCache(String uid);
}

class FirestoreCatalogRepository implements CatalogRepository {
  const FirestoreCatalogRepository(this._service, this._cache);

  final FirestoreCatalogService _service;
  final LocalCatalogCache _cache;

  @override
  Stream<CatalogSnapshot> watchMine(String uid) async* {
    _requireUid(uid);
    CachedCatalog? cached;
    try {
      cached = await _cache.read(uid);
      if (cached != null) {
        yield CatalogSnapshot(
          items: cached.items,
          source: CatalogDataSource.localCache,
          savedAt: cached.savedAt,
        );
      }
    } on Object {
      // A broken local cache must not prevent a fresh server read.
    }

    await for (final serverItems in _service.watchByOwner(uid)) {
      final cachedById = {
        for (final item in cached?.items ?? const <ItemCatalogo>[])
          item.id: item,
      };
      final items = serverItems
          .map((item) {
            final local = cachedById[item.id];
            return local?.fotoLocalBase64 == null
                ? item
                : item.copyWith(fotoLocalBase64: local!.fotoLocalBase64);
          })
          .toList(growable: false);
      await _cache.write(uid, items);
      cached = CachedCatalog(items: items, savedAt: DateTime.now().toUtc());
      yield CatalogSnapshot(
        items: items,
        source: CatalogDataSource.firestore,
        savedAt: cached.savedAt,
      );
    }
  }

  @override
  Future<ItemCatalogo> create(String uid, ItemCatalogo item) async {
    _requireUid(uid);
    final created = await _service.create(uid, item);
    final current = await _cache.read(uid);
    final next = [
      created,
      ...?current?.items.where((entry) => entry.id != created.id),
    ];
    await _cache.write(uid, next);
    return created;
  }

  @override
  Future<void> update(String uid, ItemCatalogo item) async {
    _requireUid(uid);
    await _service.update(uid, item);
    final current = await _cache.read(uid);
    final items = current?.items ?? const <ItemCatalogo>[];
    final updated = [
      for (final cached in items)
        if (cached.id == item.id && item.fotoLocalBase64 == null)
          item.copyWith(fotoLocalBase64: cached.fotoLocalBase64)
        else if (cached.id == item.id)
          item
        else
          cached,
    ];
    if (!updated.any((cached) => cached.id == item.id)) updated.insert(0, item);
    await _cache.write(uid, updated);
  }

  @override
  Future<void> delete(String uid, String id) async {
    _requireUid(uid);
    await _service.delete(uid, id);
    final current = await _cache.read(uid);
    final items = current?.items ?? const <ItemCatalogo>[];
    await _cache.write(
      uid,
      items.where((item) => item.id != id).toList(growable: false),
    );
  }

  @override
  Future<void> clearCache(String uid) => _cache.clear(_requireUid(uid));

  String _requireUid(String uid) {
    if (uid.isEmpty) throw const CatalogFailure(CatalogFailureKind.session);
    return uid;
  }
}
