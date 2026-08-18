# DecideMeal 数据表说明

> Schema：`food`（库名 `food`）。前缀 `sf_` = SoulFood / DecideMeal。  
> 来源：`soulfood-backed/src/main/resources/db/migration/` V1–V15 及后续增量。  
> 通用约定：`id` 主键；`created_at` / `updated_at` 为 `TIMESTAMPTZ`；`deleted = true` 为逻辑删除（有该列的表）。

---

## 1. 账号与关系

### `sf_user` 应用用户

| 字段 | 含义 |
|------|------|
| id | 用户主键 |
| open_id | 微信等渠道 OpenId，账号登录后可为空 |
| username | 账号登录用户名，未删除用户内唯一 |
| password_hash | BCrypt 密码哈希 |
| nickname | 昵称 |
| avatar_url | 头像地址 |
| signature | 个性签名 |
| phone | 手机号 |
| invite_code | 该用户自己的邀请码（发给别人用） |
| status | `1` 正常，`0` 禁用 |
| created_at / updated_at | 创建 / 更新时间 |
| deleted | 逻辑删除 |

### `sf_invite` 邀请记录

| 字段 | 含义 |
|------|------|
| id | 主键 |
| inviter_id | 邀请人 `sf_user.id` |
| invite_code | 当时使用的邀请码 |
| invitee_id | 被邀请人，未完成时为空 |
| status | `pending` 待完成 / `completed` 已注册 / `expired` 过期 |
| reward_status | 奖励状态，默认 `none` |
| created_at | 发起时间 |
| completed_at | 完成时间 |

同一邀请人 + 被邀请人唯一（已绑定 invitee 时）。

### `sf_friend` 好友关系

双向各存一行：A→B 与 B→A。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 关系主体 |
| friend_user_id | 对方用户，不能等于 `user_id` |
| source | `invite` 邀请注册 / `manual` 主动添加 |
| created_at | 成为好友时间 |

---

## 2. 组局投票

### `sf_room` 投票房间

| 字段 | 含义 |
|------|------|
| id | 主键 |
| code | 6 位房间号，全表唯一 |
| topic | 主题，如「今晚吃什么」 |
| max_people | 人数上限，默认 4 |
| duration_min | 有效时长（分钟） |
| status | `open` 可加入 / `voting` 投票中 / `closed` 已结束 |
| owner_id | 房主 |
| winner_option_id | 结算后的胜出选项，指向 `sf_room_option` |
| created_at / updated_at | 创建 / 更新 |
| closed_at | 关闭时间 |
| deleted | 逻辑删除 |

### `sf_room_option` 房间候选项

| 字段 | 含义 |
|------|------|
| id | 主键 |
| room_id | 所属房间 |
| title | 选项文案（店名或菜名） |
| vote_count | 得票数（可与 `sf_vote` 对账） |
| source | `manual` 人工 / `ai` Agent 生成 |
| sort_order | 展示顺序 |
| created_at / updated_at / deleted | 时间与逻辑删除 |

### `sf_vote` 投票明细

一房一人一票（`room_id + user_id` 唯一）。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| room_id | 房间 |
| option_id | 所选选项 |
| user_id | 投票人 |
| created_at | 投票时间 |

---

## 3. 餐厅、菜谱、偏好

### `sf_restaurant` 餐厅 / POI

附近觅食候选，可由高德 POI upsert。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| name | 店名 |
| category | 品类，如 `hotpot` / `bbq` / `fast` |
| address | 地址 |
| lat / lng | 纬度 / 经度 |
| rating | 评分 |
| distance_km | 相对某次查询的距离（缓存字段，非绝对地理属性） |
| external_id | 第三方地图 POI ID，非空时唯一 |
| phone | 电话 |
| photo_url | 封面图 |
| created_at / updated_at / deleted | 时间与逻辑删除 |

### `sf_restaurant_want` 「想去」标记

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 用户 |
| restaurant_id | 餐厅 |
| created_at | 标记时间 |

`(user_id, restaurant_id)` 唯一。

### `sf_recipe` 菜谱库

| 字段 | 含义 |
|------|------|
| id | 主键 |
| name | 菜名 |
| category | 分类：家常菜 / 川菜 / 素菜 / 硬菜 / 汤羹 等 |
| difficulty | 难度，如简单 / 中等 |
| duration_min | 预计耗时（分钟） |
| score | 推荐分 |
| summary | 一句话简介 |
| ingredients_json | 食材数组 JSON |
| steps_json | 步骤数组 JSON |
| created_at / updated_at / deleted | 时间与逻辑删除 |

**RAG 入库来源之一：** `name + summary + ingredients_json + steps_json` 拼成文档后切块。

### `sf_user_preference` 口味偏好

一用户一行。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 用户，唯一 |
| tags_json | 偏好标签，如 `["清淡","微辣"]` |
| spicy_level | 辣度 1–5 |
| sweet_level | 甜度 1–5 |
| no_coriander | 忌香菜 |
| no_peanut | 忌花生 |
| allergens_json | 其他过敏原数组 |
| created_at / updated_at | 时间 |

