import sys

from urllib.request import Request, urlopen

# Simple health check for Django application
# Exits with code 0 if healthy, 1 otherwise

req = Request("http://localhost:8000/api/healthz")
with urlopen(req, timeout=5) as resp:
    pass
if resp.status != 200:
    print('Error, status code:', resp.status)
    sys.exit(1)
print('OK')
sys.exit(0)
