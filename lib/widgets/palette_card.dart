import 'package:flutter/material.dart';
import '../models/saved_palette.dart';

class PaletteCard extends StatelessWidget {
  final SavedPalette palette;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaletteCard({
    super.key,
    required this.palette,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(palette.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: palette.colors
                      .map((c) => Expanded(
                            child: Container(color: c),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(palette.name, style: theme.textTheme.titleSmall),
                    if (palette.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: palette.tags
                            .map((t) => Chip(
                                  label: Text(t),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  labelStyle: theme.textTheme.labelSmall,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
