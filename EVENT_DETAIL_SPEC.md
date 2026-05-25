# 事件详情 HTML 生成规范

## 用途

任何 agent 在创建或更新日历事件的 `detail_html` 字段时，必须严格按照本规范生成 HTML。本规范确保所有事件详情在 dashboard 上呈现一致。

## 可用 CSS class

| class | 用途 |
|-------|------|
| `detail-html` | 最外层容器（自动由 dashboard 添加，agent 不需要写） |
| `detail-section` | 一个信息区块，如「地点」「去程」 |
| `detail-section-title` | 区块标题，含 emoji |
| `detail-row` | 单条信息行（label + value） |
| `detail-label` | 信息标签（加粗、灰色，如"航班""时间"） |
| `detail-value` | 信息值（白色正文） |
| `detail-checklist` | 物品清单容器 |
| `detail-checkitem` | 物品清单的每一项 |

## 内容原则

1. **只放对完成这件事必不可少的信息**，不放无关细节
2. 一个事件最多 **6 个 section**
3. 物品清单放在**最后一个 section**
4. 联系人信息放在地点或交通之后

## 示例

```html
<div class="detail-section">
  <div class="detail-section-title">📍 地点</div>
  <div class="detail-row">
    <span class="detail-label">医院</span>
    <span class="detail-value">北京协和医院 · 东院</span>
  </div>
  <div class="detail-row">
    <span class="detail-label">地址</span>
    <span class="detail-value">东城区帅府园1号</span>
  </div>
</div>

<div class="detail-section">
  <div class="detail-section-title">✈️ 去程</div>
  <div class="detail-row">
    <span class="detail-label">航班</span>
    <span class="detail-value">CZ3151</span>
  </div>
  <div class="detail-row">
    <span class="detail-label">时间</span>
    <span class="detail-value">08:00 → 11:00</span>
  </div>
  <div class="detail-row">
    <span class="detail-label">座位</span>
    <span class="detail-value">34A</span>
  </div>
</div>

<div class="detail-section">
  <div class="detail-section-title">🚄 回程</div>
  <div class="detail-row">
    <span class="detail-label">车次</span>
    <span class="detail-value">G79</span>
  </div>
  <div class="detail-row">
    <span class="detail-label">时间</span>
    <span class="detail-value">18:00 → 23:00</span>
  </div>
  <div class="detail-row">
    <span class="detail-label">车站</span>
    <span class="detail-value">北京西 → 深圳北</span>
  </div>
  <div class="detail-row">
    <span class="detail-label">座位</span>
    <span class="detail-value">03车 08D号</span>
  </div>
</div>

<div class="detail-section">
  <div class="detail-section-title">📋 需要带的物品</div>
  <div class="detail-checklist">
    <div class="detail-checkitem">身份证</div>
    <div class="detail-checkitem">病历本</div>
    <div class="detail-checkitem">医保卡</div>
  </div>
</div>
```

## 常见事件类型的 section 模板

### 出行（飞机+火车）

1. 📍 地点（目的地地址）
2. ✈️ 去程（航班号、时间、座位、出发/到达机场）
3. 🚄 回程（车次、时间、座位、车站）
4. 📋 物品清单（身份证、其他）

### 就医

1. 📍 地点（医院名、地址）
2. ☎️ 联系方式（科室、电话）
3. ✈️/🚄 交通（如果有）
4. 📋 物品清单（身份证、病历本、医保卡）

### 会议/活动

1. 📍 地点（地址）
2. 🕐 时间（如果有跨时间段）
3. 📋 物品清单（邀请函、材料等）

### 纯提醒

1. 不需要 section，只写备注即可

## 创建流程

1. 用户提供信息（截图/口述）
2. agent 按本规范生成 HTML
3. 存入 `calendar_events.detail_html`
4. 呈报用户确认
