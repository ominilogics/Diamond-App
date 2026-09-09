import json
import urllib.request

SUPABASE_URL = "https://jlfgigvfmxuvlixohzli.supabase.co"
SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsZmdpZ3ZmbXh1dmxpeG9oemxpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjM0NTMzMCwiZXhwIjoyMDk3OTIxMzMwfQ.HIJd0uoxUXaRfPCWP0NNmWOAk0njM-8ZfzTC3k60Md0"

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
