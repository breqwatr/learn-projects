"""Fail on anything that belongs to a test environment rather than a reader's project: test
resource prefixes and domains, real email addresses, and IP addresses other than the subnet
ranges, public DNS servers and documentation addresses the tutorials use."""
import ipaddress, pathlib, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
DENY = [r'learn-verify', r'sslip\.io', r'nip\.io', r'kolla', r'breqwatr\.dev', r'\bdev-dev\b', r'\bbreq-dev\b',
        r'VLAN\d+', r'RegionOne', r'BEGIN CERTIFICATE', r'BEGIN [A-Z ]*PRIVATE KEY']
EMAIL = re.compile(r'[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\.)+[A-Za-z]{2,}')
EMAIL_OK = re.compile(r'@example\.(com|org|net)$|^noreply@github\.com$')
IPV4 = re.compile(r'(?<![\d.])(\d{1,3}(?:\.\d{1,3}){3})(?:/(\d{1,2}))?(?![\d.])')
IP_OK = [ipaddress.ip_network(n) for n in ('0.0.0.0/32', '192.0.2.0/24', '198.51.100.0/24', '203.0.113.0/24', '1.1.1.1/32', '1.0.0.1/32', '127.0.0.0/8')]
SKIP = {'scripts/deny_list.py', 'LICENSE'}


def ip_ok(addr, prefix):
    ip = ipaddress.ip_address(addr)
    if any(ip in n for n in IP_OK):
        return True
    # Private subnet ranges written as a network, such as 10.40.0.0/24, are the tutorials' own subnets
    return prefix is not None and ip.is_private and ipaddress.ip_network(f'{addr}/{prefix}', strict=False).network_address == ip


tracked = subprocess.run(['git', 'ls-files'], cwd=ROOT, capture_output=True, text=True, check=True).stdout.split()
found = 0
for rel in tracked:
    if rel in SKIP or rel.endswith('.lock.hcl'):
        continue
    for n, line in enumerate((ROOT / rel).read_text(errors='replace').splitlines(), 1):
        hits = [m.group(0) for p in DENY for m in re.finditer(p, line, re.I)]
        hits += [m.group(0) for m in EMAIL.finditer(line) if not EMAIL_OK.search(m.group(0))]
        hits += [m.group(0) for m in IPV4.finditer(line) if not ip_ok(m.group(1), m.group(2))]
        for h in hits:
            print(f'{rel}:{n}: {h}'); found += 1
print(f'Deny-list: {found} finding(s) in {len(tracked)} tracked file(s)')
sys.exit(1 if found else 0)
