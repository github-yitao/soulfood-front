import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';

class RecipeResultPage extends StatefulWidget {
  const RecipeResultPage({super.key, this.voteWinner});

  final String? voteWinner;

  @override
  State<RecipeResultPage> createState() => _RecipeResultPageState();
}

class _RecipeResultPageState extends State<RecipeResultPage> {
  final _repo = AgentRepository();
  List<RecipeItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      var pref = '清淡、家常菜';
      if (widget.voteWinner != null && widget.voteWinner!.isNotEmpty) {
        pref = '$pref、投票胜出：${widget.voteWinner}';
      }
      final items = await _repo.recommend(preference: pref);
      if (mounted) setState(() => _items = items);
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
        title: const Text('推荐菜谱'),
        actions: [
          TextButton(onPressed: _loading ? null : _load, child: const Text('换一批')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.reason, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text('${item.score}分'),
                );
              },
            ),
    );
  }
}
