# DecideMeal 前后端开发计划

> 基于 `doc/html/decidemeal-pages` 原型与 `doc/product/decidemeal-单体功能分块.md` 整理。  
> 后端现状：`soulfood-backed` 已具备 Spring AI 对话与推荐接口；前端以 Flutter 为主，HTML 为交互原型。

---

## 1. 目标与范围

| 维度 | 目标 |
|------|------|
| 产品 | 完成「建房 → 投票 → 出结果 → 菜谱/探店」闭环，AI 辅助决策与推荐 |
| 前端 | Flutter App 对齐 18 个原型页；HTML 原型可演示 Agent 调用 |
| 后端 | 单体 Spring Boot：业务 API + 已有 `/ai` Agent 层 |
| MVP | P0 功能块 + Agent 菜谱推荐、随机吃什么 |

---

## 2. 原型页面索引

| 页面 | 路径 | 功能块 | Agent 触点 |
|------|------|--------|------------|
| 启动 | `01-splash.html` | 主入口 | — |
| 首页 | `02-home.html` | 主入口 | AI 一键决策入口 |
| 组局说明 | `03-friends.html` | 组局投票 | — |
| 投票房 | `04-vote.html` | 组局投票 | AI 补选项、生成菜谱 |
| 附近觅食 | `05-cook-mode.html` | 餐厅发现 | AI 推荐附近店 |
| 菜谱结果 | `06-result.html` | 菜谱推荐 | **核心**：推荐/换一批 |
| 随机吃 | `07-nearby.html` | 餐厅发现 | AI 随机决策 |
| 记录 | `08-record.html` | 记录订单 | — |
| 我的 | `09-mine.html` | 个人信息 | — |
| 设置/外观 | `10-11` | 设置 | — |
| 收藏/偏好 | `12-13` | 偏好 | 偏好写入 Agent 上下文 |
| 订单/邀请/关于 | `14-16` | P2 | — |
| 建房/入房 | `17-18` | 组局投票 | — |

共享脚本：`assets/agent.js`（封装 `/ai/chat`、`/ai/recommend`，失败时 Mock）。

---

## 3. 架构总览

```mermaid
flowchart TB
  subgraph client [客户端]
    HTML[HTML 原型]
    Flutter[Flutter App]
  end
  subgraph api [soulfood-backed 单体]
    Gateway[REST /soulfood/*]
    Biz[业务模块 待建]
    AI[/ai Agent 已实现]
  end
  subgraph infra [基础设施]
    PG[(PostgreSQL)]
    Redis[(Redis 规划)]
    LLM[智谱 GLM-4-flash]
  end
  HTML --> Gateway
  Flutter --> Gateway
  Gateway --> Biz
  Gateway --> AI
  Biz --> PG
  AI --> LLM
  Biz --> Redis
```

---

## 4. 前端开发计划（Flutter）

### 4.1 模块划分（按功能块）

| 模块 | 目录建议 | 原型页 | 优先级 |
|------|----------|--------|--------|
| `core` | 路由、主题、HTTP、鉴权 | 全局 | P0 |
| `home` | 首页三入口 | 02 | P0 |
| `room` | 建房/入房/投票/结果 | 03,17,18,04,06 | P0 |
| `nearby` | 附近觅食、随机吃 | 05,07 | P0 |
| `agent` | AI 推荐、流式对话 | 06,07,04 | P0 |
| `preference` | 口味、收藏 | 12,13 | P1 |
| `record` | 记录、订单 | 08,14 | P1 |
| `profile` | 我的、设置、外观 | 09-11 | P1 |
| `growth` | 邀请、关于 | 15-16 | P2 |

### 4.2 关键实现任务

**P0 — MVP（约 3–4 周）**

1. **基础框架**：`dio`/`http` 客户端、`ApiResponse<T>`、Token 拦截、环境配置（dev/prod baseUrl）。
2. **首页**：三大入口导航；底部 Tab（首页/记录/我的）。
3. **组局投票**：创建房间表单、6 位房间号加入、投票列表 WebSocket 或轮询（先 REST 轮询）、结果页跳转。
4. **附近觅食**：列表 + 品类 Chip + 搜索；「想去」本地状态；发起投票带候选 ID。
5. **Agent 模块**：
   - 封装 `AgentRepository`：`recommend(preference)`、`chat(message, conversationId?)`。
   - 结果页解析 AI 文本为 `RecipeItem` 列表（正则/JSON 模式二选一，与后端约定）。
   - Loading / 错误 / 重试 UI；conversationId 持久化。
