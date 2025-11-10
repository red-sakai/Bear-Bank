import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/transaction_provider.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});
  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isExpense = true;
  CategoryType _category = CategoryType.food;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  final _player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SwitchListTile(
                title: Text(_isExpense ? 'Expense' : 'Income'),
                value: _isExpense,
                onChanged: (v) => setState(() => _isExpense = v),
              ),
              DropdownButtonFormField<CategoryType>(
                value: _category,
                items: CategoryType.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (c) => setState(() => _category = c!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Enter positive amount';
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              ListTile(
                title: Text('Date: ${_date.toLocal().toString().split(' ').first}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 1),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final amount = double.parse(_amountController.text);
                  final id = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
                  final tx = BankTransaction(
                    id: id,
                    date: _date,
                    amount: amount,
                    isExpense: _isExpense,
                    category: _category,
                    note: _noteController.text,
                  );
                  await context.read<TransactionProvider>().add(tx);
                  if (_isExpense) {
                    await _showDuduAngry();
                  } else {
                    await _showBubuMoney();
                  }
                  if (mounted) Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDuduAngry() async {
    // Play audio
    try {
      await _player.stop();
    } catch (_) {}
    await _player.play(AssetSource('audio/dudu_angry.mp3'));

    if (!mounted) return;
    // Show improved overlay with blur, fade + scale animation
    // Don't await here so we can time-dismiss it after 3s
    // ignore: unawaited_futures
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'dudu_angry',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final scale = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));
        final opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return Opacity(
          opacity: opacity.value,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // subtle blur backdrop
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: const SizedBox.expand(),
              ),
              Center(
                child: ScaleTransition(
                  scale: scale,
                  child: Material(
                    color: Colors.white,
                    elevation: 12,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset('assets/gifs/dudu_angry.gif', height: 180, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Dudu is angry at that spending!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Let's be mindful next time.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Keep it on screen for ~3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Stop audio after close if still playing
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _showBubuMoney() async {
    // Play audio
    try {
      await _player.stop();
    } catch (_) {}
    await _player.play(AssetSource('audio/bubu_money.mp3'));

    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'bubu_money',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final scale = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));
        final opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return Opacity(
          opacity: opacity.value,
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: const SizedBox.expand(),
              ),
              Center(
                child: ScaleTransition(
                  scale: scale,
                  child: Material(
                    color: Colors.white,
                    elevation: 12,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset('assets/gifs/bubu_money.gif', height: 180, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bubu loves that income! 💰',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nice boost to your budget.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    try {
      await _player.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
