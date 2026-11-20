import 'dart:async';

import 'package:catalogo_pessoal/features/catalog/data/repositories/catalog_repository.dart';
import 'package:catalogo_pessoal/features/catalog/domain/catalog_failure.dart';
import 'package:catalogo_pessoal/features/catalog/presentation/view_models/catalog_view_model.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository implements CatalogRepository {
  final controller = StreamController<CatalogSnapshot>.broadcast();
  CatalogFailure? failure;
  String? lastUid;
  bool cacheCleared = false;
  ItemCatalogo? created;
  ItemCatalogo? updated;
  String? deleted;

  @override
  Stream<CatalogSnapshot> watchMine(String uid) {
    lastUid = uid;
    return controller.stream;
  }

  @override
  Future<ItemCatalogo> create(String uid, ItemCatalogo item) async {
    lastUid = uid;
    if (failure != null) throw failure!;
    created = item;
    return item;
  }

  @override
  Future<void> update(String uid, ItemCatalogo item) async {
    lastUid = uid;
    if (failure != null) throw failure!;
    updated = item;
  }

  @override
  Future<void> delete(String uid, String id) async {
    lastUid = uid;
    if (failure != null) throw failure!;
    deleted = id;
  }

  @override
  Future<void> clearCache(String uid) async {
    lastUid = uid;
    cacheCleared = true;
  }
}

void main() {
  test(
    'transitions loading -> empty -> success and preserves cache provenance',
    () async {
      final repository = _Repository();
      final viewModel = CatalogViewModel(repository, 'user-1')..start();
      expect(viewModel.status, CatalogStatus.loading);
      expect(repository.lastUid, 'user-1');

      repository.controller.add(
        const CatalogSnapshot(items: [], source: CatalogDataSource.firestore),
      );
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.status, CatalogStatus.empty);

      final item = ItemCatalogo(id: 'a', titulo: 'Livro A');
      repository.controller.add(
        CatalogSnapshot(
          items: [item],
          source: CatalogDataSource.localCache,
          savedAt: DateTime.utc(2026),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.status, CatalogStatus.success);
      expect(viewModel.items.single, item);
      expect(viewModel.isShowingLocalData, isTrue);
      expect(viewModel.savedAt, DateTime.utc(2026));
      await repository.controller.close();
      viewModel.dispose();
    },
  );

  test('maps stream failures and retries by reopening subscription', () async {
    final repository = _Repository();
    final viewModel = CatalogViewModel(repository, 'user-1')..start();
    repository.controller.addError(
      const CatalogFailure(CatalogFailureKind.unavailable),
    );
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.status, CatalogStatus.failure);
    expect(viewModel.loadFailure?.kind, CatalogFailureKind.unavailable);
    await viewModel.retry();
    expect(viewModel.status, CatalogStatus.loading);
    await repository.controller.close();
    viewModel.dispose();
  });

  test(
    'routes create, update, delete and private-cache clearing through UID',
    () async {
      final repository = _Repository();
      final viewModel = CatalogViewModel(repository, 'owner-42');
      final item = ItemCatalogo(id: 'doc-1', titulo: 'Obra');
      expect(await viewModel.save(item, isNew: true), isTrue);
      expect(repository.created, item);
      expect(await viewModel.save(item, isNew: false), isTrue);
      expect(repository.updated, item);
      expect(await viewModel.delete(item), isTrue);
      expect(repository.deleted, item.id);
      await viewModel.clearPrivateCache();
      expect(repository.lastUid, 'owner-42');
      expect(repository.cacheCleared, isTrue);
      viewModel.dispose();
    },
  );

  test('exposes command error and allows another attempt', () async {
    final repository = _Repository()
      ..failure = const CatalogFailure(CatalogFailureKind.permission);
    final viewModel = CatalogViewModel(repository, 'owner-42');
    final item = ItemCatalogo(id: 'doc-1', titulo: 'Obra');
    expect(await viewModel.save(item, isNew: true), isFalse);
    expect(viewModel.commandFailure?.kind, CatalogFailureKind.permission);
    repository.failure = null;
    expect(await viewModel.save(item, isNew: true), isTrue);
    expect(viewModel.commandFailure, isNull);
    viewModel.dispose();
  });
}
