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
{ "conversationId": "uuid", "reply": "...", "cards": [] }
```

`POST /ai/chat/stream` 产出 NDJSON，每行一个 JSON。旧客户端只处理 `chunk` / `done`；不认识的 `type` 应忽略。

| type | 字段 | 说明 |
|------|------|------|
| `workflow` | `runId`, `title`, `status` | 流程总状态：`running` / `done` / `failed` |
| `step` | `runId`, `id`, `title`, `status`, `summary?` | 步骤：`pending` / `running` / `done` / `failed` / `waiting` |
| `chunk` | `text` | 增量正文 |
| `cards` | `items` | 中间结果卡（P0 知识检索通常不发，终态在 `done`） |
| `done` | `conversationId`, `cards` | 结束；`cards` 与旧结果卡兼容：`recipe` / `restaurant` / `vote_room` |

P0 知识检索流示例：`workflow` → `step(running)` → `step(done)` → 若干 `chunk` → `done`。

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
