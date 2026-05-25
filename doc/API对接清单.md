# DecideMeal API 对接清单

> 后端 Base URL：`lib/core/config/app_config.dart`  
> 登录后请求头：`X-User-Id: <userId>`

## 鉴权（账号密码）

| 方法 | 路径 | Flutter |
|------|------|---------|
| POST | `/api/v1/auth/register` | `RegisterPage` |
| POST | `/api/v1/auth/login` | `LoginPage` |
| GET | `/api/v1/auth/me` | `ProfilePage` |
| POST | `/api/v1/auth/login/mock` | 仅开发调试 |

注册/登录请求体示例：

```json
{ "username": "demo01", "password": "123456", "nickname": "昵称", "inviteCode": "DM123456" }
```

## P0 业务

| 模块 | 方法 | 路径 | Flutter |
|------|------|------|---------|
| 创建房间 | POST | `/api/v1/rooms` | `CreateRoomPage` |
| 加入房间 | POST | `/api/v1/rooms/{code}/join` | `JoinRoomPage` |
| 房间详情 | GET | `/api/v1/rooms/{code}` | `VotePage` |
| 投票/选项 | POST | `/api/v1/rooms/{code}/votes` 等 | `VotePage` |
| 附近餐厅 | GET | `/api/v1/restaurants/nearby` | `NearbyPage` |
| 记录概览 | GET | `/api/v1/records/overview` | `RecordsPage` |

## P1 体验

| 模块 | 方法 | 路径 | Flutter |
|------|------|------|---------|
| 口味偏好 | GET/PUT | `/api/v1/users/me/preferences` | `PreferencePage` |
| 收藏 | GET/POST/DELETE | `/api/v1/favorites` | `FavoritesPage` / `RecipeResultPage` |
| 订单 | GET | `/api/v1/orders/overview` | `OrdersPage` |

## P2 增长与设置

| 模块 | 方法 | 路径 | Flutter |
|------|------|------|---------|
| 邀请 | GET | `/api/v1/invites/overview` | `InvitePage` |
| 外观 | 本地 | SharedPreferences | `AppearancePage` |
| 设置/关于 | 本地 | — | `SettingsPage` / `AboutPage` |
| 启动 | — | — | `SplashPage` → 登录或首页 |

## AI

| 方法 | 路径 | Flutter |
|------|------|---------|
| POST | `/ai/recommend/recipes` | `RecipeResultPage` / `AiQuickPage` |
| POST | `/ai/suggest-options` | `VotePage` |
| POST | `/ai/random-pick` | `NearbyPage` |
| POST | `/ai/chat` | 待做 UI |

## 待做

- AI 对话页 + conversationId 持久化
- JWT / Token 鉴权（当前仍用 X-User-Id）
