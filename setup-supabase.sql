-- ============================================================
-- 主宰面板 · 建表 SQL
-- 在 Supabase SQL 编辑器中直接粘贴运行
-- ============================================================

-- 1. 创建 schema
CREATE SCHEMA IF NOT EXISTS commander_dashboard;

-- 2. 设置搜索路径
SET search_path TO commander_dashboard;

-- 3. 日历事件表（替代你的日历）
CREATE TABLE IF NOT EXISTS calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  event_type TEXT DEFAULT 'task' CHECK (event_type IN ('task', 'appointment', 'reminder', 'daily')),
  completed BOOLEAN DEFAULT FALSE,
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 项目表
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'planning' CHECK (status IN ('planning', 'in_progress', 'completed', 'archived')),
  progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  tags JSONB DEFAULT '[]'::jsonb,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. 通用条目表（思考/行动/规划）
CREATE TABLE IF NOT EXISTS entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('thought', 'action', 'plan')),
  title TEXT,
  content TEXT,
  tags JSONB DEFAULT '[]'::jsonb,
  related_project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  entry_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. 目标表（长期/短期）
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('long_term', 'short_term')),
  title TEXT NOT NULL,
  description TEXT,
  due_date DATE,
  progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  related_project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  milestones JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. 启用行级安全（RLS）
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- 8. RLS 策略：允许所有人操作（个人工具）
CREATE POLICY "Allow all on calendar_events" ON calendar_events
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on projects" ON projects
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on entries" ON entries
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on goals" ON goals
  FOR ALL USING (true) WITH CHECK (true);

-- 9. 授权匿名角色访问
GRANT USAGE ON SCHEMA commander_dashboard TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA commander_dashboard TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA commander_dashboard TO anon;

-- 10. 自动更新时间戳的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 11. 应用触发器
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_calendar_events_updated_at') THEN
    CREATE TRIGGER update_calendar_events_updated_at
      BEFORE UPDATE ON calendar_events
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_projects_updated_at') THEN
    CREATE TRIGGER update_projects_updated_at
      BEFORE UPDATE ON projects
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_entries_updated_at') THEN
    CREATE TRIGGER update_entries_updated_at
      BEFORE UPDATE ON entries
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_goals_updated_at') THEN
    CREATE TRIGGER update_goals_updated_at
      BEFORE UPDATE ON goals
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END;
$$;

-- ============================================================
-- 完成！接下来：
-- 1. 去 Settings → API 复制 "anon public" 密钥给我
-- 2. 我去部署代码
-- ============================================================
