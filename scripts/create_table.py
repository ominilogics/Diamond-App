import json
import os

def load_env():
    env = {}
    if os.path.exists('.env'):
        with open('.env') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    k, v = line.strip().split('=', 1)
                    env[k] = v
    return env

env = load_env()
SUPABASE_URL = env.get("SUPABASE_URL", "https://jlfgigvfmxuvlixohzli.supabase.co")
SERVICE_KEY = env.get("SUPABASE_SERVICE_ROLE_KEY", "")

sql = """
CREATE TABLE IF NOT EXISTS public.shared_cards (
  code text PRIMARY KEY,
  cover_image_url text NOT NULL DEFAULT '',
  front_message text NOT NULL DEFAULT '',
  inside_message text NOT NULL DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.shared_cards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public select for shared_cards" ON public.shared_cards;
CREATE POLICY "Public select for shared_cards"
  ON public.shared_cards FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert for shared_cards" ON public.shared_cards;
CREATE POLICY "Public insert for shared_cards"
  ON public.shared_cards FOR INSERT WITH CHECK (true);
"""

print("--- Attempting SQL Execution ---")

# Try Supabase Management API query endpoint
url = "https://api.supabase.com/v1/projects/jlfgigvfmxuvlixohzli/db/query"
req = urllib.request.Request(
    url,
    data=json.dumps({"query": sql}).encode('utf-8'),
    headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {SERVICE_KEY}"
    },
    method="POST"
)

try:
    with urllib.request.urlopen(req) as resp:
        print("Response:", resp.status, resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print("Management API HTTPError:", e.code, e.read().decode('utf-8'))
except Exception as e:
    print("Error:", e)
