import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';

enum LegalDocumentType { terms, privacy }

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.type});

  final LegalDocumentType type;

  String get _title => switch (type) {
        LegalDocumentType.terms => '用户协议',
        LegalDocumentType.privacy => '隐私政策',
      };

  String get _content => switch (type) {
        LegalDocumentType.terms => _termsContent,
        LegalDocumentType.privacy => _privacyContent,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Markdown(
        data: _content,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        styleSheet: MarkdownStyleSheet(
          h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          p: TextStyle(height: 1.6, color: colors.textSecondary),
        ),
      ),
    );
  }
}

const _termsContent = '''
## DecideMeal 用户协议

更新日期：2026-05-25

欢迎使用 DecideMeal（「本应用」）。注册或使用本应用，即表示你同意以下条款。

### 1. 服务说明
本应用提供吃饭决策辅助服务，包括组局投票、附近餐厅发现、AI 推荐等。部分功能依赖第三方地图与 AI 服务。

### 2. 账号与安全
你应妥善保管账号密码，对账号下的行为负责。请勿将账号借给他人或用于违法用途。

### 3. 用户内容
你在应用中提交的昵称、偏好、对话内容等，仅用于提供和改进服务。请勿上传违法、侵权或骚扰性内容。

### 4. AI 生成内容
AI 推荐仅供参考，不构成医疗、营养或消费建议。外出就餐请自行核实餐厅信息与价格。

### 5. 服务变更
我们可能更新功能或暂停部分服务，并尽力提前通知重大变更。

### 6. 联系我们
如有疑问，请联系：support@decidemeal.app
''';

const _privacyContent = '''
## DecideMeal 隐私政策

更新日期：2026-05-25

我们重视你的隐私。本政策说明我们如何收集、使用和保护你的信息。

### 1. 我们收集的信息
- **账号信息**：用户名、昵称、密码（加密存储）
- **偏好与收藏**：口味标签、收藏餐厅/菜谱
- **位置信息**：仅在「附近觅食」等功能中，经你授权后用于推荐附近餐厅
- **AI 对话与记忆**：用于个性化推荐，你可随时在「AI 记忆」中查看或删除

### 2. 信息的使用
用于提供投票、推荐、记录等核心功能，以及改进产品体验。我们不会出售你的个人信息。

### 3. 第三方服务
我们可能使用高德地图、智谱 AI 等第三方服务，相关数据按各平台政策处理。

### 4. 数据存储与安全
数据存储于受保护的服务器，采用 HTTPS 传输与访问控制。请妥善保管登录凭证。

### 5. 你的权利
你可查看、修改个人资料，删除 AI 记忆，或通过设置联系我们申请注销账号（功能陆续开放）。

### 6. 联系我们
隐私相关问题：support@decidemeal.app
''';
