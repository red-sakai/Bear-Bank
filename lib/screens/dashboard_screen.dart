import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/budget_provider.dart';
import '../state/transaction_provider.dart';
import '../widgets/budget_progress.dart';
import '../widgets/scattered_images_background.dart';
import 'new_transaction_screen.dart';
import '../utils/currency.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
  final monthLabel = DateFormat('MMMM yyyy').format(now);
    final txs = context.watch<TransactionProvider>();
    final budgets = context.watch<BudgetProvider>();

    final expense = txs.totalExpenses(now.year, now.month);
    final income = txs.totalIncome(now.year, now.month);
    final net = income - expense;

    final forMonth = budgets.forMonth(now.year, now.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bear Bank'),
      ),
      body: Stack(
        children: [
          const ScatteredImagesBackground(),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(monthLabel, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            _moneyRow(context, 'Income', income, Colors.teal),
                            const SizedBox(height: 4),
                            _moneyRow(context, 'Expenses', -expense, Colors.pink),
                            const Divider(height: 20),
                            _moneyRow(context, 'Net', net, net >= 0 ? Colors.green : Colors.red),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: const Text('🐻\n🖤', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Budgets', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (forMonth.isEmpty)
                Text('No budgets yet. Add some from the Budgets tab.', style: Theme.of(context).textTheme.bodyMedium)
              else
                ...forMonth.map((b) {
                  final spent = txs.totalForCategory(now.year, now.month, b.category);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BudgetProgress(
                      label: b.category.label,
                      spent: spent,
                      limit: b.limit,
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewTransactionScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _moneyRow(BuildContext context, String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(formatPeso(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
