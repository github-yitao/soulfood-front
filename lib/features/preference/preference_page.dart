import 'package:flutter/material.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';

class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  final _repo = PreferenceRepository();
  static const _allTags = ['清淡', '微辣', '重辣', '家常菜', '汤面', '低脂', '高蛋白', '夜宵'];

  bool _loading = true;
  bool _saving = false;
  UserPreference? _pref;
  late Set<String> _selectedTags;
  late int _spicy;
  late int _sweet;
  late bool _noCoriander;
  late bool _noPeanut;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pref = await _repo.load();
      if (mounted) {
        setState(() {
          _pref = pref;
          _selectedTags = pref.tags.toSet();
          _spicy = pref.spicyLevel;
          _sweet = pref.sweetLevel;
          _noCoriander = pref.noCoriander;
          _noPeanut = pref.noPeanut;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repo.save(UserPreference(
        tags: _selectedTags.toList(),
        spicyLevel: _spicy,
        sweetLevel: _sweet,
        noCoriander: _noCoriander,
        noPeanut: _noPeanut,
        allergens: _pref?.allergens ?? [],
        preferenceText: '',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('偏好已保存，将影响 AI 推荐')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reset() {
    setState(() {
      _selectedTags = {'清淡', '家常菜'};
      _spicy = 3;
      _sweet = 2;
      _noCoriander = false;
      _noPeanut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的口味偏好'),
        actions: [
          IconButton(onPressed: _reset, icon: const Icon(Icons.restart_alt)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  title: '偏好标签',
                  subtitle: '选择你常吃和喜欢的口味（可多选）',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allTags.map((tag) {
                      final active = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: active,
                        onSelected: (_) {
                          setState(() {
                            if (active) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFFFF2E0),
                        checkmarkColor: const Color(0xFFD86A00),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  title: '口味强度',
                  child: Column(
                    children: [
                      _rangeRow('辣度偏好', _spicy, (v) => setState(() => _spicy = v)),
                      const SizedBox(height: 12),
                      _rangeRow('甜度偏好', _sweet, (v) => setState(() => _sweet = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  title: '忌口与过滤',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('不吃香菜'),
                        value: _noCoriander,
                        onChanged: (v) => setState(() => _noCoriander = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('过滤花生过敏'),
                        value: _noPeanut,
                        onChanged: (v) => setState(() => _noPeanut = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: const Color(0xFFFF8A43),
                  ),
                  child: Text(_saving ? '保存中…' : '保存偏好（同步 Agent）'),
                ),
              ],
            ),
    );
  }

  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF1F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6F7888))),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _rangeRow(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('$value / 5', style: const TextStyle(color: Color(0xFFFF7A21), fontWeight: FontWeight.w800)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: const Color(0xFFFF8D40),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
