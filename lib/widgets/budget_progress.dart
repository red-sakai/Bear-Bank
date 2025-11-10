import 'package:flutter/material.dart';

class BudgetProgress extends StatelessWidget {
  final double spent;
  final double limit;
  final String label;

  const BudgetProgress({super.key, required this.spent, required this.limit, required this.label});

  @override
  Widget build(BuildContext context) {
    final pct = limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final color = pct < 0.7
        ? Colors.green
        : pct < 1.0
            ? Colors.orange
            : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text("${spent.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
