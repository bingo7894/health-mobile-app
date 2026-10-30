import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const List<String> kDefaultMealOrder = [
  'BREAKFAST',
  'LUNCH',
  'DINNER',
  'SNACK',
];

class MealOrderNotifier extends StateNotifier<List<String>> {
  static const String _storageKey = 'custom_meal_order';
  final FlutterSecureStorage _storage;

  MealOrderNotifier(this._storage) : super(List<String>.from(kDefaultMealOrder)) {
    _loadSavedOrder();
  }

  Future<void> _loadSavedOrder() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved != null && saved.isNotEmpty) {
        final list = saved
            .split(',')
            .map((e) => e.trim().toUpperCase())
            .where((e) => e.isNotEmpty)
            .toList();
        if (list.isNotEmpty) {
          state = list;
        }
      }
    } catch (_) {}
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0 || newIndex >= state.length) return;

    final updated = List<String>.from(state);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    state = updated;

    _saveOrder(updated);
  }

  void reorderItem(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex >= state.length) return;

    final updated = List<String>.from(state);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    state = updated;

    _saveOrder(updated);
  }

  void syncWithAvailableTypes(Iterable<String> availableTypes) {
    final current = List<String>.from(state);
    bool changed = false;
    for (final type in availableTypes) {
      final upper = type.toUpperCase();
      if (!current.contains(upper)) {
        current.add(upper);
        changed = true;
      }
    }
    if (changed) {
      state = current;
      _saveOrder(current);
    }
  }

  Future<void> _saveOrder(List<String> order) async {
    try {
      await _storage.write(key: _storageKey, value: order.join(','));
    } catch (_) {}
  }
}

final mealOrderProvider =
    StateNotifierProvider<MealOrderNotifier, List<String>>((ref) {
  const storage = FlutterSecureStorage();
  return MealOrderNotifier(storage);
});
