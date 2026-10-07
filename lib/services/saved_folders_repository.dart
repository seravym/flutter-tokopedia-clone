import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/saved_folder.dart';

class SavedFoldersRepository extends ChangeNotifier {
  SavedFoldersRepository._();
  static final SavedFoldersRepository instance = SavedFoldersRepository._();

  final List<SavedFolder> _folders = [];

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
    notifyListeners();
    return folder;
  }

  void renameFolder(String folderId, String newName) {
    final folder = _folders.firstWhere((f) => f.id == folderId);
    folder.name = newName;
    notifyListeners();
  }

  void deleteFolder(String folderId) {
    if (folderId == 'default') return; 
    _folders.removeWhere((f) => f.id == folderId);
    notifyListeners();
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
    notifyListeners();
  }

  void removeFromAllFolders(int productId) {
    for (final folder in _folders) {
      folder.products.removeWhere((p) => p.id == productId);
    }
    notifyListeners();
  }

  List<String> getFolderNamesForProduct(int productId) {
    return _folders
        .where((f) => f.products.any((p) => p.id == productId))
        .map((f) => f.name)
        .toList();
  }
}