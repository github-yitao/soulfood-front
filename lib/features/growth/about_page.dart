import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8EB), Color(0xFFFFFFFF), Color(0xFFF7F9FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDF1F6)),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD36E), Color(0xFFFF9F5A)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.ramen_dining, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 10),
                const Text('DecideMeal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  '让选择变得更简单。\n专注于「今天吃什么」的轻决策工具。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6F7888), height: 1.5),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE6EBF3)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF5F697A))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('我们在做什么', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    '通过偏好管理、历史记录、好友协作投票，帮助你快速完成吃饭决策。项目处于早期阶段，我们会持续迭代体验与稳定性。',
                    style: TextStyle(color: Color(0xFF5F697A), height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'DecideMeal Team\nCopyright © 2026',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF96A0B1), fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
