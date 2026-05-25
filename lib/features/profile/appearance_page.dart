import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  late AppThemeMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = AppServices.I.appearance.mode;
  }

  Future<void> _select(AppThemeMode mode) async {
    setState(() => _mode = mode);
    await AppServices.I.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('外观设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('主题模式', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          _ModeTile(
            label: '浅色模式',
            selected: _mode == AppThemeMode.light,
            onTap: () => _select(AppThemeMode.light),
          ),
          _ModeTile(
            label: '深色模式',
            selected: _mode == AppThemeMode.dark,
            onTap: () => _select(AppThemeMode.dark),
          ),
          _ModeTile(
            label: '跟随系统',
            selected: _mode == AppThemeMode.system,
            onTap: () => _select(AppThemeMode.system),
          ),
          const SizedBox(height: 16),
          const Text(
            '主题设置仅在当前设备生效',
            style: TextStyle(color: Color(0xFF8D919A), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFFFF8A43)) : null,
        onTap: onTap,
      ),
    );
  }
}
