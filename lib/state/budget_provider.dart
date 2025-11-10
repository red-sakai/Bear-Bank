import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

class BudgetProvider extends ChangeNotifier {
  final Box<Budget> box;

  BudgetProvider(this.box);

  List<Budget> forMonth(int year, int month) {
    return box.values.where((b) => b.year == year && b.month == month).toList();
  }

  Budget? byCategory(int year, int month, CategoryType category) {
    try {
      return box.values.firstWhere((b) => b.year == year && b.month == month && b.category == category);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Budget budget) async {
    await box.put(budget.id, budget);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await box.delete(id);
    notifyListeners();
  }
}
