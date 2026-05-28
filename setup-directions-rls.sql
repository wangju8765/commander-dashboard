-- 给 directions 表添加 RLS 权限
ALTER TABLE directions ENABLE ROW LEVEL SECURITY;

-- 允许匿名 key 读取所有方向项
CREATE POLICY "anon_select_directions" ON directions
  FOR SELECT USING (true);
