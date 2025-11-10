import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import 'models/models.dart';
import 'state/budget_provider.dart';
import 'state/transaction_provider.dart';
import 'screens/home_shell.dart';
import 'screens/new_transaction_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/reports_screen.dart';

class AppShell extends StatelessWidget {
  final Box<BankTransaction> txBox;
  final Box<Budget> budgetBox;
  const AppShell({super.key, required this.txBox, required this.budgetBox});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider(txBox)),
        ChangeNotifierProvider(create: (_) => BudgetProvider(budgetBox)),
      ],
      child: MaterialApp(
        title: 'Bear Bank',
        theme: _buildTheme(),
        routes: {
          '/': (_) => const HomeShell(),
          '/transactions/new': (_) => const NewTransactionScreen(),
          '/transactions': (_) => const TransactionsScreen(),
          '/budgets': (_) => const BudgetsScreen(),
          '/reports': (_) => const ReportsScreen(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF6E4AFF);
    final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed));
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.primaryContainer,
        foregroundColor: base.colorScheme.onPrimaryContainer,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: base.colorScheme.primary,
        foregroundColor: base.colorScheme.onPrimary,
      ),
    );
  }
}
