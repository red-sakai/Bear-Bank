import 'package:flutter/material.dart';
// no extra imports needed here; initialization happens in SplashScreen
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bear Bank',
      theme: _buildTheme(),
      routes: {
        '/': (_) => const SplashScreen(),
      },
      // Other screens will be pushed after initialization.
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF6E4AFF); // playful purple
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
      // Keep defaults for card theme for compatibility across Flutter versions.
    );
  }
}
