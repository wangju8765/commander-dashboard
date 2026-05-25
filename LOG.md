# LOG.md — 主宰面板 运行日志

## 2026-05-25

### 13:30 - 15:30 首次开发 session
- 讨论需求：使用场景、功能范围、技术方案
- 出示意图：手机版(mockup.html) + 电脑版(mockup-desktop.html)
- 用户确认布局方向

### 数据库搭建
- Supabase 建4张表（calendar_events/projects/goals/entries）
- 最初建在 commander_dashboard schema，后因 REST API 限制迁移到 public
- 迁移 SQL：setup-move-to-public.sql

### 代码开发（三次无效迭代）
1. index.html v1：用 import 加载 supabase-js CDN → 手机 Safari 卡死
2. index.html v2：改 UMD CDN → CSS 布局混乱
3. index.html v3：直接 fetch() 调 API → 手机/电脑混合显示

### 最终修复（v4）
- 手机和电脑完全分离为两套独立视图（mobileView / desktopView）
- 各自使用 mockup 的原始 CSS，互不冲突
- 根据屏幕宽度用 JS 切换
- 零外部依赖

### 当前问题（待修复）
- 手机 Safari 渲染和交互仍需验证
- 电脑端与 mockup-desktop 有细节差异（用户反馈但未具体指出）
- 缺少编辑/删除功能
- 缺少未来规划模块

### 16:00-16:50 修复 session
- 根因诊断：之前卡顿是 DeepSeek API 503，非逻辑问题
- **下拉刷新**：彻底方案 `html/body { overflow:hidden; height:100% }`，只让 `.main` 滚动
- **电脑版布局**：`#desktopView { display:flex }` — sidebar 和 main 左右并排
- **FAB 被 tab bar 遮挡**：`bottom:calc(6rem + env(safe-area-inset-bottom))`，z-index:150
- **头顶飘进刘海**：header 加 `padding-top:calc(1.25rem + env(safe-area-inset-top))`
- **tab bar 安全区**：`padding-bottom:calc(0.375rem + env(safe-area-inset-bottom))`
- 所有修改已提交 + 部署到 GitHub Pages
- 用户需删除旧 Home Screen 快捷方式重新添加才能完全生效

### 17:00-18:00 表单验证 + 功能迭代 session

#### 表单验证优化（用户反馈：alert 弹窗不好）
- 去掉 alert()，改为内联提示（红字/红框）
- 标题为空 → 红框 + "请输入事项名称"
- 日期为空 → 红框 + "请选择日期"
- 空时间/备注 → 清洗后不发送到 API
- API 失败 → 模态框内显示红色提示条
- 日期框宽度：`flex:1.3` + select 高度统一 `min-height:2.2rem`

#### Bug修复（用户 Safari 实际使用反馈）
1. **日期 tab 点不了** — renderEvents 用 S.today 而非 S.selDate，修复
2. **勾选圈白字** — CSS `\\u2713` → `\\2713`（JavaScript vs CSS 的 Unicode 写法差异）
3. **双击放大** — 全局 `* { touch-action: manipulation }`
4. **Safari 下拉刷新** — 之前已修复

#### 事件模型重新设计（用户讨论确立）
- 去掉手动勾选（toggle），改为**自动完成**：时间过了自动变灰
- 新增 `isPast()` 函数，按时间判断事件是否已完成
- 移除 `event-check` 全套 CSS/JS（圆圈、勾号、toggle 逻辑）
- 移除 `crudUpdate`（不再需要）

#### 日期条改为 10 天窗口
- 过去 2 天 + 今天 + 未来 7 天
- 创建事件不受限制（通过 agent 截图创建）

#### 事件详情块
- 新增 `detail_html` 字段（TEXT）
- 点击事件弹出详情卡，渲染 detail_html
- 规范文档 `EVENT_DETAIL_SPEC.md`（交给其他 agent 的交接规范）
- 数据库迁移 SQL：`add-detail-html-column.sql`

### 核心教训（本 session 确立）
- AGENTS.md 新增「地基原则」：用户确认过的产物只修改不重写
- AGENTS.md 新增「UI 交付验证清单」
- MEMORY.md 补充「示意图即是生产代码地基」
