---
name: commander-calendar
description: Create and manage Commander Dashboard calendar events via Supabase REST API. Use when the user asks to create, update, or manage calendar events in the Commander Dashboard (主宰面板) — including simple events (e.g. "下周三上午9点开会") and complex multi-step events requiring rich detail pages (trips with transit, packing lists, timelines). For simple events, create a basic entry with title/time/description. For complex events, generate structured detail_html with packing tags and timeline views. Not for iPhone calendar — only for Commander Dashboard.
---

# Event Detail Creator

## Decision Tree

When the user asks to create an event, first determine complexity:

```
用户说 "帮我创建/安排/记一个事件"
                           │
          ┌────────────────┴────────────────┐
          │                                 │
    简单事件                           复杂事件
  (一句话能说完)                   (多步骤/需出行/多信息点)
          │                                 │
          │                                 │
   只写 title+date+                生成完整 detail_html
   ±time±description               + packing tags + 时间线
   (不写 detail_html)              + AI 推理补齐
```

**简单事件判断标准：**
- 只有时间和标题，没有交通、物品、地点等细节
- 例子："下周三上午9点开会，内容是讨论公众号选题"
- 例子："周六下午3点接妹妹放学"
- 做法：直接 INSERT 到 Supabase，只填 `title` `event_date` `start_time` `description`（纯文本），`detail_html` 留 null

**复杂事件判断标准：**
- 涉及出行、交通换乘、医院、物品清单等
- 需要推理补齐中间环节
- 例子："周六带哥哥去儿童医院，火车来回……"
- 做法：按下面"复杂事件工作流"执行

---

## 通用：Supabase API 信息

```
Base URL: https://pkxmsfyzcphzvuangrzs.supabase.co/rest/v1/
```

**API Key (anon)**: 在项目 `index.html` 第 522 行 `SB_KEY` 变量的值（也可以直接读文件获取）。

**Headers 固定格式：**
```
apikey: {anon_key}
Authorization: Bearer {anon_key}
Content-Type: application/json
Prefer: return=representation
```

### 创建新事件 (INSERT)

```
POST /calendar_events
Body:
{
  "title": "事件名称",
  "event_date": "2026-05-30",
  "start_time": "09:00",     // 可选
  "event_type": "work",      // life | work | course，默认 life
  "description": "纯文本备注", // 可选
  "detail_html": null        // 简单事件不填，复杂事件填完整HTML
}
```

### 更新已存在的事件 (PATCH)

```
PATCH /calendar_events?id=eq.{event_id}
Body: { /* 只发送需要更新的字段 */ }
```

### 查询已有事件（避免重复创建）

```
GET /calendar_events?select=id,title,event_date,start_time,event_type,description,detail_html&order=event_date.desc&limit=20
```

如需查某一天的事件：
```
GET /calendar_events?event_date=eq.2026-05-30&select=id,title,start_time
```

### 修改事件 (PATCH)

只能改 `description`（用户可编辑的备注）和基本信息，不能改 `detail_html`：

```
PATCH /calendar_events?id=eq.{event_id}
Body:
{
  "title": "新标题",        // 可选
  "event_date": "2026-05-30",  // 可选
  "start_time": "10:00",       // 可选
  "event_type": "work",        // 可选
  "description": "新备注"      // 可选
}
```

如果要重新生成 `detail_html`（用户要求重新安排行程），需要先 PATCH 清空：
```
PATCH /calendar_events?id=eq.{event_id}
Body: { "detail_html": null }
```
然后按复杂事件流程重新生成完整 detail_html。

### 删除事件 (DELETE)

```
DELETE /calendar_events?id=eq.{event_id}
```

执行前向用户确认是否确定删除，获得肯定答复后再执行。

---

## 简单事件流程

1. 提取：标题、日期、时间（如有）、事件类型、备注
2. 按格式调用 Supabase POST 创建事件
3. 通知用户创建完成

**类型判断规则：**
- 生活类 → `life`（家庭事务、个人琐事）
- 工作类 → `work`（会议、合作、上课）
- 课程类 → `course`（学生上课，如翔哥、邵子齐等）

不确定类型时默认 `life`。

---

## 复杂事件工作流

### Step 1: 读取规范

[EVENT_DETAIL_SPEC.md](../../EVENT_DETAIL_SPEC.md) — 定义所有 CSS class、布局规则、简化规则。

### Step 2: 提取关键信息

- 日期、时间
- 交通：车次/航班、车站/机场、座位
- 地点：目的地、地址
- 联系人
- 物品

### Step 3: 推理补齐（核心）

| 缺口 | 操作 | 示例 |
|------|------|------|
| 站点间交通 | 实时查证路线 | 重庆北→儿童医院: 环线→冉家坝换6号线 |
| 到站→预约时间 | 算地铁耗时，推算发车 | 08:58到→09:10上地铁 |
| 跨中午 | 推荐用餐 | 医院附近午餐 |
| 缺返程 | 镜像补齐 | 回程 6号线→环线 |
| 缺物品 | 场景推理 | 医院→病历+医保卡 |

**所有推理内容用金色样式**（`detail-tl-suggest` class）。

### Step 4: 生成 detail_html

顺序：🎒 携带物品 → 🕐 行程时间线

字体：统一 0.85rem，只靠颜色区分（白色=事实 / 浅灰=细节 / 金色=AI建议）。

### Step 5: 创建事件

**先查询是否已存在此事件**（避免重复），然后 POST 或 PATCH。

创建时同时写入：
- `detail_html`: 完整结构化 HTML
- `description`: 纯文本摘要（可选，用户后续可编辑）

---

## 硬性规则

### 交通查证
- **绝对不凭记忆编造路线。** 必须搜索实时查证并交叉验证。
- 查不到就写"建议导航"，不编造。

### 医院场景
- 涉及医院 → 必须带：病历本、医保卡；建议带：口罩

### 座位简化
- 格式：`01车 · 08F 08D`
- 不写谁坐哪、不写窗/过道

### 不写时长
- 起止时间已隐含时长，不再重复写 "33分钟"

### 分行
- 地址和联系人分开行
- 检票口独立行

---

## 自查清单（复杂事件）

```
□ 事件是否已存在？（避免重复）
□ 时间点对齐无矛盾
□ 交通接驳完整（去+回）
□ 跨中午有午餐建议
□ 有物品建议（必须带+建议带）
□ AI建议用金色样式
□ 座位简化
□ 地址和联系人分行
□ 交通路线已查证
□ 涉及医院有病历本+医保卡
```
