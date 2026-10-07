import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import 'saved_folders_repository.dart';

class BudgetRepository extends ChangeNotifier {
  BudgetRepository._();
  static final BudgetRepository instance = BudgetRepository._();

  Budget? _budget;
  Budget? get budget => _budget;
  bool get hasBudget => _budget != null;

  void setBudget(double limit) {
    _budget = Budget(limit: limit);
    notifyListeners();
  }

  void updateBudget(double limit) {
    if (_budget == null) {
      setBudget(limit);
      return;
    }
    _budget!.limit = limit;
    notifyListeners();
  }

  void clearBudget() {
    _budget = null;
    notifyListeners();
  }

  double get totalSaved {
    final seenIds = <int>{};
    double total = 0;
    for (final folder in SavedFoldersRepository.instance.folders) {
      for (final product in folder.products) {
        if (seenIds.add(product.id)) {
          total += product.finalIdr;
        }
      }
    }
    return total;
  }

  int get totalSavedCount {
    final seenIds = <int>{};
    for (final folder in SavedFoldersRepository.instance.folders) {
      for (final product in folder.products) {
        seenIds.add(product.id);
      }
    }
    return seenIds.length;
  }

  double get remaining {
    if (_budget == null) return 0;
    return _budget!.limit - totalSaved;
  }

  double get progress {
    if (_budget == null || _budget!.limit <= 0) return 0;
    return totalSaved / _budget!.limit;
  }

  bool get isOverBudget =>
      _budget != null && totalSaved > _budget!.limit;

  bool get isNearLimit =>
      _budget != null && progress >= 0.85 && !isOverBudget;
}