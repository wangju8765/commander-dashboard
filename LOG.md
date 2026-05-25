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

### 19:00-19:35 用户反馈修复 session

#### 7项 UI/交互改进（全部完成并部署）
1. **日期框** — `.date-field` flex 1.3→2.5，时间 1，日期 input 加 `white-space:nowrap`
2. **类型按钮** — 下拉 select → 三色按钮组（📋任务蓝 / 📅预约橙 / 🔔提醒绿），隐藏 input 存值
3. **日历清晰度** — day-pill 2.5rem→3rem，dow 0.6→0.65rem，dom 0.85→0.95rem
4. **过去窗口** — `i=-2`→`i=-1`
5. **选中态** — 新增 `.day-pill.selected` 样式（亮蓝边框+背景+白色字），点击切换，今天保持淡背景
6. **类型探讨** — 不修改，回复中讨论
7. **详情编辑** — 新增 crudUpdate/updateEvent PATCH API，详情页加
- AGENTS.md 新增「UI 交付验证清单」
- MEMORY.md 补充「示意图即是生产代码地基」

### 19:35-22:00 深度迭代 session

#### 用户反馈修复
1. **编辑按钮** — ✏️ emoji→文字「编辑」，移到关闭按钮左侧
2. **编辑可改类型** — 编辑表单新增三色按钮类型切换
3. **创建表单排序** — 类型字段排第一
4. **类型标签** — 去掉 emoji 改用颜色小点，生活改蓝色 #5b9aff
5. **课程按钮** — 选课程时显示5个固定按钮（翔哥/邵子齐/郭靖宇/蔡汐堋/四年级）
6. **日历字体** — dow 0.7rem + 600, dom 1.05rem + 700
7. **日历窗口** — 0~+6（今天+未来6天）
8. **默认日期** — 改为日历选中日 S.selDate

#### 重大 bug 修复
- **编辑按钮闭包 bug**：`||` 创建一次按钮，闭包锁死在第一个事件。改为每次 `openEventDetail` 重新绑定 `onclick`

#### 类型系统重构
- 数据库 CHECK 约束改为允许 life/work/course
- 旧数据迁移：task/appointment/reminder→life，笔杆子→work
- 代码全部删除 task/appointment/reminder 映射

#### Markdown 备注系统
- 新增 `mdToHtml` 渲染器（支持 #标题 / **加粗** / -列表）
- description 改为 Markdown 存储，编辑框等宽字体+语法提示
- detail_html 保持独立，两者同时渲染

#### 交互式勾选框
- `- [ ] / - [x]` 渲染为可点击勾选框
- 点击自动勾选/取消，实时 PATCH 到 Supabase
- 选中文字变灰+删除线

#### 日历繁忙进度条
- 小圆点→进度条（宽度+颜色双维度）
- 公式：事件数×60÷600min
- ≤30%绿/≤60%橙/>60%红

#### 数据库
- 用户手动在 Supabase SQL Editor 执行删约束+加新约束
- 旧数据已迁移（4条→life, 1条→work）
- 哥哥测评 description 写入 Markdown（含交互式勾选框）

#### 代码提交
- 本次共5个 commit，全部推送成功
- 文件大小：47934→55432 字节（+7498）

### 22:00-22:10 事件删除 + 类型修复

#### 修复
1. **事件删除功能** — 详情弹窗新增「删除」按钮，调用 `crudDelete()` + `deleteEvent()`
2. **修复编辑表单类型按钮** — `showEditForm` 使用 `life/work/course` 替代旧的 `task/appointment/reminder`
3. **修复创建事件默认类型** — fallback `'task'` → `'life'`
4. **修复事件圆点颜色** — evtHtml 类型映射同步
5. **关闭弹窗隐藏删除按钮**
6. **新增 .gitignore** — 清理远程 node_modules/build artifacts（+140K 行删除）

#### 提交
- `a45a3e1` feat: 事件删除功能 + 修复编辑表单类型值为新系统 + 修复创建事件默认类型
- `b788c65` chore: add .gitignore, stop tracking node_modules/build artifacts
