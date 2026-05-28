-- 方向与聚焦表
-- 北极星+4个方向分类卡片的所有条目
-- 数据由 AI（主宰）维护，用户只读

CREATE TABLE IF NOT EXISTS directions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,                    -- 条目名称
  icon TEXT NOT NULL DEFAULT '📌',       -- emoji 图标
  category TEXT NOT NULL CHECK (category IN ('north','product','ai','content','family')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','done')),
  tip TEXT,                              -- tooltip 描述文字
  sort_order INTEGER NOT NULL DEFAULT 0, -- 分类内排序
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS 权限：允许匿名 key 读取
ALTER TABLE directions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_select_directions" ON directions
  FOR SELECT USING (true);

-- 初始数据（北极星 + 4类方向卡片）
INSERT INTO directions (name, icon, category, status, tip, sort_order) VALUES
  -- 北极星
  ('生活即工作', '⭐', 'north', 'active', '一辈子大方向', 0),

  -- 产品
  ('写字小程序', '🎮', 'product', 'active', '当前聚焦 · 进行中', 0),
  ('24点游戏',   '24',  'product', 'done',   '已完成 · 已上线', 1),

  -- AI数字化
  ('主宰面板',   '🖥️', 'ai',      'active', '当前聚焦 · 进行中', 0),
  ('Agent日报',  '📋',  'ai',      'done',   '已完成 · 已存档', 1),

  -- 内容
  ('公众号',        '✏️', 'content', 'active', '当前聚焦 · 持续更新', 0),
  ('引光小站调研',  '🔍', 'content', 'done',   '已完成 · 已存档', 1),
  ('天才小熊猫调研', '🐼', 'content', 'done',   '已完成 · 已存档', 2),

  -- 家庭
  ('每日打卡',  '📋', 'family', 'active', '日常 · 老大训练中', 0),
  ('老二陪伴',  '👧', 'family', 'active', '日常 · 持续关注', 1),
  ('心理学笔记', '📖', 'family', 'done',   '已完成 · 已读完', 2)
ON CONFLICT DO NOTHING;
