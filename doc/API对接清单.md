# DecideMeal API 对接清单（非 AI）

> AI 接口（`/ai/*`）下一阶段再接入 Flutter。

## 后端 Base URL

默认：`https://wine-doug-broadcast-downloading.trycloudflare.com/soulfood`  
（见 `lib/core/config/app_config.dart`，可用 `--dart-define=API_BASE_URL=...` 覆盖）

请求头：`X-User-Id: <userId>`（Mock 登录后由客户端自动带上）

## 已对接

| 模块 | 方法 | 路径 | Flutter |
|------|------|------|---------|
| 登录 | POST | `/api/v1/auth/login/mock` | `AppBootstrap` 启动自动调用 |
| 我的 | GET | `/api/v1/auth/me` | `ProfilePage` |
| 创建房间 | POST | `/api/v1/rooms` | `CreateRoomPage` |
| 加入房间 | POST | `/api/v1/rooms/{code}/join` | `JoinRoomPage` |
| 房间详情 | GET | `/api/v1/rooms/{code}` | `VotePage`（含下拉刷新） |
| 添加选项 | POST | `/api/v1/rooms/{code}/options` | `VotePage` |
| 投票 | POST | `/api/v1/rooms/{code}/votes` | `VotePage` |
| 投票结果 | GET | `/api/v1/rooms/{code}/result` | `RecipeResultPage`（含 AI 菜谱） |
| 附近餐厅 | GET | `/api/v1/restaurants/nearby` | `NearbyPage` |
| 想去 | POST | `/api/v1/restaurants/{id}/want` | `NearbyPage` 点击卡片 |
| 记录概览 | GET | `/api/v1/records/overview` | `RecordsPage` |

## AI 已对接

| 方法 | 路径 | Flutter |
|------|------|---------|
| POST | `/ai/recommend/recipes` | `RecipeResultPage` / `AiQuickPage` |
| POST | `/ai/suggest-options` | `VotePage` AI 补选项 |
| POST | `/ai/random-pick` | `NearbyPage` 随机帮我选 |
| POST | `/ai/chat` | 预留 |
| GET | `/ai/recommend` | 兼容旧接口 |
