import 'package:flutter/material.dart';

class SavedPalette {
  final String id;
  final String name;
  final List<Color> colors;
  final List<String> tags;
  final String? sourceImagePath;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  SavedPalette({
    required this.id,
    required this.name,
    required this.colors,
    this.tags = const [],
    this.sourceImagePath,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModifiedAt = lastModifiedAt ?? DateTime.now();

  SavedPalette copyWith({
    String? name,
    List<Color>? colors,
    List<String>? tags,
    String? sourceImagePath,
  }) {
    return SavedPalette(
      id: id,
      name: name ?? this.name,
      colors: colors ?? this.colors,
      tags: tags ?? this.tags,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      createdAt: createdAt,
      lastModifiedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colors': colors.map((c) => c.toHex()).toList(),
        'tags': tags,
        'sourceImagePath': sourceImagePath,
        'createdAt': createdAt.toIso8601String(),
        'lastModifiedAt': lastModifiedAt.toIso8601String(),
      };

  factory SavedPalette.fromJson(Map<String, dynamic> json) => SavedPalette(
        id: json['id'] as String,
        name: json['name'] as String,
        colors: (json['colors'] as List)
            .map((hex) => ColorExtension.fromHex(hex as String))
            .toList(),
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        sourceImagePath: json['sourceImagePath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      );
}

extension ColorExtension on Color {
  String toHex() {
    final r = (this.r * 255).round().clamp(0, 255);
    final g = (this.g * 255).round().clamp(0, 255);
    final b = (this.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  String toRgbString() {
    final r = (this.r * 255).round().clamp(0, 255);
    final g = (this.g * 255).round().clamp(0, 255);
    final b = (this.b * 255).round().clamp(0, 255);
    return 'RGB($r, $g, $b)';
  }

  String toHslString() {
    final hsl = HSLColor.fromColor(this);
    return 'HSL(${hsl.hue.round()}, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%)';
  }

  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    final value = int.parse('FF$clean', radix: 16);
    return Color.from(
      alpha: 1.0,
      red: ((value >> 16) & 0xFF) / 255.0,
      green: ((value >> 8) & 0xFF) / 255.0,
      blue: (value & 0xFF) / 255.0,
    );
  }
}
