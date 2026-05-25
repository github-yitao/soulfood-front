import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';

/// 首页「帮我决定」— 直接 AI 推荐菜谱
class AiQuickPage extends StatefulWidget {
  const AiQuickPage({super.key});

  @override
  State<AiQuickPage> createState() => _AiQuickPageState();
}

class _AiQuickPageState extends State<AiQuickPage> {
  final _agent = AgentRepository();
  final _prefRepo = PreferenceRepository();
  List<RecipeItem> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pref = await _prefRepo.preferenceText();
      final items = await _agent.recommendRecipes(preference: pref);
      if (mounted) setState(() => _recipes = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 帮我决定'),
        actions: [
          TextButton(onPressed: _loading ? null : _load, child: const Text('换一批')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final item = _recipes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(item.reason),
                    trailing: Text('${item.score}分'),
                  ),
                );
              },
            ),
    );
  }
}
