"""rebuild-dont-repair (4.5) is three-tier-web-app (4.4) with one change: prevent_destroy on the
database's data volume, between the section markers the page embeds. Fail on any other difference."""
import pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
A, B = ROOT / 'three-tier-web-app', ROOT / 'rebuild-dont-repair'
CHANGE = '\n\n  lifecycle {\n    prevent_destroy = true\n  }\n'
MARKERS = ('# --8<-- [start:protect]\n', '# --8<-- [end:protect]\n')


def files(d):
    return {p.relative_to(d) for p in d.rglob('*') if p.is_file() and p.name != 'README.md' and '.terraform' not in p.parts}


failed = False
if files(A) != files(B):
    print('Different files:', sorted(map(str, files(A) ^ files(B)))); failed = True
for rel in sorted(files(A) & files(B)):
    a, b = (A / rel).read_text(), (B / rel).read_text()
    if str(rel) == 'database.tf':
        for m in MARKERS:
            if b.count(m) != 1:
                print(f'database.tf: expected one {m.strip()!r}'); failed = True
            b = b.replace(m, '')
        if b.count(CHANGE) != 1:
            print('database.tf: expected one prevent_destroy lifecycle block'); failed = True
        b = b.replace(CHANGE, '\n', 1)
    if a != b:
        print(f'{rel}: differs from three-tier-web-app beyond the 4.5 change'); failed = True
print('rebuild-dont-repair differs from three-tier-web-app only by the 4.5 change' if not failed else 'Diff check failed')
sys.exit(1 if failed else 0)
