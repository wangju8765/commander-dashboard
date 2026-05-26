-- 为 projects 表添加 lead（负责人）字段
ALTER TABLE projects ADD COLUMN IF NOT EXISTS lead TEXT;
