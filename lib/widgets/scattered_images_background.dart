import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A subtle decorative background that scatters a few images from
/// assets/images/couple-pics across the screen with low opacity.
class ScatteredImagesBackground extends StatefulWidget {
  final int maxImages; // how many to place
  final double opacity;
  final bool enable;
  const ScatteredImagesBackground({super.key, this.maxImages = 10, this.opacity = 0.12, this.enable = true});

  @override
  State<ScatteredImagesBackground> createState() => _ScatteredImagesBackgroundState();
}

class _ScatteredImagesBackgroundState extends State<ScatteredImagesBackground> {
  final _rng = Random();
  static List<String>? _cached; // cache across screens
  List<String> _assets = [];
  List<_PlacedImage> _placed = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_cached != null) {
      _assets = _cached!;
      if (mounted) setState(() {});
      return;
    }
    try {
      final content = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(content);
      final pics = manifest.keys.where((k) {
        if (!k.startsWith('assets/images/couple-pics/')) return false;
        final lower = k.toLowerCase();
        return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp');
      }).toList();
      // If there are HEIC images present they won't render; ignore them silently.
      _cached = pics;
      if (!mounted) return;
      setState(() => _assets = pics);
    } catch (_) {}
  }

  void _place(Size size) {
    _placed.clear();
    if (_assets.isEmpty) return;
    final count = widget.maxImages;
    final placedRects = <Rect>[];
    const baseW = 120.0;
    const baseH = 120.0;
    const padding = 12.0; // min distance between items

    // Try to place each image with up to N attempts avoiding overlaps.
    // Build a sequence that uses all images once before repeating.
    final order = <String>[];
    var pool = _assets.toList()..shuffle(_rng);
    while (order.length < count) {
      order.addAll(pool);
      pool = _assets.toList()..shuffle(_rng);
    }

    for (var i = 0; i < count; i++) {
      final img = order[i];
      int tries = 0;
      bool placed = false;
      while (tries < 60 && !placed) {
        final rot = (_rng.nextDouble() * 16 - 8) * pi / 180; // -8..+8 degrees
        final scale = 0.75 + _rng.nextDouble() * 0.75; // 0.75..1.5
        // Compute rotated bounding box around top-left origin
        final cosT = cos(rot).abs();
        final sinT = sin(rot).abs();
        final w = (baseW * cosT + baseH * sinT) * scale;
        final h = (baseW * sinT + baseH * cosT) * scale;
        if (w >= size.width || h >= size.height) {
          tries++;
          continue;
        }
        final dx = _rng.nextDouble() * (size.width - w);
        final dy = _rng.nextDouble() * (size.height - h);
        final rect = Rect.fromLTWH(dx - padding, dy - padding, w + padding * 2, h + padding * 2);
        final overlaps = placedRects.any((r) => r.overlaps(rect));
        if (!overlaps) {
          placedRects.add(rect);
          _placed.add(_PlacedImage(asset: img, offset: Offset(dx, dy), rotation: rot, scale: scale));
          placed = true;
        }
        tries++;
      }
      // If we can't place after many tries, we just skip this slot.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) return const SizedBox.shrink();
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _place(Size(constraints.maxWidth, constraints.maxHeight));
          if (_assets.isEmpty) {
            // Fallback: scatter a few emoji if there are no supported images (e.g., only HEIC files).
            final rng = _rng;
            final items = List.generate(widget.maxImages, (i) {
              final dx = rng.nextDouble() * (constraints.maxWidth - 80);
              final dy = rng.nextDouble() * (constraints.maxHeight - 80);
              final rot = (rng.nextDouble() * 10 - 5) * pi / 180;
              final scale = 0.9 + rng.nextDouble() * 0.6;
              final emoji = i.isEven ? '🐻' : '🖤';
              return Positioned(
                left: dx,
                top: dy,
                child: Transform.rotate(
                  angle: rot,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: widget.opacity + 0.05,
                      child: Text(emoji, style: const TextStyle(fontSize: 48)),
                    ),
                  ),
                ),
              );
            });
            return Stack(children: items);
          }
          return Stack(
            children: _placed
                .map((p) => Positioned(
                      left: p.offset.dx,
                      top: p.offset.dy,
                      child: Transform.rotate(
                        angle: p.rotation,
                        alignment: Alignment.topLeft,
                        child: Transform.scale(
                          scale: p.scale,
                          alignment: Alignment.topLeft,
                          child: Opacity(
                            opacity: widget.opacity,
                            child: Image.asset(
                              p.asset,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _PlacedImage {
  final String asset;
  final Offset offset;
  final double rotation;
  final double scale;
  _PlacedImage({required this.asset, required this.offset, required this.rotation, required this.scale});
}
