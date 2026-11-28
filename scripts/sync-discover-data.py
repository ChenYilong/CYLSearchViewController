#!/usr/bin/env python3
"""Keeps the Discover demo data of every example equal to the iOS source and checks its refresh rule.

Source: CYLSearchExample/CYLSearchDiscover.bundle/<lang>.lproj/search-discover.json (en, ja, zh-Hans, zh-Hant).
Rule (docs/animated-icon-component.md, "Refresh, hot data and navigation bar contract"):
  - the pool is a whole number of pages of `discoverCount` records, at least 2 pages;
  - each page has exactly one record with "icon": "hot" (the hot mark lives in the record of its tag);
  - the slot of the hot record on a page differs from its slot on the next page, wrap-around included;
  - every language has the same records in the same order, so the same hot slots.
Usage: sync-discover-data.py [--check] [--apply-hot]
  --check      only validate the source and report the targets that differ
  --apply-hot  rewrite the hot marks of the source to HOT_SLOTS (a deliberate data change), then sync
"""
import json, os, sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
LANGS = ["en", "ja", "zh-Hans", "zh-Hant"]
HOT_SLOTS = [0, 3, 5, 1]  # the slot of the hot record on page 0, 1, 2, 3 (consecutive pages and the wrap differ)
SOURCE = "CYLSearchExample/CYLSearchDiscover.bundle/{lang}.lproj/search-discover.json"
FLUTTER = "CrossPlatform/flutter_cylsearch/example/assets/discover/{lang}/search-discover.json"
RN = "CrossPlatform/react-native-cylsearch/example/src/search-discover.json"
# Other examples add their copies here (Android assets, HarmonyOS rawfile, mini program); each is a full copy of the source file.
HARMONYOS = {  # the rawfile names are the HarmonyOS locale qualifiers
    "en": "harmonyos/entry/src/main/resources/rawfile/discover/base.json",
    "ja": "harmonyos/entry/src/main/resources/rawfile/discover/ja_JP.json",
    "zh-Hans": "harmonyos/entry/src/main/resources/rawfile/discover/zh_CN.json",
    "zh-Hant": "harmonyos/entry/src/main/resources/rawfile/discover/zh_TW.json",
}
MINIPROGRAM = "CrossPlatform/wechat-miniprogram-cylsearch/example/miniprogram/utils/discover/{lang}.json"
ANDROID = "android/merged/app/src/main/assets/CYLSearchDiscover.bundle/{lang}.lproj/search-discover.json"
COPIES = {
    "android": ANDROID,
    "flutter": FLUTTER,
    "harmonyos": HARMONYOS,
    "miniprogram": MINIPROGRAM,
}


def read(path):
    with open(os.path.join(ROOT, path), encoding="utf-8") as handle:
        return json.load(handle)


def write(path, data):
    with open(os.path.join(ROOT, path), "w", encoding="utf-8") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def validate(sources):
    problems = []
    reference = None
    for lang in LANGS:
        data = sources[lang]
        count = data["discoverCount"]
        topics = data["discover"]
        if count <= 0 or len(topics) % count or len(topics) // count < 2:
            problems.append(f"{lang}: {len(topics)} records are not 2 or more pages of {count}")
            continue
        pages = len(topics) // count
        slots = []
        for page in range(pages):
            hot = [i for i, t in enumerate(topics[page * count:(page + 1) * count]) if t.get("icon") == "hot"]
            if len(hot) != 1:
                problems.append(f"{lang}: page {page} has {len(hot)} hot records, need exactly 1")
            slots.append(hot[0] if hot else -1)
        for page in range(pages):
            if slots[page] == slots[(page + 1) % pages]:
                problems.append(f"{lang}: the hot slot {slots[page]} repeats from page {page} to page {(page + 1) % pages}")
        if reference is None:
            reference = slots
        elif slots != reference:
            problems.append(f"{lang}: hot slots {slots} differ from {reference}")
    return problems


def main():
    check = "--check" in sys.argv
    sources = {lang: read(SOURCE.format(lang=lang)) for lang in LANGS}
    if "--apply-hot" in sys.argv:
        for lang in LANGS:
            data = sources[lang]
            count = data["discoverCount"]
            for index, topic in enumerate(data["discover"]):
                topic.pop("icon", None)
                if index % count == HOT_SLOTS[(index // count) % len(HOT_SLOTS)]:
                    topic["icon"] = "hot"
            data["comment"] = ("Sample data of the search history and discover demo (CYLSearchDiscoverViewController), one file per "
                               "language (the same topics, in the same order): recent searches, and pages of discoverCount discover "
                               "topics; refresh shows the next page, cyclically. A topic with icon 'hot' shows the localized hot icon "
                               "(discover-hot.png of the same .lproj) after its title; each page has exactly one, at a different slot "
                               "from the next page (scripts/sync-discover-data.py --check).")
            write(SOURCE.format(lang=lang), data)
    problems = validate(sources)
    for problem in problems:
        print("error:", problem)
    differs = []
    for name, template in COPIES.items():
        for lang in LANGS:
            path = template[lang] if isinstance(template, dict) else template.format(lang=lang)
            if not os.path.exists(os.path.join(ROOT, path)):
                if check:
                    differs.append(f"{name}: {path} missing")
                else:
                    os.makedirs(os.path.dirname(os.path.join(ROOT, path)), exist_ok=True)
                    write(path, sources[lang])
            elif read(path) != sources[lang]:
                if check:
                    differs.append(f"{name}: {path} differs")
                else:
                    write(path, sources[lang])
    rn = read(RN)
    wanted = {lang: {"recentSearches": sources[lang]["recentSearches"], "discover": sources[lang]["discover"]} for lang in LANGS}
    if rn.get("data") != wanted or rn.get("discoverCount") != sources["en"]["discoverCount"]:
        if check:
            differs.append(f"rn: {RN} differs")
        else:
            rn["data"] = wanted
            rn["discoverCount"] = sources["en"]["discoverCount"]
            write(RN, rn)
    for item in differs:
        print("differs:", item)
    if problems or (check and differs):
        sys.exit(1)
    print("Discover data: OK" if check else "Discover data: synced")


if __name__ == "__main__":
    main()
