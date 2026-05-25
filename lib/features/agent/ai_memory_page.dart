import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';

class AiMemoryPage extends StatefulWidget {
  const AiMemoryPage({super.key});

  @override
  State<AiMemoryPage> createState() => _AiMemoryPageState();
}

class _AiMemoryPageState extends State<AiMemoryPage> {
  final _agent = AgentRepository();
  final _inputCtrl = TextEditingController();

  List<AiUserMemoryItem> _items = [];
  bool _loading = true;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _agent.listMemories(memoryType: _filterType);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addMemory() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      await _agent.addMemory(content: text);
      _inputCtrl.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已添加记忆，后续对话会自动参考')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _delete(AiUserMemoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记忆'),
        content: Text('确定删除「${item.content}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _agent.deleteMemory(item.id);
      if (mounted) setState(() => _items.removeWhere((e) => e.id == item.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 记忆'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              '助手会记住你的饮食偏好和近期经历，让推荐越来越懂你。'
              '对话中明确说出的习惯也会自动提取为长期记忆。',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _FilterChip(
                  label: '全部',
                  selected: _filterType == null,
                  onTap: () {
                    setState(() => _filterType = null);
                    _load();
                  },
                ),
                _FilterChip(
                  label: '长期记忆',
                  selected: _filterType == 'long_term',
                  onTap: () {
                    setState(() => _filterType = 'long_term');
                    _load();
                  },
                ),
                _FilterChip(
                  label: '近期经历',
                  selected: _filterType == 'episodic',
                  onTap: () {
                    setState(() => _filterType = 'episodic');
                    _load();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _items.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    '暂无记忆\n可在下方手动添加，或通过对话自动积累',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFF8D919A)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item.content),
                                  subtitle: Text(item.typeLabel),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _delete(item),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      decoration: InputDecoration(
                        hintText: '手动添加记忆，如「不吃香菜」',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addMemory(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addMemory,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A43)),
                    child: const Text('添加'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
