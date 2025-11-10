import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Instructions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructions for my bubu bear bibeh bear', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _InstructionItem(index: 1, text: 'gawa ka muna budget bibeh for specific expenses mu like foodies or rent ganernn'),
            _InstructionItem(index: 2, text: 'tas punta ka sa dashboard kada may income or expenses ikaw para ma-set sya and ma-update'),
            _InstructionItem(index: 3, text: 'makikita mo sa transactions ang mga nalagay mo na income or expensesss'),
            _InstructionItem(index: 4, text: 'sa reports chart lang cia for design mweheheheh'),
            const SizedBox(height: 16),
            Text('i love youuuu', style: textTheme.titleMedium?.copyWith(color: Colors.pink, fontWeight: FontWeight.w700)),
            const Spacer(),
            Center(
              child: Text('🐻🖤', style: textTheme.headlineSmall),
            )
          ],
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final int index;
  final String text;
  const _InstructionItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$index', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
