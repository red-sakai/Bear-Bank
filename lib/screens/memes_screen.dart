import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MemesScreen extends StatefulWidget {
  const MemesScreen({super.key});

  @override
  State<MemesScreen> createState() => _MemesScreenState();
}

class _MemesScreenState extends State<MemesScreen> {
  List<_MemItem> _memes = [];
  static const String _fsMemesDir = r'C:\Github Projects\bear_bank\assets\images\memes';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // 1) Try to read directly from filesystem directory (Windows dev path as requested)
    final fromFs = await _loadFromFilesystem();
    if (fromFs.isNotEmpty) {
      if (!mounted) return;
      setState(() => _memes = fromFs);
      return;
    }

    // 2) Fallback to assets listed in AssetManifest (portable across platforms)
    try {
      final content = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(content);
      final imgs = manifest.keys
          .where((k) => k.startsWith('assets/images/memes/'))
          .where((k) {
            final lower = k.toLowerCase();
            return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.gif') || lower.endsWith('.webp');
          })
          .map((p) => _MemItem(path: p, isFile: false))
          .toList();
      if (!mounted) return;
      setState(() => _memes = imgs);
    } catch (_) {
      if (!mounted) return;
      setState(() => _memes = []);
    }
  }

  Future<List<_MemItem>> _loadFromFilesystem() async {
    try {
      final dir = Directory(_fsMemesDir);
      if (!await dir.exists()) return [];
      final entries = await dir.list().toList();
      final items = entries
          .whereType<File>()
          .map((f) => f.path)
          .where((p) {
            final lower = p.toLowerCase();
            return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.gif') || lower.endsWith('.webp');
          })
          .map((p) => _MemItem(path: p, isFile: true))
          .toList();
      return items;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bubu & Dudu Memes')),
      body: _memes.isEmpty
          ? const Center(child: Text('No memes found yet\nAdd images to assets/images/memes or the filesystem folder.', textAlign: TextAlign.center))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _memes.length,
              itemBuilder: (context, index) {
                final item = _memes[index];
                return GestureDetector(
                  onTap: () => _openViewer(item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: item.isFile
                        ? Image.file(File(item.path), fit: BoxFit.cover)
                        : Image.asset(item.path, fit: BoxFit.cover),
                  ),
                );
              },
            ),
    );
  }

  void _openViewer(_MemItem item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.isFile
                ? Image.file(File(item.path), fit: BoxFit.contain)
                : Image.asset(item.path, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _MemItem {
  final String path;
  final bool isFile;
  const _MemItem({required this.path, required this.isFile});
}
