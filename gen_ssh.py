"""Generate SSH config entries based on docker-compose port mappings.

The script reades `compose.yaml` and outputs SSH config entries that expose
the mapped ports via SSH local forwarding.  This is useful if the Docker Compose
stack is running on a remote or virtual machine, and you want to access the
services from your local machine.

The hostname is generated from the current machine's detected IP address.
This may need to be adjusted based on your network setup.

Copy the output and append it to your `~/.ssh/config` file, replacing any
existing entries for the host.
"""

from dotenv import load_dotenv
import envsub
import yaml
import socket

def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(('1.1.1.1', 1))
    return s.getsockname()[0]
ip = get_ip_address()

load_dotenv('.env')

with open('compose.yaml', 'r') as file:
    with envsub.sub(file) as f:
        compose_data = yaml.safe_load(f)

# Extract and print port mappings
ports = {k: v.get('ports', []) for k, v in compose_data['services'].items()}
# pprint(ports)

# Flatten the list of ports
ports = [p for sublist in ports.values() for p in sublist]

# Get the public port from each mapping
public_ports = sorted([int(p.split(':')[0]) for p in ports])
# print(public_ports)

print()
print(f"Host {socket.gethostname()}")
print(f"  Hostname {ip}")
print(f"  User ubuntu")

print()
print(f"Host {socket.gethostname()}-ports")
print(f"  Hostname {ip}")
print(f"  User ubuntu")
for port in public_ports:
    print(f"  LocalForward 127.0.0.1:{port} 127.0.0.1:{port}")
print()
