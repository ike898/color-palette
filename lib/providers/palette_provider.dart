import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/saved_palette.dart';

int _counter = 0;

String _generateId() =>
    '${DateTime.now().millisecondsSinceEpoch}_${++_counter}';

final paletteListProvider =
    AsyncNotifierProvider<PaletteListNotifier, List<SavedPalette>>(
        PaletteListNotifier.new);

class PaletteListNotifier extends AsyncNotifier<List<SavedPalette>> {
  @override
  Future<List<SavedPalette>> build() => _load();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/palettes.json');
  }

  Future<List<SavedPalette>> _load() async {
    final file = await _file;
    if (!await file.exists()) return [];
    final json = jsonDecode(await file.readAsString()) as List;
    final palettes =
        json.map((e) => SavedPalette.fromJson(e as Map<String, dynamic>)).toList();
    palettes.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));
    return palettes;
  }

  Future<void> _save(List<SavedPalette> palettes) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(palettes.map((p) => p.toJson()).toList()));
  }

  Future<SavedPalette> add(List<Color> colors, {String? name}) async {
    final palette = SavedPalette(
      id: _generateId(),
      name: name ?? 'Palette ${(state.value?.length ?? 0) + 1}',
      colors: colors,
    );
    final current = [...?state.value, palette];
    state = AsyncData(current);
    await _save(current);
    return palette;
  }

  Future<void> updatePalette(SavedPalette updated) async {
    final current =
        state.value?.map((p) => p.id == updated.id ? updated : p).toList() ?? [];
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> delete(String id) async {
    final current = state.value?.where((p) => p.id != id).toList() ?? [];
    state = AsyncData(current);
    await _save(current);
  }
}
