
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/music_player_controller.dart';

class MusicPlayerOverlay extends StatefulWidget {
  const MusicPlayerOverlay({super.key});

  @override
  State<MusicPlayerOverlay> createState() => _MusicPlayerOverlayState();
}

class _MusicPlayerOverlayState extends State<MusicPlayerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 8));
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MusicPlayerController>();
    if (mp.isPlaying && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!mp.isPlaying && _spin.isAnimating) {
      _spin.stop();
    }

    final theme = Theme.of(context);

    return IgnorePointer(
      ignoring: false,
      child: Padding(
        // Body area already sits above NavigationBar; keep a small margin.
        padding: const EdgeInsets.only(left: 12, bottom: 12),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinning disc button
              GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                child: RotationTransition(
                  turns: _spin,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF6E4AFF), Color(0xFFBB86FC)]),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner hole
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(mp.isPlaying ? Icons.music_note : Icons.music_note_outlined, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _showControls
                    ? Padding(
                        key: const ValueKey('controls'),
                        padding: const EdgeInsets.only(left: 8),
                        child: Material(
                          color: theme.colorScheme.surface.withOpacity(0.92),
                          elevation: 2,
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.skip_previous),
                                  onPressed: mp.hasTracks ? () => context.read<MusicPlayerController>().previous() : null,
                                ),
                                Tooltip(
                                  message: mp.currentTitle.isEmpty ? 'No track' : mp.currentTitle,
                                  child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                    icon: Icon(mp.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                                    onPressed: mp.hasTracks ? () => context.read<MusicPlayerController>().toggle() : null,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.skip_next),
                                  onPressed: mp.hasTracks ? () => context.read<MusicPlayerController>().next() : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
