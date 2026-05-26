import 'package:shared_preferences/shared_preferences.dart';

class RecentRoomsStore {
  static const _key = 'recent_room_codes';
  static const _max = 5;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<void> remember(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    final next = [code, ...current.where((c) => c != code)].take(_max).toList();
    await prefs.setStringList(_key, next);
  }
}
