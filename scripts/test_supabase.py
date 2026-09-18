import os
import urllib.request

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

req = urllib.request.Request(
    f"{SUPABASE_URL}/rest/v1/",
    headers={
        "apikey": SERVICE_KEY,
        "Authorization": f"Bearer {SERVICE_KEY}"
    }
)

with urllib.request.urlopen(req) as resp:
    spec = json.loads(resp.read().decode('utf-8'))
    print("Cards schema:", json.dumps(spec.get("definitions", {}).get("cards", {}), indent=2))
