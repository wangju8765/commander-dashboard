// User: Zeno
// Setup Commander Dashboard database tables on Supabase
// Run: node setup_db.js

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://pkxmsfyzcphzvuangrzs.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_SERVICE_KEY) {
  console.error('ERROR: SUPABASE_SERVICE_KEY not set. Run: source ~/.zshrc');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

const SCHEMA_SQL = `
-- Create schema for commander dashboard
CREATE SCHEMA IF NOT EXISTS commander_dashboard;
SET search_path TO commander_dashboard;

-- 1. calendar_events: Daily/weekly tasks and appointments (replaces calendar)
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

-- 2. projects: Project tracking
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

-- 3. entries: General entries - thinking, actions, future plans
CREATE TABLE IF NOT EXISTS entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('thought', 'action', 'future_plan')),
  title TEXT,
  content TEXT,
  tags JSONB DEFAULT '[]'::jsonb,
  related_project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  entry_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. goals: Long-term and short-term goals
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

-- Enable Row Level Security
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- RLS policies: Allow all operations for public (personal tool, single user)
CREATE POLICY "Allow all on calendar_events" ON calendar_events
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on projects" ON projects
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on entries" ON entries
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on goals" ON goals
  FOR ALL USING (true) WITH CHECK (true);

-- Grant usage to anon role
GRANT USAGE ON SCHEMA commander_dashboard TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA commander_dashboard TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA commander_dashboard TO anon;

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
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
`;

async function main() {
  console.log('Creating Commander Dashboard tables...');
  
  // Execute SQL via Supabase REST API
  const { data, error } = await supabase.rpc('exec_sql', { query: SCHEMA_SQL });
  
  if (error) {
    console.error('Error via RPC, trying direct SQL...');
    console.error(error.message);
    
    // Alternative: Try using raw SQL via POST
    // Supabase pg-meta API
    const sqlResponse = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Prefer': 'params=single-object'
      },
      body: JSON.stringify({ query: SCHEMA_SQL })
    });
    
    const result = await sqlResponse.text();
    console.log('Direct SQL result:', result);
    return;
  }
  
  console.log('Tables created successfully!');
  console.log('Data:', JSON.stringify(data));
}

main().catch(console.error);
