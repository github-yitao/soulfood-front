import 'package:flutter/material.dart';
import 'package:soulfood_front/features/recipe/recipe_detail_page.dart';
import 'package:soulfood_front/features/recipe/recipe_repository.dart';

class RecipeLibraryPage extends StatefulWidget {
  const RecipeLibraryPage({super.key});

  @override
  State<RecipeLibraryPage> createState() => _RecipeLibraryPageState();
}

class _RecipeLibraryPageState extends State<RecipeLibraryPage> {
  final _repo = RecipeRepository();
  final _searchCtrl = TextEditingController();
  List<RecipeSummary> _items = [];
  String _category = 'all';
  bool _loading = true;

  static const _chips = <Map<String, String>>[
    {'id': 'all', 'label': '全部'},
    {'id': '家常菜', 'label': '家常菜'},
    {'id': '川菜', 'label': '川菜'},
    {'id': '素菜', 'label': '素菜'},
    {'id': '汤羹', 'label': '汤羹'},
    {'id': '硬菜', 'label': '硬菜'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.list(
        category: _category == 'all' ? null : _category,
        keyword: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(RecipeSummary item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailPage(recipeId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('菜品库')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索菜名或分类',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _load();
                  },
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = _chips[index];
                return ChoiceChip(
                  label: Text(chip['label']!),
                  selected: _category == chip['id'],
                  onSelected: (_) {
                    setState(() => _category = chip['id']!);
                    _load();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading && _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                      ],
                    )
                  : _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(
                              height: 200,
                              child: Center(child: Text('暂无菜谱', style: TextStyle(color: Color(0xFF8D919A)))),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFFFEFBC),
                                  child: Text(
                                    item.name.isNotEmpty ? item.name.substring(0, 1) : '?',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  '${item.category} · ${item.difficulty} · ${item.durationMin} 分钟',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${item.score}'),
                                    const Icon(Icons.chevron_right, color: Color(0xFFB3B8C2)),
                                  ],
                                ),
                                onTap: () => _openDetail(item),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
