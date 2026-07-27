#!/usr/bin/env bash
# ==============================================================================
# sync-skills.sh — Sincronização de skills de governança (Mac / Linux)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=""
COMMIT=false
QUIET=false
SOURCE_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY="$2"; shift 2 ;;
    --commit) COMMIT=true; shift ;;
    --quiet) QUIET=true; shift ;;
    --source) SOURCE_OVERRIDE="$2"; shift 2 ;;
    *) echo "Argumento desconhecido: $1" >&2; exit 1 ;;
  esac
done

resolve_source() {
  if [[ -n "$SOURCE_OVERRIDE" ]]; then
    echo "$SOURCE_OVERRIDE"
    return
  fi
  local config_file="$REPO_ROOT/tools/.skills-source"
  if [[ -f "$config_file" ]]; then
    local configured
    configured="$(head -n1 "$config_file" | tr -d '\r\n')"
    if [[ -n "$configured" ]]; then
      if [[ "$configured" = /* ]]; then
        echo "$configured"
      else
        echo "$REPO_ROOT/tools/$configured"
      fi
      return
    fi
  fi
  echo "$(dirname "$REPO_ROOT")/agentic-research-template"
}

folder_hash() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  local entries
  entries="$(find "$dir" -type f | sort | while read -r f; do
    rel="${f#$dir/}"
    if command -v sha256sum >/dev/null 2>&1; then
      h="$(sha256sum "$f" | cut -d' ' -f1)"
    else
      h="$(shasum -a 256 "$f" | cut -d' ' -f1)"
    fi
    printf "%s:%s|" "$rel" "$h"
  done)"
  [[ -n "$entries" ]] || return 0
  if command -v sha256sum >/dev/null 2>&1; then
    printf "%s" "$entries" | sha256sum | cut -d' ' -f1
  else
    printf "%s" "$entries" | shasum -a 256 | cut -d' ' -f1
  fi
}

SOURCE_ROOT="$(resolve_source)"

if [[ ! -d "$SOURCE_ROOT" ]]; then
  [[ "$QUIET" == true ]] || echo "⚠ [ERRO] Repositório mãe não encontrado em: $SOURCE_ROOT" >&2
  exit 1
fi

SOURCE_SKILLS_DIR="$SOURCE_ROOT/.claude/skills"
if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  [[ "$QUIET" == true ]] || echo "⚠ [ERRO] Repositório mãe sem .claude/skills em: $SOURCE_ROOT" >&2
  exit 1
fi

LOCAL_SKILLS_DIR="$REPO_ROOT/.claude/skills"
mkdir -p "$LOCAL_SKILLS_DIR"

[[ "$QUIET" == true ]] || echo "🔄 Comparando skills locais com a mãe em: $SOURCE_ROOT"
[[ "$QUIET" == true ]] || echo ""

TO_APPLY=()

for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  mother_hash="$(folder_hash "${skill_dir%/}")"
  [[ -n "$mother_hash" ]] || continue

  local_dir="$LOCAL_SKILLS_DIR/$name"
  local_hash="$(folder_hash "$local_dir")"

  if [[ -z "$local_hash" ]]; then
    [[ "$QUIET" == true ]] || printf "  %-28s NOVA (não instalada)\n" "$name"
    TO_APPLY+=("$name:nova")
  elif [[ "$local_hash" == "$mother_hash" ]]; then
    [[ "$QUIET" == true ]] || printf "  %-28s em dia\n" "$name"
  else
    [[ "$QUIET" == true ]] || printf "  %-28s desatualizada\n" "$name"
    TO_APPLY+=("$name:desatualizada")
  fi
done

[[ "$QUIET" == true ]] || echo ""

if [[ -z "$APPLY" ]]; then
  if [[ ${#TO_APPLY[@]} -gt 0 && "$QUIET" == false ]]; then
    echo "💡 Existem skills desatualizadas! Rode com --apply all para atualizar."
  fi
  exit 0
fi

APPLIED_NAMES=()
for entry in "${TO_APPLY[@]}"; do
  name="${entry%%:*}"
  if [[ "$APPLY" != "all" && "$APPLY" != "$name" ]]; then continue; fi
  src_dir="$SOURCE_SKILLS_DIR/$name"
  dest_dir="$LOCAL_SKILLS_DIR/$name"
  rm -rf "$dest_dir"
  cp -r "$src_dir" "$dest_dir"
  [[ "$QUIET" == true ]] || echo "  ✅ '$name' copiada da mãe."
  APPLIED_NAMES+=("$name")
done

if [[ ${#APPLIED_NAMES[@]} -eq 0 ]]; then
  [[ "$QUIET" == true ]] || echo "Nada a aplicar para '$APPLY'."
  exit 0
fi

if [[ "$COMMIT" == true ]]; then
  APPLIED_STR="${APPLIED_NAMES[*]}"
  COMMIT_MSG="chore(skills): sync skills from mother template [$APPLIED_STR]"
  for name in "${APPLIED_NAMES[@]}"; do
    git -C "$REPO_ROOT" add ".claude/skills/$name"
  done
  if [[ -f "$REPO_ROOT/NEWS.md" ]]; then
    TS="$(date +'%Y-%m-%d %H:%M')"
    cat <<EOT >> "$REPO_ROOT/NEWS.md"

## $TS — Sincronização de skills de governança

Atualização automatizada das skills: $APPLIED_STR.

**Metadados de Execução**:
- **Data/Hora**: $TS (Horário Local)
- **Agente**: sync-skills.sh / Antigravity
- **Mensagem do Commit**: "$COMMIT_MSG"
- **Arquivos afetados**: .claude/skills/, NEWS.md
EOT
    git -C "$REPO_ROOT" add "$REPO_ROOT/NEWS.md"
  fi
  git -C "$REPO_ROOT" commit -m "$COMMIT_MSG"
  [[ "$QUIET" == true ]] || echo "✅ Commit cirúrgico realizado: '$COMMIT_MSG'"
fi
