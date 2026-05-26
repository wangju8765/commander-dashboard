---
name: event-detail-creator
description: Create structured event detail HTML for Commander Dashboard calendar events. Use when the user provides trip/event information and needs a rich detail page with packing checklist (must/suggest tags), timeline view, AI-suggested transit/meal supplements, and Supabase persistence. Triggered by requests like "帮我创建行程" "安排出行" "创建事件详情" or when the user supplies complex multi-step event info.
---

# Event Detail Creator

## Quick Start

When the user gives you event info, follow this workflow:

```
用户材料 → 分析提取 → 推理补齐 → 生成HTML → 写入Supabase → 确认
```

### Step 1: Load the Spec

Read the canonical specification:

[EVENT_DETAIL_SPEC.md](../../EVENT_DETAIL_SPEC.md)

This file defines:
- All available CSS classes (packing tags, timeline, AI suggestion styling)
- Layout ordering rules (packing first, then timeline)
- Information simplification rules (seats, durations)
- AI inference requirements (transit connections, meals)

### Step 2: Extract Key Info

From user input, extract:
- Date(s) and times
- Transport: train/flight numbers, stations/airports, seat numbers
- Locations: destination, address, floor/room
- Contacts: who, how to reach
- Items: anything user explicitly mentions bringing

### Step 3: Infer Missing Info (Critical)

**Your job is not just to record — it's to complete the journey.**

| Gap | What to do | Example |
|-----|------------|---------|
| No transit between stations | Search real-time route | 重庆北站→儿童医院: 环线→冉家坝换6号线 |
| Gap between arrival and appointment | Calculate subway time, infer departure | 08:58到站→09:10上地铁 |
| Midday gap | Recommend nearby meals | 医院附近金渝大道用餐 |
| Missing return transit | Mirror the outbound route | 回程: 6号线→环线 |
| No packing list | Infer from context | Hospital: must bring 病历/医保卡 |

**ALL inferred content must use golden styling** (`detail-tl-suggest` class).

### Step 4: Generate HTML

Follow the layout ordering from EVENT_DETAIL_SPEC.md:

1. **🎒 携带物品** — `detail-pack` container with `detail-pack-tag must/suggest` rows
2. **🕐 行程时间线** — `detail-tl` container with timeline items

Typography rules: **uniform size** (0.85rem). No "small text." Colors only:
- White = core facts (time, transport)
- Light grey = details (seat numbers, address, platform)
- Golden = AI suggestions (transit, meals, recommended items)

### Step 5: Write to Supabase

```
PATCH https://pkxmsfyzcphzvuangrzs.supabase.co/rest/v1/calendar_events?id=eq.{event_id}
Headers:
  apikey: {supabase_anon_key}
  Authorization: Bearer {supabase_anon_key}
  Content-Type: application/json

Body:
{
  "title": "事件名称",
  "event_date": "2026-05-30",
  "start_time": "08:25",
  "end_time": null,  // optional, only when known
  "event_type": "life",  // life | work | course
  "detail_html": "<!-- 完整的结构化HTML -->",
  "description": "纯文本摘要（可选，用户可编辑的备注）"
}
```

The Supabase anon key is in the project's `index.html` file at line 522.

## Hard Rules (Violations Are Not Acceptable)

### Transit Verification
- **NEVER generate transit routes from memory.** Routes change constantly (new metro lines, bus reroutes).
- **Always search and cross-verify.** Even if you "remember" a route.
- If you can't find accurate info, write "建议导航" in the golden suggestion block — do NOT fabricate.

### Hospital Context
- If the trip involves a hospital, MUST include 病历本 and 医保卡 in must-bring tags.
- SUGGEST including 口罩 in the suggest tags.

### Seat Simplification
- Format: `01车 · 08F 08D`
- Do NOT write who sits where (traveling companions swap seats anyway)
- Do NOT write window/aisle

### Duration Removal
- If you show `08:25 → 08:58`, do NOT also write "33分钟" — the start/end times already imply the duration.

### Line Breaks
- Address and contact info must be on SEPARATE lines
- Platform/gate info must be on its own line

## Example Output

See [EVENT_DETAIL_SPEC.md](../../EVENT_DETAIL_SPEC.md) section 四 for a complete "出行+就医" example with all CSS classes.

## Verification Checklist (run after generating)

```
□ 所有时间点对齐（无矛盾）
□ 交通接驳完整（去程+回程）
□ 跨中午行程有午餐建议
□ 有物品建议（必须带+建议带）
□ AI建议用了金色样式
□ 座位简化（无姓名/窗道）
□ 地址和联系人分行
□ 交通路线已查证（非记忆）
□ 涉及医院时有病历本+医保卡
```
