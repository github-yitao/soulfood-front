import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.preferenceTitle),
        actions: [
          IconButton(onPressed: _reset, icon: const Icon(Icons.restart_alt)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppSectionCard(
                  title: l10n.preferenceTags,
                  subtitle: '选择你常吃和喜欢的口味（可多选）',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allTags.map((tag) {
                      final active = _selectedTags.contains(tag);
                      return AppFilterChip(
                        label: tag,
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
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                AppSectionCard(
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
                AppSectionCard(
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
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(_saving ? '保存中…' : '保存偏好（同步 Agent）'),
                ),
              ],
            ),
    );
  }

  Widget _rangeRow(String label, int value, ValueChanged<int> onChanged) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text('$value / 5', style: TextStyle(color: colors.accent, fontWeight: FontWeight.w800)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