6. **启动页**：品牌展示 → 首页（可跳过登录占位）。

**P1 — 体验（约 2 周）**

7. 口味偏好 CRUD，保存后合并进 Agent `preference` 参数。
8. 收藏同步（菜谱、餐厅）。
9. 记录时间线、订单列表（静态 Mock → API）。

**P2 — 增长与完善**

10. 邀请码、分享渠道、主题/外观设置。

### 4.3 Agent 前端契约

```dart
// 与 HTML agent.js、后端 AiChatController 对齐
class AgentRepository {
  Future<ChatResponse> chat({String? conversationId, required String message});
  Future<String> recommend({required String preference});
  Stream<String> chatStream({String? conversationId, required String message});
}
```

- `baseUrl`: `http://host:8080/soulfood`
- 结果页进入前：`sessionStorage` / `SharedPreferences` 写入 `voteContext`（选项、胜出项、人数）

### 4.4 HTML 原型（当前迭代）

- 已增加 `assets/agent.js` + `app.css` Agent 样式。
- 已接线页面：02、04、05、06、07、13。
- 本地调试：后端启动后，在控制台执行 `SoulFoodAgent.setBaseUrl('http://localhost:8080/soulfood')`；跨域需后端配置 CORS。

---

## 5. 后端开发计划（Spring Boot）

### 5.1 现状

| 能力 | 状态 | 路径 |
|------|------|------|
| AI 对话 | ✅ | `POST /ai/chat` |
| 流式对话 | ✅ | `GET /ai/chat/stream` |
| 会话历史/清空 | ✅ | `GET/DELETE /ai/chat/{id}/...` |
| 快捷推荐 | ✅ | `GET /ai/recommend?preference=` |
| 组局/餐厅/用户 | ❌ 待建 | — |

`context-path`: `/soulfood`  
AI：`spring-ai` + 智谱 `glm-4-flash`，系统提示词见 `AiConfig`。

### 5.2 模块规划（单体包结构）

```
com.food.soulfoodbackend
├── config/          # 安全、CORS、Redis、MyBatis
├── controller/
│   ├── AiChatController.java      # 已有
│   ├── AuthController.java        # P0
│   ├── RoomController.java        # P0 组局
│   ├── VoteController.java        # P0
│   ├── RestaurantController.java  # P0 附近
│   └── UserPreferenceController.java # P1
├── service/
├── domain/entity + mapper/
└── dto/
```

### 5.3 P0 业务接口清单

#### 鉴权 ` /api/v1/auth`

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/login/wechat` | 微信 code 换 token（或 Mock） |
| POST | `/refresh` | 刷新 token |
| GET | `/me` | 当前用户 |

#### 房间 ` /api/v1/rooms`

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/` | 创建房间（主题、人数、时长） |
| POST | `/{code}/join` | 加入 |
| GET | `/{code}` | 房间详情 + 选项 + 票数 |
| POST | `/{code}/options` | 添加选项（含 AI 生成标记） |

#### 投票 ` /api/v1/rooms/{code}/votes`

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/` | 投票 |
| GET | `/result` | 胜出选项 |

#### 餐厅 ` /api/v1/restaurants/nearby`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/` | 经纬度 + 品类 + 关键词 |
| POST | `/{id}/want` | 想去 |

#### Agent 增强 ` /ai`（在现有基础上扩展）

| 方法 | 路径 | 说明 | 优先级 |
|------|------|------|--------|
| GET | `/recommend` | 已有：文本推荐 | ✅ |
| POST | `/recommend/recipes` | 结构化返回 `{items:[{name,score,reason}]}` | ✅ |
| POST | `/suggest-options` | 根据主题生成投票选项 | ✅ |
| POST | `/random-pick` | 从候选店/菜中决策 | ✅ |
| POST | `/chat` | 已有 | ✅ |

**`POST /ai/recommend/recipes` 请求体示例：**

```json
{
  "preference": "微辣、家常菜、不吃香菜",
  "voteWinner": "火锅",
  "participants": 4,
  "conversationId": "optional-uuid"
}
```

**响应示例：**

```json
{
  "conversationId": "uuid",
  "items": [
    {"name": "番茄炒蛋", "score": 4.8, "reason": "清淡下饭"},
    {"name": "土豆丝炒肉", "score": 4.6, "reason": "家常菜"}
  ],
  "rawReply": "..."
}
```

