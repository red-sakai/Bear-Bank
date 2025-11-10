import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/budget_provider.dart';
import '../state/transaction_provider.dart';
import '../widgets/budget_progress.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budgets = context.watch<BudgetProvider>().forMonth(now.year, now.month);
    final txs = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final b = budgets[index];
          final spent = txs.totalForCategory(now.year, now.month, b.category);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.category.label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  BudgetProgress(label: 'This month', spent: spent, limit: b.limit),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    CategoryType category = CategoryType.food;
    final controller = TextEditingController();
    final now = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Budget'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CategoryType>(
                value: category,
                items: CategoryType.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (c) => category = c!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Monthly limit'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return 'Enter a positive number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final id = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
              final b = Budget(
                id: id,
                category: category,
                limit: double.parse(controller.text),
                year: now.year,
                month: now.month,
              );
              await context.read<BudgetProvider>().upsert(b);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
