#!/usr/bin/env python3
"""Installs the HarmonyOS libraries of the sub-repositories the iOS example uses through CocoaPods, at pinned commits:

- CYLTabBarController `CrossPlatform/harmonyos-cyltabbar/cyltabbar` -> harmonyos/vendor/cyltabbar (the tab bar);
- CYLTableViewPlaceHolder `CrossPlatform/harmonyos-cylplaceholder/cylplaceholder` -> harmonyos/vendor/cylplaceholder
  (CYLRefreshNormalHeader and the placeholder scenarios);
- CollectionViewClassifyMenu `harmony/classifymenu` -> harmonyos/vendor/classifymenu (`CYLTagButton`, the one icon +
  title + animated icon component that draws the search bar items).

The commits are in harmonyos/oh-package.json5 (`cylTabBarControllerCommit`, `cylTableViewPlaceHolderCommit`,
`collectionViewClassifyMenuCommit`; the newest commit on any branch that has the HarmonyOS library,
docs/sub-repositories.md). `CYL_TABBAR_DIR` / `CYL_PLACEHOLDER_DIR` / `CYL_CLASSIFYMENU_DIR` use a local checkout
instead. harmonyos/vendor is git-ignored; run this before building.
Run: python3 harmonyos/scripts/sync-sub-repositories.py
"""
import io, json, os, re, shutil, subprocess, tarfile, tempfile

HARMONY = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
VENDOR = os.path.join(HARMONY, 'vendor')
REPOS = [
    ('cyltabbar', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cyltabbar', 'CYL_TABBAR_DIR', ['LICENSE']),
    ('cylplaceholder', 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', 'cylTableViewPlaceHolderCommit',
     'CrossPlatform/harmonyos-cylplaceholder/cylplaceholder', 'CYL_PLACEHOLDER_DIR', ['LICENSE']),
    ('classifymenu', 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', 'collectionViewClassifyMenuCommit',
     'harmony/classifymenu', 'CYL_CLASSIFYMENU_DIR', []),
]


def pins():
    text = open(os.path.join(HARMONY, 'oh-package.json5'), encoding='utf-8').read()
    return dict(re.findall(r'"(\w+Commit)"\s*:\s*"([0-9a-f]+)"', text))


def archive(repo_dir, commit, paths):
    data = subprocess.run(['git', '-C', repo_dir, 'archive', '--format=tar', commit] + paths,
                          check=True, capture_output=True).stdout
    return tarfile.open(fileobj=io.BytesIO(data))


def main():
    commits = pins()
    os.makedirs(VENDOR, exist_ok=True)
    for name, url, key, path, env, extras in REPOS:
        commit = commits[key]
        local = os.environ.get(env)
        if local:
            repo_dir = local
        else:
            repo_dir = os.path.join(tempfile.gettempdir(), 'cyl-harmony-' + name + '.git')
            if not os.path.isdir(repo_dir):
                subprocess.run(['git', 'init', '--bare', '-q', repo_dir], check=True)
            subprocess.run(['git', '-C', repo_dir, 'fetch', '-q', '--filter=blob:none', url, commit], check=True)
        target = os.path.join(VENDOR, name)
        shutil.rmtree(target, ignore_errors=True)
        with archive(repo_dir, commit, [path] + extras) as tar:
            for member in tar.getmembers():
                if member.name.startswith(path + '/'):
                    relative = member.name[len(path) + 1:]
                elif member.name in extras:
                    relative = member.name
                else:
                    continue
                if not relative or member.isdir():
                    continue
                out = os.path.join(target, relative)
                os.makedirs(os.path.dirname(out), exist_ok=True)
                with tar.extractfile(member) as source, open(out, 'wb') as sink:
                    shutil.copyfileobj(source, sink)
        print(name, commit[:9], '->', os.path.relpath(target, HARMONY))


if __name__ == '__main__':
    main()
