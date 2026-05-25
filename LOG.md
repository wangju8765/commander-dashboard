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

### 核心教训（本 session 确立）
- AGENTS.md 新增「地基原则」：用户确认过的产物只修改不重写
- AGENTS.md 新增「UI 交付验证清单」
- MEMORY.md 补充「示意图即是生产代码地基」
