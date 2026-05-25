-- 主宰面板 · 把表从 commander_dashboard 移到 public schema
-- 在 Supabase SQL 编辑器中粘贴运行

-- 1. 移动表到 public schema
ALTER TABLE commander_dashboard.calendar_events SET SCHEMA public;
ALTER TABLE commander_dashboard.projects SET SCHEMA public;
ALTER TABLE commander_dashboard.entries SET SCHEMA public;
ALTER TABLE commander_dashboard.goals SET SCHEMA public;

-- 2. 给 anon 角色授权（public schema 默认已暴露给 API）
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;

-- 完成！之后刷新页面即可
