import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'reports_screen.dart';
import 'instructions_screen.dart';
import 'memes_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    ReportsScreen(),
    InstructionsScreen(), // kept as full pages for now (accessible via overflow menu soon)
    MemesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // If the screen is very narrow we still keep all destinations but hide unselected labels
    // to reduce squeezing. On larger widths we can show all labels.
    final width = MediaQuery.of(context).size.width;
    final showAllLabels = width > 500; // simple heuristic

    return Scaffold(
      // Preserve state of each page using IndexedStack instead of rebuilding when switching.
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 62,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: selected ? 12 : 10, // smaller overall
              letterSpacing: -0.2,
            );
          }),
          indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          overlayColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.05)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          labelBehavior: showAllLabels
              ? NavigationDestinationLabelBehavior.alwaysShow
              : NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Transactions'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budgets'),
            NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Reports'),
            NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'Help'),
            NavigationDestination(icon: Icon(Icons.mood_outlined), selectedIcon: Icon(Icons.mood), label: 'Memes'),
          ],
        ),
      ),
    );
  }
}
