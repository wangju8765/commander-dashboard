# 主宰面板 (Commander Dashboard)

**目标：** 做一个个人管理面板，可视化追踪项目、目标、周计划、未来规划、思考与行动，释放认知负荷
**状态：** 🚧 已上线（MVP）
**版本：** v0.4.0
**网址：** https://wangju8765.github.io/commander-dashboard/
**仓库：** wangju8765/commander-dashboard
**起始：** 2026-05-25
**负责人：** 主宰

## 当前功能

- 📅 **日历事件** — 创建/编辑/删除，按时间分组的简洁列表
- 📊 **项目管理** — 状态徽章、进度条、标签
- 🎯 **目标追踪** — 长短期目标、进度、截止日期
- 📚 **思考/行动/规划库** — 统一 timeline，类型筛选
- 📱 **响应式** — 手机底部 Tab + 电脑三列仪表盘
- ☁️ **Supabase 云端** — 数据自动同步
- 🎒 **AI 生成的事件详情页** — 携带物品标签（蓝色=必须/金色=建议，可点击标记已带）+ 行程时间线 + AI 建议（金色边框）
- 🤖 **Commander Calendar Skill** — 其他 AI agent 通过 skill 获得创建/修改/删除日历事件的能力

## 相关文档

- [PLAN.md](./PLAN.md) — 规划细节、里程碑
- [LOG.md](./LOG.md) — 迭代日志
- [EVENT_DETAIL_SPEC.md](./EVENT_DETAIL_SPEC.md) — AI 事件详情生成规范（CSS class / 布局规则 / AI推理）
- [skills/commander-calendar/SKILL.md](./skills/commander-calendar/SKILL.md) — Agent Skill 文件
