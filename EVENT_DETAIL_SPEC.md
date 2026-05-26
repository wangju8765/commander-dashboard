# 事件详情 HTML 生成规范（v2）

## 用途

任何 agent 在创建或更新日历事件的 `detail_html` 字段时，必须严格按照本规范生成 HTML。本规范确保所有事件详情在 dashboard 上呈现一致。

**核心原则：** Agent 必须主动推理并补齐用户未提供的空白信息（交通接驳、用餐建议、出行顺序等），用金色样式标注 AI 补充内容。

---

## 一、整体布局顺序

```
1. 🎒 携带物品（排第一）
   - 蓝色 tag = 必须带（从行程推理出的硬性需求）
   - 金色 tag = 建议带（AI 推荐的辅助物品）
   
2. 🕐 行程时间线（排第二）
   - 按时间顺序排列每个节点
   - 无时间节点的不放入时间线
```

---

## 二、可用 CSS class

### 容器
| class | 用途 | 说明 |
|-------|------|------|
| `detail-pack` | 携带物品区外层容器 | 包裹所有 pack-tag |
| `detail-pack-row` | tag 行 | 蓝色一行，金色一行 |
| `detail-tl` | 时间线容器 | |
| `detail-tl-item` | 单个时间节点 | |

### 时间线节点内容
| class | 用途 | 样式 |
|-------|------|------|
| `detail-tl-time` | 时间 | 大号白色加粗 `0.9rem` |
| `detail-tl-main` | 核心行动简述 | 白色半粗 `0.85rem` |
| `detail-tl-sub` | 辅助信息（座位/地址/检票口） | 浅灰 `#ccc` `0.85rem` |

### 时间线圆点（节点标记）
| class | 含义 |
|-------|------|
| `detail-tl-dot train` | 🚄 火车/飞机 |
| `detail-tl-dot location` | 📍 地点 |
| `detail-tl-dot suggest` | 🟠 AI 建议（地铁/用餐） |
| `detail-tl-dot home` | 🏠 到家/结束 |

### 携带物品 tag
| class | 用途 |
|-------|------|
| `detail-pack-tag must` | 必须带（蓝色边框） |
| `detail-pack-tag suggest` | 建议带（金色边框） |
| `detail-pack-tag done` | 已携带（勾选状态，绿色） |

### AI 建议内容
| class | 用途 | 样式 |
|-------|------|------|
| `detail-tl-suggest` | AI 推理补充的段落 | 金色字 `#ff9f43`，左侧金边框 |

---

## 三、生成规则

### 3.1 信息提取

从用户提供的材料中提取：
- 所有时间点（出发/到达/约定）
- 交通方式（车次/航班号、出发到达站、座位号）
- 地点地址（精确到楼层/科室/房间）
- 联系人（姓名/称谓 + 联系方式）
- 需要携带的物品（用户明确提到的）

### 3.2 AI 推理补齐（必须做）

| 补齐类型 | 做法 | 示例 |
|---------|------|------|
| 交通接驳 | 查地铁/公交路线，给出具体方案 | 重庆北站→儿童医院：环线→冉家坝换6号线→礼嘉4A口 |
| 时间衔接 | 计算换乘时间，推算下一段出发时间 | 08:58到站→09:10上地铁→09:50到礼嘉 |
| 用餐建议 | 跨中午的行程推荐附近用餐 | ~12:00 医院周边用餐 |
| 返程交通 | 镜像补齐回程交通 | 回程地铁：礼嘉→冉家坝→重庆北 |
| 物品建议 | 根据场景推荐携带物品 | 带零食/带水杯/带充电宝 |

**所有 AI 推理补齐的内容必须用金色样式 `detail-tl-suggest` 标注。**

### 3.3 物品清单规则

- **必须带（蓝色）**：证件、病历、票务相关——来自行程的硬性推理
- **建议带（金色）**：水杯、充电宝、零食、湿巾等——AI 根据场景推荐
- 默认不加文字标签，颜色天然区分
- 每行最多 5 个 tag，多了换行

### 3.4 字体规则

全部使用同一字号（`0.85rem`）：
- 时间节点标题：白色加粗
- 核心行动：白色半粗
- 辅助细节（座位号/地址/联系方式/检票口）：浅灰色
- AI 建议：金色

**不要做"大字/小字"的分级，所有信息同等重要，只靠颜色区分类型。**

### 3.5 座位信息简化规则

- 只写车厢号和座位号：`01车 · 08F 08D`
- **不写谁坐哪个座位**（两人同行会换座）
- **不写靠窗/靠过道**（不重要）

### 3.6 时间省略规则

- 行程时长（如"33分钟"）不写——起止时间已包含此信息

### 3.7 信息分行规则

- 地址和联系电话**必须分两行**显示
- 检票口信息**必须独立一行**

### 3.8 交通信息查证规则

- **绝对不凭记忆生成路线。** 交通规则和路线变化极快（地铁新线开通、公交改线、站点更名），靠记忆极大概率出错。
- 即使 agent「记得」某条路线，也必须通过搜索实时查证并交叉验证。
- 查证示例：搜索「重庆北站南广场 到 儿童医院两江院区 地铁」，确认环线→冉家坝换6号线→礼嘉的方案。
- 如果查不到准确信息，在 `detail-tl-suggest` 中写「建议导航」字样，不要编造路线。