实现建议：`AiChatService` 增加 `recommendStructured`，Prompt 要求 **仅输出 JSON**，再用 Jackson 解析；失败时降级为文本 + 前端解析。

### 5.4 P1 接口（摘要）

- `GET/PUT /api/v1/users/me/preferences` — 口味标签、辣度、忌口
- `GET/POST/DELETE /api/v1/favorites`
- `GET /api/v1/records`、`GET /api/v1/orders`

### 5.5 非功能需求

- 统一响应：`{code, message, data, traceId}`
- Agent 限流：用户级 20 次/分钟；IP 级兜底
- 敏感配置：`api-key` 迁到环境变量，禁止提交仓库
- CORS：允许原型 `file://` 或本地静态服务域名
- 会话记忆：生产改 Redis `ChatMemory`（当前 InMemory）

### 5.6 数据模型（P0 核心表）

> **已实现**：Flyway `V1__init_decidemeal_schema.sql`，数据库与 schema 均为 `food`，表前缀 `sf_`。详见 `soulfood-backed/src/main/resources/db/README.md`。

| 表 | 主要字段 |
|----|----------|
| `sf_user` | id, open_id, nickname, avatar_url, signature |
| `sf_room` | id, code(6), topic, max_people, duration_min, status, owner_id |
| `sf_room_option` | id, room_id, title, vote_count, source(manual/ai) |
| `sf_vote` | id, room_id, option_id, user_id |
| `sf_restaurant` | id, name, category, lat, lng, rating |
| `sf_user_preference` | user_id, tags_json, spicy_level, sweet_level, allergens_json |
| `sf_favorite` / `sf_order` / `sf_activity_record` / `sf_invite` / `sf_restaurant_want` | P1 扩展表，见迁移脚本 |

---

## 6. Agent 场景与 Prompt 设计

| 场景 | 触发页 | API | Prompt 要点 |
|------|--------|-----|-------------|
| 菜谱推荐 | 06-result | `/ai/recommend` 或 `/recommend/recipes` | 投票胜出菜 + 用户偏好 + 3 道菜 |
| 换一批 | 06-result | 同上 + `regenerate=true` | 避免与上一轮重复 |
| 投票补选项 | 04-vote | `/ai/suggest-options`（待建） | 房间主题 → 2–4 个选项 |
| 随机吃什么 | 07-nearby | `/ai/random-pick`（待建） | 列表名称 → 1 个决策 + 理由 |
| 附近 AI 排序 | 05-cook-mode | `/ai/chat` | 距离+偏好重排推荐理由 |
| 偏好沉淀 | 13-taste | localStorage → 各 Agent 请求 | 标签、辣度、忌口拼接 |

---

## 7. 里程碑排期

| 阶段 | 周期 | 前端 | 后端 | 验收 |
|------|------|------|------|------|
| **M1 MVP** | 3–4 周 | 首页+组局+结果页+Agent 模块 | 房间/投票/餐厅 CRUD + Agent 结构化 | 能建房投票并 AI 出菜谱 |
| **M2 体验** | 2 周 | 偏好/收藏/记录 | 偏好/收藏/订单 API | 推荐带个性化 |
| **M3 增长** | 2 周 | 邀请/设置/关于 | 邀请码、配置中心 | 可分享拉新 |

---

## 8. 联调与环境

```bash
# 后端
cd soulfood-backed && ./mvnw spring-boot:run
# 健康检查
curl "http://localhost:8080/soulfood/ai/recommend?preference=微辣,家常菜"

# HTML 原型（避免 file:// CORS，建议静态服务）
cd soulfood-front/doc/html/decidemeal-pages && python3 -m http.server 5500
# 浏览器打开 http://localhost:5500/06-result.html
```

---

## 9. 风险与依赖

- **CORS**：HTML 直连本地 API 需 `WebMvcConfigurer` 放行。
- **Agent 输出不稳定**：优先推动结构化 JSON 接口，前端勿强依赖正则。
- **地图/POI**：附近餐厅 P0 可用静态数据，P1 接高德/腾讯 POI。
- **实时投票**：P0 轮询；P1 WebSocket。

---

## 10. 交付物清单

- [x] 本计划文档
- [x] HTML `agent.js` + 关键页 Agent 交互
- [ ] 后端 `RecommendRecipesRequest/Response` DTO 与实现
- [ ] Flutter `agent` + `room` 模块
- [ ] OpenAPI / Apifox 接口文档导出

---

*文档版本：v1.0 | 与原型 commit 同步维护*
