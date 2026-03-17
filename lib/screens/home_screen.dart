import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/palette_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/palette_card.dart';
import 'palette_result_screen.dart';
import 'pick_image_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PickImageScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palettesAsync = ref.watch(paletteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorPalette'),
      ),
      body: palettesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (palettes) {
          if (palettes.isEmpty) {
            return EmptyStateWidget(
              headline: 'Capture your first palette',
              subtext: 'Point your camera at anything colorful',
              ctaLabel: 'Open Camera',
              icon: Icons.palette_outlined,
              onCtaTap: () => _openCamera(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: palettes.length,
            itemBuilder: (context, index) {
              final palette = palettes[index];
              return PaletteCard(
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaletteResultScreen(palette: palette),
                  ),
                ),
                onDelete: () =>
                    ref.read(paletteListProvider.notifier).delete(palette.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCamera(context),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
