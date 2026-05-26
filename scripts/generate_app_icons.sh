#!/usr/bin/env bash
# 从 1024×1024 源图生成 Android mipmap 与 iOS 应用图标。
#
# 源文件（需自行维护）：
#   assets/app_icons/source/icon_classic_1024.png
#   assets/app_icons/source/icon_ghoul_1024.png
#
# 用法（在项目根目录 soulfood-front/ 下）：
#   ./scripts/generate_app_icons.sh
#   bash scripts/generate_app_icons.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT/assets/app_icons/source"
SRC_CLASSIC="$SRC_DIR/icon_classic_1024.png"
SRC_GHOUL="$SRC_DIR/icon_ghoul_1024.png"

ANDROID_RES="$ROOT/android/app/src/main/res"
IOS_RUNNER="$ROOT/ios/Runner"
ICONSET="$IOS_RUNNER/Assets.xcassets/AppIcon.appiconset"

require_sips() {
  if ! command -v sips >/dev/null 2>&1; then
    echo "error: 需要 macOS 自带的 sips 命令来缩放 PNG。" >&2
    exit 1
  fi
}

require_sources() {
  local missing=0
  for f in "$SRC_CLASSIC" "$SRC_GHOUL"; do
    if [[ ! -f "$f" ]]; then
      echo "error: 缺少源图 $f" >&2
      missing=1
    fi
  done
  if [[ "$missing" -ne 0 ]]; then
    echo "请将 1024×1024 PNG 放入 assets/app_icons/source/ 后重试。" >&2
    exit 1
  fi
}

resize() {
  local size="$1"
  local src="$2"
  local dest="$3"
  mkdir -p "$(dirname "$dest")"
  sips -z "$size" "$size" "$src" --out "$dest" >/dev/null
  echo "  wrote $(basename "$dest") (${size}px)"
}

generate_android() {
  echo "==> Android mipmap"
  local spec size density
  for spec in \
    "48:mdpi" \
    "72:hdpi" \
    "96:xhdpi" \
    "144:xxhdpi" \
    "192:xxxhdpi"; do
    size="${spec%%:*}"
    density="${spec##*:}"
    local dir="$ANDROID_RES/mipmap-$density"
    mkdir -p "$dir"
    resize "$size" "$SRC_CLASSIC" "$dir/ic_launcher.png"
    resize "$size" "$SRC_GHOUL" "$dir/ic_launcher_ghoul.png"
  done

  mkdir -p "$ANDROID_RES/mipmap-anydpi-v26"
  cat >"$ANDROID_RES/mipmap-anydpi-v26/ic_launcher.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_classic_bg"/>
    <foreground android:drawable="@mipmap/ic_launcher"/>
</adaptive-icon>
EOF

  cat >"$ANDROID_RES/mipmap-anydpi-v26/ic_launcher_ghoul.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_ghoul_bg"/>
    <foreground android:drawable="@mipmap/ic_launcher_ghoul"/>
</adaptive-icon>
EOF

  mkdir -p "$ANDROID_RES/values"
  cat >"$ANDROID_RES/values/ic_launcher_colors.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_classic_bg">#FFF6CF57</color>
    <color name="ic_launcher_ghoul_bg">#FF1C1C1E</color>
</resources>
EOF
  echo "  wrote adaptive-icon XML + ic_launcher_colors.xml"
}

generate_ios_classic() {
  echo "==> iOS AppIcon.appiconset (classic)"
  mkdir -p "$ICONSET"

  resize 40 "$SRC_CLASSIC" "$ICONSET/Icon-App-20x20@2x.png"
  resize 60 "$SRC_CLASSIC" "$ICONSET/Icon-App-20x20@3x.png"
  resize 29 "$SRC_CLASSIC" "$ICONSET/Icon-App-29x29@1x.png"
  resize 58 "$SRC_CLASSIC" "$ICONSET/Icon-App-29x29@2x.png"
  resize 87 "$SRC_CLASSIC" "$ICONSET/Icon-App-29x29@3x.png"
  resize 80 "$SRC_CLASSIC" "$ICONSET/Icon-App-40x40@2x.png"
  resize 120 "$SRC_CLASSIC" "$ICONSET/Icon-App-40x40@3x.png"
  resize 120 "$SRC_CLASSIC" "$ICONSET/Icon-App-60x60@2x.png"
  resize 180 "$SRC_CLASSIC" "$ICONSET/Icon-App-60x60@3x.png"
  resize 20 "$SRC_CLASSIC" "$ICONSET/Icon-App-20x20@1x.png"
  resize 40 "$SRC_CLASSIC" "$ICONSET/Icon-App-40x40@1x.png"
  resize 76 "$SRC_CLASSIC" "$ICONSET/Icon-App-76x76@1x.png"
  resize 152 "$SRC_CLASSIC" "$ICONSET/Icon-App-76x76@2x.png"
  resize 167 "$SRC_CLASSIC" "$ICONSET/Icon-App-83.5x83.5@2x.png"
  resize 1024 "$SRC_CLASSIC" "$ICONSET/Icon-App-1024x1024@1x.png"
}

generate_ios_ghoul_alternate() {
  echo "==> iOS alternate icons (ghoul)"
  # 须放在 Runner/ 目录，文件名与 Info.plist CFBundleAlternateIcons 一致
  resize 120 "$SRC_GHOUL" "$IOS_RUNNER/icon_ghoul@2x.png"
  resize 180 "$SRC_GHOUL" "$IOS_RUNNER/icon_ghoul@3x.png"
}

main() {
  require_sips
  require_sources

  echo "DecideMeal app icon generator"
  echo "  root:   $ROOT"
  echo "  classic: $SRC_CLASSIC"
  echo "  ghoul:   $SRC_GHOUL"
  echo

  generate_android
  echo
  generate_ios_classic
  echo
  generate_ios_ghoul_alternate
  echo
  echo "Done. 重新编译安装后即可看到新图标。"
  echo "动态切换：外观设置 → 应用图标（真机；alias 名 icon_ghoul）。"
}

main "$@"