### `sf_favorite` 收藏

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 用户 |
| target_type | `recipe` / `restaurant` / `ai_reply` |
| target_id | 目标主键；AI 回复收藏可为空 |
| title | 展示标题 |
| subtitle | 副标题 |
| meta_json | 扩展（如会话 id、原文摘要） |
| created_at / deleted | 时间与逻辑删除 |

---

## 4. 记录、订单、通知

### `sf_activity_record` 行为时间线

对应「我的记录」。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 用户 |
| record_type | `vote` / `favorite` / `eat` / `ai_recommend` |
| title | 标题 |
| summary | 摘要 |
| ref_id | 关联业务 id（房间、收藏、订单等） |
| extra_json | 扩展 |
| occurred_at | 业务发生时间（列表按此倒序） |
| created_at | 写入时间 |

### `sf_order` 用餐 / 记账订单

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 用户 |
| restaurant_name | 店名（可与 `sf_restaurant` 无外键） |
| category | 品类 |
| amount | 金额 |
| item_summary | 点了什么 |
| ordered_at | 用餐时间 |
| source | `manual` 用户记账 / `demo` 示例数据 |
| created_at / deleted | 时间与逻辑删除 |

### `sf_user_notification` 站内通知

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 接收人 |
| type | 通知类型（业务自定义字符串） |
| title | 标题 |
| body | 正文 |
| payload_json | 跳转/业务载荷 |
| read_flag | 是否已读 |
| created_at / deleted | 时间与逻辑删除 |

---

## 5. 好友私聊

### `sf_friend_conversation` 一对一会话

一对用户只一行：`user_low_id < user_high_id`。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_low_id | 较小的用户 id |
| user_high_id | 较大的用户 id |
| created_at / updated_at | 创建 / 最后消息时间 |

### `sf_friend_message` 好友消息

| 字段 | 含义 |
|------|------|
| id | 主键 |
| conversation_id | 会话 |
| sender_id | 发送人 |
| message_type | `text` 纯文本 / `vote_share` 投票分享卡 |
| content | 文本正文；分享卡时可为空串 |
| payload_json | 结构化载荷（分享卡必填） |
| created_at | 发送时间 |

### `sf_friend_conversation_read` 已读游标

主键 `(conversation_id, user_id)`。

| 字段 | 含义 |
|------|------|
| conversation_id | 会话 |
| user_id | 读者 |
| last_read_message_id | 已读到的消息 id |
| updated_at | 游标更新时间 |

---

## 6. AI 对话与记忆

### `sf_ai_conversation` AI 会话

| 字段 | 含义 |
|------|------|
| id | conversationId（UUID 字符串） |
| user_id | 所属用户，可空（未登录） |
| title | 标题，通常取首条用户消息摘要 |
| scene_tag | 场景：聚餐 / 减脂 / 探店 / 日常 等 |
| created_at / updated_at | 创建 / 最后活跃 |

### `sf_ai_chat_message` AI 消息

| 字段 | 含义 |
|------|------|
| id | 主键 |
| conversation_id | 会话 id |
| sort_order | 会话内顺序 |
| message_type | `USER` / `ASSISTANT` / `SYSTEM` / `TOOL` |
| content | 文本内容 |
| meta_json | 扩展：结果卡、后续可存流程卡快照 |
| created_at | 写入时间 |

### `sf_ai_user_memory` 用户分层记忆（非向量）

| 字段 | 含义 |
|------|------|
| id | 主键 |
| user_id | 用户 |
| memory_type | `long_term` 长期偏好 / `episodic` 近期经历 |
| content | 记忆正文，最长 512 |
| source | `auto` / `user` / `conversation` / `activity` |
| source_ref | 来源引用（会话 id 等） |
| created_at / updated_at | 时间 |

第一期 RAG **不**把本表写入向量；Agent 仍按用户 + 类型拉取后拼 prompt。

---

## 7. `sf_rag_chunk` RAG 知识切片（V16）

知识切片，供向量检索。启动时若 `app.ai.rag.ingest-on-startup=true` 会写入 FAQ/常识种子与 `sf_recipe` 切块。

| 字段 | 含义 |
|------|------|
| id | 主键 |
| source_type | `recipe` / `faq` / `common` |
| source_id | 菜谱 id；FAQ/常识为空 |
| source_key | 稳定键，唯一。FAQ 如 `faq.room.join`，菜谱如 `recipe.1` |
| title | 标题 |
| content | 可检索正文 |
| embedding | `vector(1024)`，与 `embedding-3` 维度锁定 |
| created_at | 写入时间 |

---

## 8. 表关系简图

```text
sf_user
  ├─ sf_user_preference          1:1
  ├─ sf_favorite / sf_order / sf_activity_record / sf_user_notification
  ├─ sf_invite / sf_friend
  ├─ sf_friend_conversation ── sf_friend_message
  │                         └─ sf_friend_conversation_read
  ├─ sf_room (owner) ── sf_room_option ── sf_vote
  ├─ sf_restaurant_want ── sf_restaurant
  └─ sf_ai_conversation ── sf_ai_chat_message
       └─ sf_ai_user_memory

sf_recipe  ──(P0 ingest)──►  sf_rag_chunk (source_type=recipe)
种子 FAQ/常识 ──(P0 ingest)──►  sf_rag_chunk (faq | common)
```
