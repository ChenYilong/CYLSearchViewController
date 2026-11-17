#!/usr/bin/env bash
# Every package this repository publishes to an external registry carries its license declaration, inside its
# resource bundle when it has one (AGENTS.md, "Licenses in published packages"; docs/licenses.md).
set -euo pipefail
cd "$(dirname "$0")/.."

# One line per published package: the license file it must ship, inside its bundle where the package has one.
required=(
  LICENSE                                                                                    # repository, CocoaPods license file
  Resources/CYLSearchViewController.bundle/LICENSE                                           # CocoaPods resource bundle
  android/merged/cylsearch/src/main/resources/META-INF/cylsearch/LICENSE                     # Android library (Maven / Gradle): in the AAR's classes.jar
  harmonyos/cylsearch/LICENSE                                                                # ohpm package root
  harmonyos/cylsearch/src/main/resources/rawfile/CYLSearchViewController.bundle/LICENSE      # HarmonyOS resource bundle
  CrossPlatform/react-native-cylsearch/LICENSE                                               # npm
  CrossPlatform/wechat-miniprogram-cylsearch/LICENSE                                         # npm (mini program)
  CrossPlatform/wechat-miniprogram-cylsearch/src/LICENSE                                     # mini program component folder
  CrossPlatform/flutter_cylsearch/LICENSE                                                    # pub.dev
)

status=0
for file in "${required[@]}"; do
  if [ ! -f "$file" ]; then
    echo "error: $file is missing" >&2
    status=1
  elif ! cmp -s LICENSE "$file"; then
    echo "error: $file differs from LICENSE" >&2
    status=1
  fi
done

# The declared license in each manifest matches the file.
grep -q "s.license = { :type => 'MIT', :file => 'LICENSE' }" CYLSearchViewController.podspec \
  || { echo "error: CYLSearchViewController.podspec does not declare the MIT LICENSE file" >&2; status=1; }
for manifest in CrossPlatform/react-native-cylsearch/package.json CrossPlatform/wechat-miniprogram-cylsearch/package.json; do
  grep -q '"license": "MIT"' "$manifest" || { echo "error: $manifest does not declare MIT" >&2; status=1; }
done
grep -q 'license": "MIT"' harmonyos/cylsearch/oh-package.json5 \
  || { echo "error: harmonyos/cylsearch/oh-package.json5 does not declare MIT" >&2; status=1; }

if [ "$status" -eq 0 ]; then
  echo "Licenses: OK (${#required[@]} files)"
fi
exit "$status"
