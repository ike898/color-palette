import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/saved_palette.dart';
import '../providers/palette_provider.dart';

class PaletteResultScreen extends ConsumerStatefulWidget {
  final SavedPalette palette;

  const PaletteResultScreen({super.key, required this.palette});

  @override
  ConsumerState<PaletteResultScreen> createState() =>
      _PaletteResultScreenState();
}

class _PaletteResultScreenState extends ConsumerState<PaletteResultScreen> {
  late SavedPalette _palette;
  final _exportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _palette = widget.palette;
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _palette.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Palette'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Palette name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final updated = _palette.copyWith(name: name);
      await ref.read(paletteListProvider.notifier).updatePalette(updated);
      setState(() => _palette = updated);
    }
  }

  Future<void> _exportPng() async {
    try {
      final boundary = _exportKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/palette_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $label: $text'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _rename,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(_palette.name, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 16),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportPng,
            tooltip: 'Export PNG',
          ),
        ],
      ),
      body: Column(
        children: [
          RepaintBoundary(
            key: _exportKey,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: _palette.colors
                    .map((c) => Expanded(
                          child: AspectRatio(
                            aspectRatio: 0.7,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                c.toHex(),
                                style: TextStyle(
                                  color: c.computeLuminance() > 0.5
                                      ? Colors.black87
                                      : Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _palette.colors.length,
              itemBuilder: (context, index) {
                final color = _palette.colors[index];
                final hex = color.toHex();
                final rgb = color.toRgbString();
                final hsl = color.toHslString();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CopyableText(
                                label: 'HEX',
                                value: hex,
                                onCopy: () => _copyToClipboard(hex, 'HEX'),
                              ),
                              _CopyableText(
                                label: 'RGB',
                                value: rgb,
                                onCopy: () => _copyToClipboard(rgb, 'RGB'),
                              ),
                              _CopyableText(
                                label: 'HSL',
                                value: hsl,
                                onCopy: () => _copyToClipboard(hsl, 'HSL'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyableText extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyableText({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            Text(value, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 4),
            Icon(Icons.copy, size: 12, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
