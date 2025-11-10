import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/transaction_provider.dart';
import '../models/category.dart';
import '../widgets/scattered_images_background.dart';
import '../utils/currency.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txs = context.watch<TransactionProvider>().all;
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Stack(
        children: [
          const ScatteredImagesBackground(),
          ListView.separated(
            itemCount: txs.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final t = txs[index];
              final sign = t.isExpense ? '-' : '+';
              return ListTile(
                leading: CircleAvatar(child: Text(t.category.label[0])),
                title: Text(t.note.isEmpty ? t.category.label : t.note),
                subtitle: Text(DateFormat.yMMMd().format(t.date)),
                trailing: Text(
                  '$sign${formatPeso(t.amount)}',
                  style: TextStyle(color: t.isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/transactions/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
