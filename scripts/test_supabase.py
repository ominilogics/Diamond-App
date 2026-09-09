import json
import urllib.request

SUPABASE_URL = "https://jlfgigvfmxuvlixohzli.supabase.co"
SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsZmdpZ3ZmbXh1dmxpeG9oemxpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjM0NTMzMCwiZXhwIjoyMDk3OTIxMzMwfQ.HIJd0uoxUXaRfPCWP0NNmWOAk0njM-8ZfzTC3k60Md0"

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
