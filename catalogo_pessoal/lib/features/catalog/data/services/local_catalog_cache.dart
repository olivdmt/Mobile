import 'dart:convert';

import 'package:catalogo_pessoal/models/item_catalogo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedCatalog {
  const CachedCatalog({required this.items, required this.savedAt});

  final List<ItemCatalogo> items;
  final DateTime savedAt;
}

abstract interface class LocalCatalogCache {
  Future<CachedCatalog?> read(String uid);
  Future<void> write(String uid, List<ItemCatalogo> items);
  Future<void> clear(String uid);
}

class SharedPreferencesCatalogCache implements LocalCatalogCache {
  SharedPreferencesCatalogCache(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const _schemaVersion = 1;

  String _key(String uid) => 'catalog_cache_v$_schemaVersion:$uid';

  @override
  Future<CachedCatalog?> read(String uid) async {
    final encoded = await _preferences.getString(_key(uid));
    if (encoded == null) return null;
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> ||
        decoded['items'] is! List ||
        decoded['savedAt'] is! String) {
      await clear(uid);
      return null;
    }

    try {
      final items = (decoded['items'] as List)
          .map(
            (item) => ItemCatalogo.fromCacheJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
      final savedAt = DateTime.tryParse(decoded['savedAt'] as String);
      if (savedAt == null) {
        throw const FormatException('Data de cache inválida.');
      }
      return CachedCatalog(items: items, savedAt: savedAt);
    } on Object {
      await clear(uid);
      return null;
    }
  }

  @override
  Future<void> write(String uid, List<ItemCatalogo> items) async {
    await _preferences.setString(
      _key(uid),
      jsonEncode({
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        'items': items.map((item) => item.toCacheJson()).toList(),
      }),
    );
  }

  @override
  Future<void> clear(String uid) => _preferences.remove(_key(uid));
}
