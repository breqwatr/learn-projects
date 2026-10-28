"""Print every OpenTofu folder: a folder with .tf files that isn't inside a modules/ folder."""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent


def folders():
    found = {p.parent for p in ROOT.rglob('*.tf') if '.terraform' not in p.parts and 'modules' not in p.relative_to(ROOT).parts}
    return sorted(found)


if __name__ == '__main__':
    for f in folders():
        print(f.relative_to(ROOT))
