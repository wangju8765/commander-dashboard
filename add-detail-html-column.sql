-- 在 Supabase Dashboard → SQL Editor 中运行
-- 为日历事件添加详情字段（agent 生成的 HTML）

ALTER TABLE calendar_events
ADD COLUMN IF NOT EXISTS detail_html TEXT;
