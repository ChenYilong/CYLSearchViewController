#!/usr/bin/env python3
"""Installs the HarmonyOS libraries of the sub-repositories the iOS example uses through CocoaPods, at pinned commits:

- CYLTabBarController `CrossPlatform/harmonyos-cyltabbar/cyltabbar` -> harmonyos/vendor/cyltabbar (the tab bar);
- CYLTableViewPlaceHolder `CrossPlatform/harmonyos-cylplaceholder/cylplaceholder` -> harmonyos/vendor/cylplaceholder
  (CYLRefreshNormalHeader and the placeholder scenarios);
- CollectionViewClassifyMenu `harmony/classifymenu` -> harmonyos/vendor/classifymenu (`CYLTagButton`, the one icon +
  title + animated icon component that draws the search bar items);
- CYLTabBarController `CrossPlatform/harmonyos-cyltabbar/cylanimateditem` -> harmonyos/vendor/cylanimateditem (the shared
  animated icon + title component, `CYLAnimatedItemView`). It comes from the tab bar commit, not from
  CollectionViewClassifyMenu's vendored copy: cyltabbar imports files of its own commit's copy (CYLAnimatedItemGIFTiming
  since f66e85d5) that an older copy lacks. classifymenu and cylplaceholder name it `file:../cylanimateditem`. It
  depends on no animation library: the example registers the engines it plays (entry/src/main/ets/animation).
- CYLTabBarController `CrossPlatform/harmonyos-cyltabbar/cylanimateditem_lottie` -> harmonyos/vendor/cylanimateditem_lottie
  (the Lottie engine of CYLAnimatedItemView; cyltabbar depends on it with `file:../cylanimateditem_lottie`).
- CYLTabBarController `cylanimateditem_pag` and `cylanimateditem_rive` -> harmonyos/vendor (the PAG and Rive engines the
  example registers in entry/src/main/ets/animation).
- CYLTabBarController `CrossPlatform/harmonyos-cyltabbar/cylanimateditemrive` -> harmonyos/vendor/cylanimateditemrive (the
  one shared Rive engine: `CYLRiveIcon`, the loop policies, `cylRegisterRiveEngine`; no own Rive player anywhere).

- CYLTabBarController `CrossPlatform/harmonyos-cyltabbar/cyldeallocblockexecutor` -> harmonyos/vendor/cyldeallocblockexecutor
  (the lifecycle library that cyltabbar and cylanimateditem depend on with `file:../cyldeallocblockexecutor`, since c6b3e976).

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
    ('cylanimateditem', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cylanimateditem', 'CYL_TABBAR_DIR', []),
    ('cylanimateditem_lottie', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cylanimateditem_lottie', 'CYL_TABBAR_DIR', []),
    ('cylanimateditem_pag', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cylanimateditem_pag', 'CYL_TABBAR_DIR', []),
    ('cylanimateditem_rive', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cylanimateditem_rive', 'CYL_TABBAR_DIR', []),
    ('cylanimateditemrive', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cylanimateditemrive', 'CYL_TABBAR_DIR', ['LICENSE']),
    ('cyldeallocblockexecutor', 'https://github.com/ChenYilong/CYLTabBarController.git', 'cylTabBarControllerCommit',
     'CrossPlatform/harmonyos-cyltabbar/cyldeallocblockexecutor', 'CYL_TABBAR_DIR', []),
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
            # One cache per repository: cyltabbar, cylanimateditem, cylanimateditem_lottie and cylanimateditemrive share one.
            cache = os.path.basename(url)[:-len('.git')].lower()
            repo_dir = os.path.join(tempfile.gettempdir(), 'cyl-harmony-' + cache + '.git')
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
