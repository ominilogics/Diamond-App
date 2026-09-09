-- SQL Migration Script for Supabase Short Card Links
-- Run this in the Supabase SQL Editor (https://supabase.com/dashboard/project/jlfgigvfmxuvlixohzli/sql)

CREATE TABLE IF NOT EXISTS public.shared_cards (
  code text PRIMARY KEY,
  cover_image_url text NOT NULL DEFAULT '',
  front_message text NOT NULL DEFAULT '',
  inside_message text NOT NULL DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Grant table privileges to anon, authenticated, and service_role
GRANT ALL ON TABLE public.shared_cards TO anon, authenticated, service_role;

-- Enable Row Level Security (RLS)
ALTER TABLE public.shared_cards ENABLE ROW LEVEL SECURITY;

-- Allow public read access to card previews by short code
DROP POLICY IF EXISTS "Public select for shared_cards" ON public.shared_cards;
CREATE POLICY "Public select for shared_cards"
  ON public.shared_cards FOR SELECT USING (true);

-- Allow public insert access when users generate card links
DROP POLICY IF EXISTS "Public insert for shared_cards" ON public.shared_cards;
CREATE POLICY "Public insert for shared_cards"
  ON public.shared_cards FOR INSERT WITH CHECK (true);
