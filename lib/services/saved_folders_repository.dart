import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/saved_folder.dart';

class SavedFoldersRepository extends ChangeNotifier {
  SavedFoldersRepository._();
  static final SavedFoldersRepository instance = SavedFoldersRepository._();

  static const _key = 'saved_folders_v1';
  final List<SavedFolder> _folders = [];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      _folders
        ..clear()
        ..addAll(
          (jsonDecode(raw) as List)
              .map((e) => SavedFolder.fromJson(e as Map<String, dynamic>)),
        );
    } catch (_) {
      _folders.clear();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_folders.map((f) => f.toJson()).toList()),
      );
    } catch (_) {}
  }

  void _commit() {
    unawaited(_persist());
    notifyListeners();
  }

  SavedFolder get _defaultFolder {
    var folder = _folders.firstWhere(
      (f) => f.id == 'default',
      orElse: () {
        final f = SavedFolder(id: 'default', name: 'Semua Simpanan');
        _folders.insert(0, f);
        return f;
      },
    );
    return folder;
  }

  List<SavedFolder> get folders {
    _defaultFolder; 
    return List.unmodifiable(_folders);
  }

  int get totalCount =>
      _folders.fold(0, (sum, folder) => sum + folder.count);

  SavedFolder createFolder(String name) {
    final folder = SavedFolder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    _folders.add(folder);
    _commit();
    return folder;
  }

  void renameFolder(String folderId, String newName) {
    final folder = _folders.firstWhere((f) => f.id == folderId);
    folder.name = newName;
    _commit();
  }

  void deleteFolder(String folderId) {
    if (folderId == 'default') return; 
    _folders.removeWhere((f) => f.id == folderId);
    _commit();
  }

  bool isSavedAnywhere(int productId) {
    return _folders.any(
      (f) => f.products.any((p) => p.id == productId),
    );
  }

  bool isInFolder(String folderId, int productId) {
    final folder = _folders.firstWhere(
      (f) => f.id == folderId,
      orElse: () => SavedFolder(id: '_', name: '_'),
    );
    return folder.products.any((p) => p.id == productId);
  }

  void toggleInFolder(String folderId, Product product) {
    final folder = _folders.firstWhere((f) => f.id == folderId);
    final exists = folder.products.any((p) => p.id == product.id);
    if (exists) {
      folder.products.removeWhere((p) => p.id == product.id);
    } else {
      folder.products.add(product);
    }
    _commit();
  }

  void removeFromAllFolders(int productId) {
    for (final folder in _folders) {
      folder.products.removeWhere((p) => p.id == productId);
    }
    _commit();
  }

  List<String> getFolderNamesForProduct(int productId) {
    return _folders
        .where((f) => f.products.any((p) => p.id == productId))
        .map((f) => f.name)
        .toList();
  }
}