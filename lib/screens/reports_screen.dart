import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../state/transaction_provider.dart';
import '../models/models.dart';
import '../widgets/scattered_images_background.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final txProvider = context.watch<TransactionProvider>();
    final data = CategoryType.values.map((c) {
      final spent = txProvider.totalForCategory(now.year, now.month, c);
      return MapEntry(c, spent);
    }).where((e) => e.value > 0).toList();

    final sections = data.map((e) {
      final color = _colorForCategory(e.key);
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: e.key.label.substring(0, 3),
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Stack(
        children: [
          const ScatteredImagesBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Spending Breakdown'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: data.isEmpty
                              ? const Center(child: Text('No expenses yet'))
                              : PieChart(PieChartData(sections: sections)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(CategoryType c) {
    switch (c) {
      case CategoryType.food:
        return Colors.redAccent;
      case CategoryType.transport:
        return Colors.blueAccent;
      case CategoryType.shopping:
        return Colors.purpleAccent;
      case CategoryType.entertainment:
        return Colors.orangeAccent;
      case CategoryType.bills:
        return Colors.indigo;
      case CategoryType.health:
        return Colors.teal;
      case CategoryType.savings:
        return Colors.green;
      case CategoryType.other:
        return Colors.grey;
    }
  }
}
