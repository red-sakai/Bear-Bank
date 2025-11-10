import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../models/models.dart';

class TransactionProvider extends ChangeNotifier {
  final Box<BankTransaction> box;

  TransactionProvider(this.box);

  List<BankTransaction> get all => box.values.sortedBy((e) => e.date).toList().reversed.toList();

  Future<void> add(BankTransaction tx) async {
    await box.put(tx.id, tx);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await box.delete(id);
    notifyListeners();
  }

  double totalForMonth(int year, int month, {bool expensesOnly = true}) {
    return box.values
        .where((t) => t.date.year == year && t.date.month == month && (expensesOnly ? t.isExpense : true))
        .fold<double>(0.0, (sum, t) => sum + t.amount * (t.isExpense ? 1 : -1));
  }

  // New clearer helpers
  double totalExpenses(int year, int month) {
    return box.values
        .where((t) => t.date.year == year && t.date.month == month && t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double totalIncome(int year, int month) {
    return box.values
        .where((t) => t.date.year == year && t.date.month == month && !t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double totalForCategory(int year, int month, CategoryType category) {
    return box.values
        .where((t) => t.date.year == year && t.date.month == month && t.category == category && t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }
}
