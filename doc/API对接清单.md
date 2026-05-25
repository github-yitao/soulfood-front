# DecideMeal API 对接清单

> 后端 Base URL：`lib/core/config/app_config.dart`（可用 `--dart-define=API_BASE_URL=...` 覆盖）  
> 请求头：`X-User-Id`（Mock 登录后自动带上）

## P0 已对接

| 模块 | 方法 | 路径 | Flutter |
|------|------|------|---------|
| 登录 | POST | `/api/v1/auth/login/mock` | `AppBootstrap` |
| 我的 | GET | `/api/v1/auth/me` | `ProfilePage` |
| 创建房间 | POST | `/api/v1/rooms` | `CreateRoomPage` |
| 加入房间 | POST | `/api/v1/rooms/{code}/join` | `JoinRoomPage` |
| 房间详情 | GET | `/api/v1/rooms/{code}` | `VotePage` |
| 添加选项 | POST | `/api/v1/rooms/{code}/options` | `VotePage` |
| 投票 | POST | `/api/v1/rooms/{code}/votes` | `VotePage` |
| 投票结果 | GET | `/api/v1/rooms/{code}/result` | `RecipeResultPage` |
| 附近餐厅 | GET | `/api/v1/restaurants/nearby` | `NearbyPage` |
| 想去 | POST | `/api/v1/restaurants/{id}/want` | `NearbyPage` |
| 记录概览 | GET | `/api/v1/records/overview` | `RecordsPage` |

## AI 已对接

| 方法 | 路径 | Flutter |
|------|------|---------|
| POST | `/ai/recommend/recipes` | `RecipeResultPage` / `AiQuickPage` |
| POST | `/ai/suggest-options` | `VotePage` AI 补选项 |
| POST | `/ai/random-pick` | `NearbyPage` 随机帮我选 |
| POST | `/ai/chat` | 预留 |
| GET | `/ai/recommend` | 兼容旧接口 |

## P1 已对接（本次）

| 模块 | 方法 | 路径 | Flutter |
|------|------|------|---------|
| 口味偏好 | GET | `/api/v1/users/me/preferences` | `PreferencePage` |
| 口味偏好 | PUT | `/api/v1/users/me/preferences` | `PreferencePage` |
| 收藏列表 | GET | `/api/v1/favorites?type=` | `FavoritesPage` |
| 添加收藏 | POST | `/api/v1/favorites` | `RecipeResultPage` |
| 取消收藏 | DELETE | `/api/v1/favorites/{id}` | `FavoritesPage` |
| 订单概览 | GET | `/api/v1/orders/overview?category=` | `OrdersPage` |

偏好 `preferenceText` 已接入 `RecipeResultPage`、`AiQuickPage` 的 AI 推荐请求。

## P2 待做

| 模块 | 说明 | 原型页 |
|------|------|--------|
| 设置 | 通知、账号 | 10-setting |
| 外观 | 主题切换 | 11-appearance |
| 邀请好友 | 邀请码/分享 | 15-invite-friends |
| 关于我们 | 静态页 | 16-about-us |
| 启动页 | Splash | 01-splash |
| AI 对话 | `/ai/chat` UI + conversationId | — |
| 微信登录 | `/api/v1/auth/login/wechat` | — |
