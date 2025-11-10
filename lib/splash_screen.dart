import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/models.dart';
import 'app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _player = AudioPlayer();
  List<String> _gifs = [];
  int _index = 0;
  Timer? _cycleTimer;
  bool _loading = true;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      _status = 'Loading assets';
      setState(() {});
      await _loadGifs();
      _status = 'Starting audio';
      setState(() {});
      await _player.play(AssetSource('audio/bubu_loading.mp3'));
      _cycleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (_gifs.isNotEmpty) {
          setState(() => _index = (_index + 1) % _gifs.length);
        }
      });
      _status = 'Opening local storage';
      setState(() {});
      await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
      Hive.registerAdapter(CategoryTypeAdapter());
      Hive.registerAdapter(BankTransactionAdapter());
      Hive.registerAdapter(BudgetAdapter());
      final txBox = await Hive.openBox<BankTransaction>('transactions');
      final budgetBox = await Hive.openBox<Budget>('budgets');
      _status = 'Finalizing';
      setState(() {});
  // Extended delay so user sees the splash for ~7 seconds total.
  // We already spent some time initializing; enforce minimum display duration.
  await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      _player.stop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AppShell(txBox: txBox, budgetBox: budgetBox)),
      );
    } catch (e) {
      _status = 'Error: $e';
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadGifs() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestContent);
    final gifs = manifest.keys
        .where((k) => k.startsWith('assets/gifs/') && (k.endsWith('.gif') || k.endsWith('.GIF')))
        .toList();
    _gifs = gifs;
    if (_gifs.isEmpty) {
      _gifs = ['assets/gifs/bubu_dancing1.gif']; // fallback expected name
    }
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gif = _gifs.isEmpty ? null : _gifs[_index];
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (gif != null)
                SizedBox(
                  height: 180,
                  child: Image.asset(gif, fit: BoxFit.contain),
                )
              else
                const FlutterLogo(size: 120),
              const SizedBox(height: 32),
              Text('Bear Bank', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _loading
                  ? Column(
                      children: [
                        const SizedBox(
                          width: 180,
                          child: LinearProgressIndicator(minHeight: 6),
                        ),
                        const SizedBox(height: 12),
                        Text(_status, textAlign: TextAlign.center),
                      ],
                    )
                  : Text(_status, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 48),
              Text('Bubu & Dudu are preparing your budgets...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
