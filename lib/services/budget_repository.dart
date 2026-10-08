import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget.dart';
import 'order_store.dart';
class BudgetRepository extends ChangeNotifier {
  BudgetRepository._() {
    OrderStore.instance.addListener(notifyListeners);
  }
  static final BudgetRepository instance = BudgetRepository._();

  static const _limitKey = 'budget_limit_v1';
  static const _setAtKey = 'budget_set_at_v1';

  Budget? _budget;
  Budget? get budget => _budget;
  bool get hasBudget => _budget != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limit = prefs.getDouble(_limitKey);
      if (limit == null) return;
      _budget = Budget(
        limit: limit,
        setAt: DateTime.tryParse(prefs.getString(_setAtKey) ?? ''),
      );
    } catch (_) {
      _budget = null;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final b = _budget;
      if (b == null) {
        await prefs.remove(_limitKey);
        await prefs.remove(_setAtKey);
        return;
      }
      await prefs.setDouble(_limitKey, b.limit);
      await prefs.setString(_setAtKey, b.setAt.toIso8601String());
    } catch (_) {}
  }

  void setBudget(double limit) {
    _budget = Budget(limit: limit);
    unawaited(_save());
    notifyListeners();
  }

  void updateBudget(double limit) {
    if (_budget == null) {
      setBudget(limit);
      return;
    }
    _budget!.limit = limit;
    unawaited(_save());
    notifyListeners();
  }

  void clearBudget() {
    _budget = null;
    unawaited(_save());
    notifyListeners();
  }

  DateTime get _periodStart {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final b = _budget;
    if (b == null) return monthStart;
    return b.setAt.isAfter(monthStart) ? b.setAt : monthStart;
  }

  Iterable<Order> get _countedOrders {
    final start = _periodStart;
    return OrderStore.instance.orders.where((o) => !o.date.isBefore(start));
  }

  double get totalSpent =>
      _countedOrders.fold<double>(0, (sum, o) => sum + o.total);

  int get spentCount => _countedOrders.fold<int>(
        0,
        (sum, o) => sum + o.items.fold<int>(0, (s, i) => s + i.qty),
      );

  double get remaining {
    if (_budget == null) return 0;
    return _budget!.limit - totalSpent;
  }

  double get progress {
    if (_budget == null || _budget!.limit <= 0) return 0;
    return totalSpent / _budget!.limit;
  }

  bool get isOverBudget => _budget != null && totalSpent > _budget!.limit;

  bool get isNearLimit =>
      _budget != null && progress >= 0.85 && !isOverBudget;
}
