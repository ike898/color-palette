import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import '../providers/palette_provider.dart';
import 'palette_result_screen.dart';

class PickImageScreen extends ConsumerStatefulWidget {
  const PickImageScreen({super.key});

  @override
  ConsumerState<PickImageScreen> createState() => _PickImageScreenState();
}

class _PickImageScreenState extends ConsumerState<PickImageScreen> {
  bool _loading = false;

  Future<void> _pickAndExtract(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked == null || !mounted) return;

    setState(() => _loading = true);

    try {
      final imageFile = File(picked.path);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        FileImage(imageFile),
        size: const Size(200, 200),
        maximumColorCount: 8,
      );

      final colors = paletteGenerator.paletteColors
          .take(5)
          .map((c) => c.color)
          .toList();

      if (colors.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not extract colors from this image')),
          );
          setState(() => _loading = false);
        }
        return;
      }

      while (colors.length < 5) {
        colors.add(colors.last);
      }

      final palette =
          await ref.read(paletteListProvider.notifier).add(colors);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaletteResultScreen(palette: palette),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Extracting Colors...')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing image...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pick Image')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_camera,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _pickAndExtract(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _pickAndExtract(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
