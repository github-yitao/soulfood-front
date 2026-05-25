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
| DELETE | `/ai/chat/{conversationId}` | `AiChatPage` 清空对话 |
| POST | `/ai/recommend/recipes` | `RecipeResultPage` / `AiQuickPage` |
| POST | `/ai/suggest-options` | `VotePage` |
| POST | `/ai/random-pick` | `NearbyPage` |
| GET | `/ai/chat/stream` | 预留流式 |

`POST /ai/chat` 请求体：

```json
{ "message": "今晚吃什么", "conversationId": "optional-uuid" }
```

响应：

```json
{ "conversationId": "uuid", "reply": "..." }
```

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
