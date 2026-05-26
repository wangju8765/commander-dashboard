# PLAN.md — 主宰面板 规划文档

> 最后更新：2026-05-25 23:30

---

## 一、项目背景

用户（Zeno）需要管理的事务维度多且杂：
- **项目**：多个并行推进的开发/运营项目
- **长期目标**：如数学教育产品矩阵，周期数月到年
- **短期目标**：如月度冲刺，周期数周
- **周计划**：本周日程、明天安排、待办清单
- **未来规划**：按月/季的时间轴安排
- **思考库**：务虚——读书笔记、理论反思、灵感
- **行动库**：务实——具体任务、实践记录

目前全靠脑力追踪，消耗大量认知能量。需要一个可视化的管理面板。

---

## 二、里程碑

| 里程碑 | 内容 | 目标状态 |
|--------|------|----------|
| M1: 需求定义 | 数据字段、交互方式、功能范围确认 | ✅ 已完成 |
| M2: UI 确认 | 用户确认布局和视觉方向 | ✅ 已完成 |
| M3: MVP 开发 | 核心功能可用的完整单页应用 | 🚧 已上线（持续迭代） |
| M4: 内测调整 | 用户实际使用一周后收集反馈 | ⏳ 待进行 |
| M5: 正式发布 | 上线可用，日常使用 | ⏳ 待进行 |

---

## 三、已完成的功能

### 数据模块
- [x] **日历/今日待办** — 每日事件列表、按上下午晚上分组、繁忙进度条
- [x] **项目列表** — 名称、状态徽章、进度条、标签
- [x] **目标** — 长短期目标、进度、截止日期
- [x] **思考库/行动库/规划库** — 统一 timeline，类型筛选
- [x] **事件详情弹窗** — Markdown 渲染 + 交互式勾选框
- [x] **日历7天条** — 选中日查看事件、繁忙度可视化

### 交互
- [x] 手机底部 Tab 导航（今日/项目/目标/库）
- [x] 电脑左侧边栏 + 三列仪表盘
- [x] 新增事项表单（日历事件/项目/目标/记录）
- [x] 编辑事件（标题/备注/类型/日期/时间）
- [x] 删除事件
- [x] 类型按钮组（生活/工作/课程，三色区分）
- [x] 课程快捷按钮（翔哥/邵子齐/郭靖宇/蔡汐堋/四年级）
- [x] 导出 JSON 备份
- [x] 内联表单验证（红框红字，无 alert）
- [x] 时间选择15分钟步长

### 技术
- [x] 单页 HTML，零依赖（无需加载任何 CDN 库）
- [x] 响应式（手机 < 768px，电脑 >= 768px，两套独立视图）
- [x] Supabase 云端数据库（持久化存储）
- [x] 部署到 GitHub Pages（HTTPS）
- [x] iOS Safari 适配（安全区、防下拉刷新、防缩放）

---

## 四、项目文件

| 文件 | 作用 |
|------|------|
| `index.html` | 生产代码（最新版本，已部署到 GitHub Pages） |
| `mockup.html` | 手机版示意图（设计地基） |
| `mockup-desktop.html` | 电脑版示意图（设计地基） |
| `PLAN.md` | 项目规划文档 |
| `README.md` | 项目说明 |
| `setup-supabase.sql` | 数据库建表 SQL |
| `setup-move-to-public.sql` | 表迁移 SQL（移至 public schema） |

---

## 五、数据库结构（Supabase public schema）

### calendar_events 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| title | TEXT | 标题 |
| description | TEXT | 描述（Markdown 格式） |
| event_date | DATE | 日期 |
| start_time | TIME | 开始时间 |
| end_time | TIME | 结束时间 |
| event_type | TEXT | 类型：life/work/course |
| completed | BOOLEAN | 是否完成（不再使用，改用自动完成） |
| priority | TEXT | 优先级（不再使用） |
| detail_html | TEXT | AI 生成的事件详情 HTML |

### projects 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| name | TEXT | 项目名 |
| status | TEXT | planning/in_progress/completed/archived |
| progress | INTEGER | 0-100 |
| tags | JSONB | 标签数组 |
| description | TEXT | 描述 |

### goals 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| type | TEXT | long_term/short_term |
| title | TEXT | 标题 |
| description | TEXT | 描述 |
| due_date | DATE | 截止日期 |
| progress | INTEGER | 0-100 |
| milestones | JSONB | 子里程碑数组 |

### entries 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| type | TEXT | thought/action/plan |
| title | TEXT | 标题 |
| content | TEXT | 内容 |
| tags | JSONB | 标签数组 |
| entry_date | DATE | 记录日期 |
| related_project_id | UUID | 关联项目 |

---

## 六、待办（后续 session）

### 需要修复的问题
- [ ] 电脑端与 mockup-desktop 的细节差异

### 需要完善的功能
- [x] 详情页支持可点击 URL 链接
- [x] 详情页全新布局（携带物品tag + 行程时间线 + AI建议）
- [x] AI 生成事件详情时推理补齐交通换乘/用餐
- [x] 创建 Commander Calendar Skill（含决策树、CRUD 操作）
- [ ] 未来规划模块（时间轴视图）
- [ ] AI 生成事件详情时补充交通换乘建议
- [ ] 快速添加今日事件按钮

### 已决定的待讨论点
- [ ] 我（主宰）通过飞书远程更新数据的能力

### 🔜 推迟到核心功能完善后
- [ ] Service Worker 离线缓存
- [ ] Web Push 推送通知（iOS 16.4+ PWA）
- [ ] iOS 捷径（快速添加事项）
- [ ] 分享功能（Web Share API）
