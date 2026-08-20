# DecideMeal API 对接清单

> Base URL：`lib/core/config/app_config.dart`  
> 默认 **直连本机后端**（Android 模拟器 `10.0.2.2:8080`，iOS/macOS `127.0.0.1:8080`）  
> 真机 + Cloudflare 隧道：`flutter run --dart-define=API_BASE_URL=https://xxx.trycloudflare.com/soulfood`  
> 鉴权：`Authorization: Bearer <JWT>`（登录/注册返回的 `token`）  
> 兼容：`X-User-Id` 仍可作为开发兜底

## 鉴权

| 方法 | 路径 | Flutter |
|------|------|---------|
| POST | `/api/v1/auth/register` | `RegisterPage` |
| POST | `/api/v1/auth/login` | `LoginPage` |
| GET | `/api/v1/auth/me` | `ProfilePage` |

登录响应 `data.token` 为 JWT，客户端持久化后随请求携带。

## AI

| 方法 | 路径 | Flutter |
|------|------|---------|
| POST | `/ai/chat` | `AiChatPage` |
| POST | `/ai/chat/stream` | `AiChatPage` 流式（NDJSON） |
| GET | `/ai/chat/stream` | 预留 SSE，仅 chunk 文本 |
| POST | `/ai/workflow/{runId}/continue` | `AiChatPage` 流程卡「继续」（NDJSON） |
| DELETE | `/ai/chat/{conversationId}` | `AiChatPage` 清空对话 |
| POST | `/ai/recommend/recipes` | `RecipeResultPage` / `AiQuickPage` |
| POST | `/ai/suggest-options` | `VotePage` |
| POST | `/ai/random-pick` | `NearbyPage` |
| POST | `/ai/rag/ingest` | **开发调试**，App 不要调 |
| GET | `/ai/rag/search?q=&limit=` | **开发调试**，App 不要调 |

`POST /ai/chat` 请求体：

```json
{
  "message": "今晚吃什么",
  "conversationId": "optional-uuid",
  "lat": 30.65,
  "lng": 104.06,
  "imageBase64": "optional",
  "imageMimeType": "image/jpeg"
}
```

闲聊、知识问答（RAG 生成）和需要工具的 ReAct 都走智谱 `glm-4.7-flash`。识图仍用 `glm-4v-flash`。本地 Ollama 只负责向量：`qwen3-embedding:0.6b`（1024 维），`app.ai.rag.mode=embedding`。Ollama 需本机 `11434` 已启动且已 pull embedding 模型。

非流式响应：

```json
{ "conversationId": "uuid", "reply": "...", "cards": [], "workflow": null }
```

`workflow` 可选。`nearby_eat` / `cook_from_fridge` / `vote_room` 会带流程快照；闲聊 / RAG / ReAct 一般为 `null`。历史接口 `GET /ai/chat/{conversationId}/history` 的每条 assistant 消息同样可带 `cards` 与 `workflow`（来自 `meta_json`）。

`POST /ai/workflow/{runId}/continue` 用于 `step.status=waiting` 的续跑，鉴权同聊天。请求体：

```json
{
  "conversationId": "uuid",
  "stepId": "collect_options | vision | locate",
  "message": "可选。组局可说「确认」；看图可说「不拍图」",
  "options": ["火锅", "烧烤"],
  "imageBase64": "看图续跑可选",
  "imageMimeType": "image/jpeg",
  "lat": 30.65,
  "lng": 104.06
}
```

响应与 `POST /ai/chat/stream` 相同的 NDJSON。待确认流程写入 `sf_ai_workflow_pending`（约 7 天），内存缓存 30 分钟。组局 waiting 也可在对话里直接说「确认」或再报两个选项。无定位的附近觅食为 `locate=waiting`，授权后点流程卡或再说「附近吃什么」。ReAct 工具最多 5 次，超时 8s，失败以 JSON observation 回给模型。

`POST /ai/chat/stream` 产出 NDJSON，每行一个 JSON。旧客户端只处理 `chunk` / `done`；不认识的 `type` 应忽略。

| type | 字段 | 说明 |
|------|------|------|
| `workflow` | `runId`, `title`, `status` | 流程总状态：`running` / `done` / `failed` |
| `step` | `runId`, `id`, `title`, `status`, `summary?` | 步骤：`pending` / `running` / `done` / `failed` / `waiting` |
| `chunk` | `text` | 增量正文 |
| `cards` | `items` | 中间结果卡（附近觅食会在出店后推送） |
| `done` | `conversationId`, `cards` | 结束；`cards` 与旧结果卡兼容：`recipe` / `restaurant` / `vote_room` |

分流（服务端 `IntentRouter`，规则优先，歧义才 LLM；`confidence < 0.6` → ReAct）：

| 意图 | 行为 |
|------|------|
| `recipe_rag` | 知识检索 + 生成（P0） |
| `nearby_eat` | 固定流程：定位 → 附近搜店 → 口味过滤 → 餐厅结果卡（P1，`AiChatPage` 流程卡） |
| `cook_from_fridge` | 冰箱做菜 / 看图做菜 / 按食材做菜 / 菜单图。识图或文字食材 → 检索菜谱 → 结果卡。无图可说「不拍图」 |
| `vote_room` | 收集选项 → 创建投票房；选项不足时 `collect_options=waiting`，确认后开房 |
| `open_react` / 闲聊 | 智谱 tools（最多 5 次）或闲聊 |

P0 知识检索流示例：`workflow` → `step(running)` → `step(done)` → 若干 `chunk` → `done`。  
P1 附近觅食流示例：`workflow` → `step(locate)` → …；无定位时 `locate=waiting`（可续跑）。  
P2 看图 / 冰箱 / 按食材：有图则 `vision` → `rag_recipes` → `present_options`；无图可 waiting，或直接说「不拍图」「按食材做菜」。  
P2 组局：说清「火锅还是烤肉」会直接开房；只说「组局」则流程卡等待确认默认选项。

`POST /ai/rag/ingest` 响应 `data`：`{ "seedsUpserted": n, "recipesUpserted": n }`（内容未变则为 0）。  
`GET /ai/rag/search` 返回命中列表：`sourceType` / `sourceKey` / `title` / `content` / `distance`。

对话上下文持久化在 PostgreSQL（`sf_ai_conversation` / `sf_ai_chat_message`）；知识向量在 `sf_rag_chunk`。

## 业务 / P1 / P2

见此前章节：房间、餐厅、偏好、收藏、订单、邀请、设置等均已对接。

## 好友

| 方法 | 路径 | Flutter |
|------|------|---------|
| GET | `/api/v1/friends` | `MyFriendsPage` 好友列表 |
| POST | `/api/v1/friends` | `MyFriendsPage` 添加好友（body: `{ "inviteCode": "DM123456" }`） |
| GET | `/api/v1/rooms/friends` | `FriendsPage` 好友进行中的房间 |

注册时填写 `inviteCode` 会自动与邀请人双向绑定好友（`source=invite`）。
主动添加好友使用对方在个人页「邀请好友」中的邀请码（`source=manual`）。

## 环境变量（后端）

| 变量 | 说明 |
|------|------|
| `JWT_SECRET` | HS256 密钥（≥32 字符） |
| `JWT_EXPIRE_HOURS` | Token 有效期，默认 168h |