---

## 四、示例

### 出行+就医（完整示例）

用户提供材料：
> 周六带哥哥去重庆儿童医院两江院区测评，G8671 08:25永川东→08:58重庆北，01车，G8686 14:37重庆北→15:08永川东，01车，7楼C区，微信联系诸老师

AI 生成输出：

```html
<div class="detail-pack">
  <div class="detail-pack-row">
    <span class="detail-pack-tag must">身份证</span>
    <span class="detail-pack-tag must">病历本</span>
    <span class="detail-pack-tag must">医保卡</span>
  </div>
  <div class="detail-pack-row">
    <span class="detail-pack-tag suggest">充电宝</span>
    <span class="detail-pack-tag suggest">水杯</span>
    <span class="detail-pack-tag suggest">零食</span>
    <span class="detail-pack-tag suggest">湿巾</span>
    <span class="detail-pack-tag suggest">耳机</span>
  </div>
</div>

<div class="detail-tl">
  <div class="detail-tl-item">
    <div class="detail-tl-dot train"></div>
    <div class="detail-tl-time">08:25 → 08:58</div>
    <div class="detail-tl-main">🚄 G8671 · 永川东 → 重庆北</div>
    <div class="detail-tl-sub">01车 · 08F 08D</div>
  </div>

  <div class="detail-tl-item">
    <div class="detail-tl-dot suggest"></div>
    <div class="detail-tl-time">09:10 → 09:50</div>
    <div class="detail-tl-main">🚇 重庆北站 → 礼嘉站</div>
    <div class="detail-tl-suggest">
      环线外环 重庆北站南广场→冉家坝（4站）换乘6号线→礼嘉（5站）<br>
      礼嘉站 4A口出 · 步行3分钟到儿童医院
    </div>
  </div>

  <div class="detail-tl-item">
    <div class="detail-tl-dot location"></div>
    <div class="detail-tl-time">🔴 10:00</div>
    <div class="detail-tl-main">📍 重庆儿童医院 · 两江院区 · 7楼C区</div>
    <div class="detail-tl-sub">重庆市两江新区金渝大道20号</div>
    <div class="detail-tl-sub">📞 微信联系诸老师</div>
  </div>

  <div class="detail-tl-item">
    <div class="detail-tl-dot suggest"></div>
    <div class="detail-tl-time">~12:00</div>
    <div class="detail-tl-main">🍚 午餐</div>
    <div class="detail-tl-suggest">
      儿童医院周边餐饮较多（金渝大道沿线）<br>
      建议在医院附近用餐，饭后休息候车
    </div>
  </div>

  <div class="detail-tl-item">
    <div class="detail-tl-dot suggest"></div>
    <div class="detail-tl-time">13:30 → 14:05</div>
    <div class="detail-tl-main">🚇 礼嘉站 → 重庆北站</div>
    <div class="detail-tl-suggest">
      6号线 礼嘉→冉家坝（5站）换乘环线内环→重庆北站南广场（4站）<br>
      预留25分钟到站候车
    </div>
  </div>

  <div class="detail-tl-item">
    <div class="detail-tl-dot train"></div>
    <div class="detail-tl-time">14:37 → 15:08</div>
    <div class="detail-tl-main">🚄 G8686 · 重庆北 → 永川东</div>
    <div class="detail-tl-sub">01车 · 09D 09F · 检票口 16B/17B</div>
  </div>

  <div class="detail-tl-item">
    <div class="detail-tl-dot home"></div>
    <div class="detail-tl-time">~15:15</div>
    <div class="detail-tl-main">🏠 到家</div>
  </div>
</div>
```

---

## 五、常见事件类型模板

### 就医（本地）

1. 🎒 携带物品（必须带：病历/医保卡/身份证；建议带：水杯/零食）
2. 🕐 时间线：出门时间 → 医院 → 回家（补齐交通方案）

### 就医（外地/跨城）

1. 🎒 携带物品
2. 🕐 时间线：出发火车/飞机 → 地铁到酒店/医院 → 就医 → 午餐 → 返程地铁 → 回程火车/飞机 → 到家

### 会议/活动

1. 🎒 携带物品（电脑/笔记本/名片等）
2. 🕐 时间线：出发 → 到达 → 活动 → 返程

### 纯提醒

1. **不生成 detail_html**，只用 `description` 写 Markdown 备注

---

## 六、创建流程

1. 用户提供材料（截图/口述/文字）
2. agent 分析材料，提取关键信息
3. agent **主动推理补齐**缺失环节（交通接驳、用餐、时间衔接）
4. agent 按本规范生成完整 `detail_html` HTML
5. agent 调用 Supabase API 创建或更新 `calendar_events` 记录
   - 写入：`title`, `event_date`, `start_time`, `end_time`, `event_type`, `detail_html`, `description`（Markdown 摘要，备查）
6. 呈报用户确认
