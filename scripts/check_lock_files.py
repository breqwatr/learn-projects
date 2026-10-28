"""Every OpenTofu folder commits a .terraform.lock.hcl that covers each provider it requires,
with hashes for Linux, macOS and Windows. `tofu init -lockfile=readonly` in CI checks that the
lock matches the version constraints; this checks the file is there and complete."""
import pathlib, re, sys

from tofu_folders import ROOT, folders

PLATFORMS = 5  # linux_amd64, linux_arm64, darwin_amd64, darwin_arm64, windows_amd64

failed = False
for folder in folders():
    name = folder.relative_to(ROOT)
    lock = folder / '.terraform.lock.hcl'
    if not lock.exists():
        print(f'{name}: no .terraform.lock.hcl'); failed = True; continue
    ok = True
    text = lock.read_text()
    locked = dict(re.findall(r'provider "registry\.opentofu\.org/([^"]+)" \{(.*?)\n\}', text, re.S))
    code = ''.join(p.read_text() for p in folder.rglob('*.tf') if '.terraform' not in p.parts)
    required = set(re.findall(r'source\s*=\s*"([\w-]+/[\w-]+)"', code))
    for source in sorted(required):
        if source not in locked:
            print(f'{name}: {source} is required but not in the lock file'); ok = False
        elif len(re.findall(r'"h1:', locked[source])) < PLATFORMS:
            print(f'{name}: {source} has hashes for fewer than {PLATFORMS} platforms'); ok = False
    for source in sorted(set(locked) - required):
        print(f'{name}: {source} is in the lock file but not required'); ok = False
    if ok:
        print(f'{name}: {len(required)} provider(s) locked')
    failed |= not ok
sys.exit(1 if failed else 0)
