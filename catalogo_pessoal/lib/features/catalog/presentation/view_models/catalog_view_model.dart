import 'dart:async';

import 'package:catalogo_pessoal/features/catalog/data/repositories/catalog_repository.dart';
import 'package:catalogo_pessoal/features/catalog/domain/catalog_failure.dart';
import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:flutter/foundation.dart';

enum CatalogStatus { loading, success, empty, failure }

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel(this._repository, this.uid);

  final CatalogRepository _repository;
  final String uid;
  StreamSubscription<CatalogSnapshot>? _subscription;
  bool _disposed = false;

  CatalogStatus status = CatalogStatus.loading;
  List<ItemCatalogo> items = const [];
  CatalogFailure? loadFailure;
  CatalogFailure? commandFailure;
  CatalogDataSource? source;
  DateTime? savedAt;
  bool isCommandLoading = false;

  bool get isShowingLocalData => source == CatalogDataSource.localCache;

  void start() {
    if (_subscription != null || _disposed) return;
    status = CatalogStatus.loading;
    _notify();
    _subscription = _repository
        .watchMine(uid)
        .listen(
          (snapshot) {
            items = snapshot.items;
            source = snapshot.source;
            savedAt = snapshot.savedAt;
            loadFailure = null;
            status = items.isEmpty
                ? CatalogStatus.empty
                : CatalogStatus.success;
            _notify();
          },
          onError: (Object error) {
            loadFailure = error is CatalogFailure
                ? error
                : const CatalogFailure(CatalogFailureKind.unexpected);
            status = items.isEmpty
                ? CatalogStatus.failure
                : CatalogStatus.success;
            _notify();
          },
        );
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    _subscription = null;
    items = const [];
    source = null;
    savedAt = null;
    loadFailure = null;
    start();
  }

  Future<bool> save(ItemCatalogo item, {required bool isNew}) =>
      _runCommand(() async {
        if (isNew) {
          await _repository.create(uid, item);
        } else {
          await _repository.update(uid, item);
        }
      });

  Future<bool> delete(ItemCatalogo item) =>
      _runCommand(() => _repository.delete(uid, item.id));

  Future<void> clearPrivateCache() => _repository.clearCache(uid);

  Future<bool> _runCommand(Future<void> Function() command) async {
    if (isCommandLoading || _disposed) return false;
    isCommandLoading = true;
    commandFailure = null;
    _notify();
    try {
      await command();
      return true;
    } catch (error) {
      commandFailure = error is CatalogFailure
          ? error
          : const CatalogFailure(CatalogFailureKind.unexpected);
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
