#!/usr/bin/env bash
set -euo pipefail

imports="/home/toubi/01 - Dev/00 - Projets à tester"
out="/home/toubi/dotfiles/nord-violet/maquettes/audits/generated"
mkdir -p "$out"

ryoku="$imports/qml-go--ryoku"
caelestia="$imports/qml-cpp--caelestia-shell"
noctalia="$imports/cpp--noctalia"
dms="$imports/qml-go--dank-material-shell"

{
  printf '# Ryoku — inventaire extrait du code\n\n'
  printf 'Source locale : `%s`  \nRévision : `%s`\n\n' "$ryoku" "$(git -C "$ryoku" rev-parse HEAD)"
  printf '## Pages du Hub\n\n'
  find "$ryoku/ryoku/hub/quickshell/pages" -maxdepth 1 -type f -name '*.qml' -printf '%f\n' | sort | sed 's/^/- /'
  printf '\n## Réglages déclarés dans les schémas\n'
  for file in "$ryoku"/ryoku/hub/quickshell/schema/*Page.js "$ryoku/ryoku/hub/quickshell/schema/WindowSettings.js"; do
    printf '\n### %s\n\n' "$(basename "$file" .js)"
    awk '
      /"tab"[[:space:]]*:/ || /"group"[[:space:]]*:/ || /"label"[[:space:]]*:/ || /"desc"[[:space:]]*:/ || /"key"[[:space:]]*:/ {
        line=$0; sub(/^[[:space:]]*/, "", line); sub(/,$/, "", line); print "- `" line "`"
      }
    ' "$file"
  done
  printf '\n## Modules visibles du shell\n\n'
  find "$ryoku/ryoku/shell/quickshell/shell/modules" -mindepth 1 -maxdepth 2 -type d -printf '%P\n' | sort -u | sed 's/^/- /'
  printf '\n## Backends du Hub\n\n'
  find "$ryoku/ryoku/hub/backend" -maxdepth 1 -type f -name '*.go' ! -name '*_test.go' -printf '%f\n' | sort | sed 's/^/- /'
  printf '\n## Sous-systèmes livrés\n\n'
  find "$ryoku/ryoku" -mindepth 1 -maxdepth 2 -type d -printf '%P\n' | sort -u | sed 's/^/- /'
} > "$out/RYOKU-INVENTORY.md"

{
  printf '# Caelestia — inventaire extrait du code\n\n'
  printf 'Source locale : `%s`  \nRévision : `%s`\n\n' "$caelestia" "$(git -C "$caelestia" rev-parse HEAD)"
  printf '## Pages et sous-pages Nexus\n\n'
  find "$caelestia/modules/nexus/pages" -type f -name '*.qml' -printf '%P\n' | sort | sed 's/^/- /'
  printf '\n## Libellés et descriptions déclarés par page\n'
  while IFS= read -r file; do
    printf '\n### %s\n\n' "${file#"$caelestia/"}"
    rg -o 'text:[[:space:]]*(Tr\.tr\()?"[^"]+"|title:[[:space:]]*(Tr\.tr\()?"[^"]+"|description:[[:space:]]*(Tr\.tr\()?"[^"]+"' "$file" | sort -u | sed 's/^/- `/' | sed 's/$/`/' || true
  done < <(find "$caelestia/modules/nexus/pages" -type f -name '*.qml' | sort)
  printf '\n## Modules du shell\n\n'
  find "$caelestia/modules" -mindepth 1 -maxdepth 3 -type d -printf '%P\n' | sort -u | sed 's/^/- /'
  printf '\n## Services QML\n\n'
  find "$caelestia/services" -maxdepth 1 -type f -name '*.qml' -printf '%f\n' | sort | sed 's/^/- /'
  printf '\n## Services natifs du plugin\n\n'
  find "$caelestia/plugin/src/Caelestia/Services" -maxdepth 1 -type f -name '*.hpp' -printf '%f\n' | sort | sed 's/^/- /'
  printf '\n## Nœuds de configuration\n\n'
  find "$caelestia/plugin/src/Caelestia/Config" -maxdepth 1 -type f -name '*config.hpp' -printf '%f\n' | sort | sed 's/^/- /'
} > "$out/CAELESTIA-INVENTORY.md"

{
  printf '# Noctalia v5 — inventaire extrait du code\n\n'
  printf 'Source locale : `%s`  \nRévision : `%s`\n\n' "$noctalia" "$(git -C "$noctalia" rev-parse HEAD)"
  printf '## Configuration complète fournie par le projet\n\n'
  awk '
    /^\[[^]]+\]/ { print "\n### `" $0 "`\n"; next }
    /^[A-Za-z0-9_]+[[:space:]]*=/ {
      line=$0; sub(/[[:space:]]+#[^#]*$/, "", line); print "- `" line "`"
    }
  ' "$noctalia/example.toml"
  printf '\n## Documentation fonctionnelle\n\n'
  find "$noctalia/docs/user" -type f -name '*.mdx' -printf '%P\n' | sort | sed 's/^/- /'
  printf '\n## Surfaces du shell\n\n'
  find "$noctalia/src/shell" -mindepth 1 -maxdepth 2 -type d -printf '%P\n' | sort -u | sed 's/^/- /'
  printf '\n## Intégrations système et compositeurs\n\n'
  find "$noctalia/src/compositors" "$noctalia/src/dbus" "$noctalia/src/wayland" -mindepth 1 -maxdepth 2 -type d -printf '%P\n' | sort -u | sed 's/^/- /'
  printf '\n## Modèles d’applications livrés\n\n'
  find "$noctalia/assets/templates" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | sed 's/^/- /'
} > "$out/NOCTALIA-INVENTORY.md"

{
  printf '# DankMaterialShell — inventaire extrait du code\n\n'
  printf 'Source locale : `%s`  \nRévision : `%s`\n\n' "$dms" "$(git -C "$dms" rev-parse HEAD)"
  printf 'Le catalogue de recherche contient **%s entrées**. Les doublons de libellé sont conservés lorsqu’ils appartiennent à des pages différentes.\n\n' "$(jq length "$dms/quickshell/translations/settings_search_index.json")"
  jq -r '
    sort_by(.page, .category, .label)
    | group_by(.page)[]
    | "## " + (.[0].page // "sans-page") + " — " + (length|tostring) + " entrées\n"
      + (group_by(.category)[]
        | "\n### " + (.[0].category // "Sans catégorie") + "\n\n"
          + (map("- **" + .label + "** (`" + .section + "`)"
              + (if .description then " — " + .description else "" end)
              + (if .conditionKey then " — condition : `" + .conditionKey + "`" else "" end))
             | join("\n")))
      + "\n"
  ' "$dms/quickshell/translations/settings_search_index.json"
  printf '\n## Modules du shell\n\n'
  find "$dms/quickshell/Modules" -mindepth 1 -maxdepth 2 -type d -printf '%P\n' | sort -u | sed 's/^/- /'
  printf '\n## Services\n\n'
  find "$dms/quickshell/Services" -maxdepth 1 -type f -name '*.qml' -printf '%f\n' | sort | sed 's/^/- /'
  printf '\n## Cibles Matugen livrées\n\n'
  find "$dms/quickshell/matugen/configs" -maxdepth 1 -type f -name '*.toml' -printf '%f\n' | sort | sed 's/^/- /'
} > "$out/DMS-INVENTORY.md"

printf 'Inventaires générés dans %s\n' "$out"
