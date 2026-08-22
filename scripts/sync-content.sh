#!/bin/bash
set -euo pipefail

SUBMODULE="content-source"
CONTENT_EN="content-en"
DOCS="src/content/docs"
IMAGES="public/images"

# Verify submodule exists
if [ ! -d "$SUBMODULE" ] || [ ! -f "$SUBMODULE/README.md" ]; then
  echo "ERROR: Submodule '$SUBMODULE' not found. Run: git submodule update --init --recursive"
  exit 1
fi

# ============================================================================
# CONTENT MAP — the single source of truth for what gets published.
#
# Adding a page? Add ONE line here, and one entry in `rewrite_links` below if
# other pages link to it with a relative .md path. Nothing else to touch except
# the sidebar in astro.config.mjs.
#
# Format: source.md | dest/path.md | sidebar_order | FR title | EN title
# ============================================================================
CONTENT_MAP=(
  "00-prerequisites.md|modules/00-prerequisites.md|0|Module 0 : Prérequis|Module 0: Prerequisites"
  "01-linux-basics.md|modules/01-linux-basics.md|1|Module 1 : Linux|Module 1: Linux"
  "02-networking.md|modules/02-networking.md|2|Module 2 : Réseau|Module 2: Networking"
  "03-docker.md|modules/03-docker.md|3|Module 3 : Docker|Module 3: Docker"
  "04-cicd.md|modules/04-cicd.md|4|Module 4 : CI/CD|Module 4: CI/CD"
  "05-aws.md|modules/05-aws.md|5|Module 5 : AWS|Module 5: AWS"
  "06-terraform.md|modules/06-terraform.md|6|Module 6 : Terraform|Module 6: Terraform"
  "07-ansible.md|modules/07-ansible.md|7|Module 7 : Ansible|Module 7: Ansible"
  "08-monitoring.md|modules/08-monitoring.md|8|Module 8 : Monitoring|Module 8: Monitoring"
  "09-kubernetes.md|modules/09-kubernetes.md|9|Module 9 : Kubernetes|Module 9: Kubernetes"

  "interview-questions.md|entretien/interview-questions.md|0|Questions d'entretien|Interview Questions"
  "interview-experience.md|entretien/interview-experience.md|1|Questions d'expérience|Experience Questions"
  "system-design-exercises.md|entretien/system-design.md|2|System Design|System Design"

  "floci-aws-local.md|references/aws-local.md|0|AWS en local|AWS Locally"
  "cheatsheet.md|references/cheatsheet.md|1|Cheatsheet|Cheatsheet"
  "troubleshooting.md|references/troubleshooting.md|2|Troubleshooting|Troubleshooting"
  "aller-plus-loin.md|references/aller-plus-loin.md|3|Aller plus loin|Going Further"

  "devops-project/README.md|projet/index.md|0|Projet fil rouge|Hands-on Project"
)

# Clean previous sync (preserve hand-written files: index.mdx, en/index.mdx)
rm -rf "$DOCS/modules" "$DOCS/entretien" "$DOCS/references" "$DOCS/projet"
rm -rf "$DOCS/en/modules" "$DOCS/en/entretien" "$DOCS/en/references" "$DOCS/en/projet"
rm -rf "$IMAGES"

# Create dirs
mkdir -p "$DOCS/modules" "$DOCS/entretien" "$DOCS/references" "$DOCS/projet" "$IMAGES"
mkdir -p "$DOCS/en/modules" "$DOCS/en/entretien" "$DOCS/en/references" "$DOCS/en/projet"

# Copy assets
cp "$SUBMODULE"/assets/*.png "$IMAGES/" 2>/dev/null || true
cp "$SUBMODULE"/assets/*.pdf "$IMAGES/" 2>/dev/null || true

# === Link rewriting: relative .md links → site routes ===
rewrite_links() {
  local prefix="${1:-}"
  sed \
    -e "s|](00-prerequisites.md)|](${prefix}/modules/00-prerequisites/)|g" \
    -e "s|](01-linux-basics.md)|](${prefix}/modules/01-linux-basics/)|g" \
    -e "s|](02-networking.md)|](${prefix}/modules/02-networking/)|g" \
    -e "s|](03-docker.md)|](${prefix}/modules/03-docker/)|g" \
    -e "s|](04-cicd.md)|](${prefix}/modules/04-cicd/)|g" \
    -e "s|](05-aws.md)|](${prefix}/modules/05-aws/)|g" \
    -e "s|](06-terraform.md)|](${prefix}/modules/06-terraform/)|g" \
    -e "s|](07-ansible.md)|](${prefix}/modules/07-ansible/)|g" \
    -e "s|](08-monitoring.md)|](${prefix}/modules/08-monitoring/)|g" \
    -e "s|](09-kubernetes.md)|](${prefix}/modules/09-kubernetes/)|g" \
    -e "s|](system-design-exercises.md)|](${prefix}/entretien/system-design/)|g" \
    -e "s|](interview-questions.md)|](${prefix}/entretien/interview-questions/)|g" \
    -e "s|](interview-experience.md)|](${prefix}/entretien/interview-experience/)|g" \
    -e "s|](floci-aws-local.md)|](${prefix}/references/aws-local/)|g" \
    -e "s|](../floci-aws-local.md)|](${prefix}/references/aws-local/)|g" \
    -e "s|](cheatsheet.md)|](${prefix}/references/cheatsheet/)|g" \
    -e "s|](troubleshooting.md)|](${prefix}/references/troubleshooting/)|g" \
    -e "s|](aller-plus-loin.md)|](${prefix}/references/aller-plus-loin/)|g" \
    -e 's|](assets/|](/images/|g' \
    -e 's|(assets/|(/images/|g'
}

# === Process a file: inject frontmatter, strip H1, rewrite links ===
process_file() {
  local src="$1"
  local dest="$2"
  local title="$3"
  local order="$4"
  local link_prefix="${5:-}"

  {
    echo "---"
    echo "title: \"$title\""
    if [ "$order" != "-1" ]; then
      echo "sidebar:"
      echo "  order: $order"
    fi
    echo "---"
    echo ""
    # Strip the first H1 line (starts with "# ") and any immediately following blank line
    awk 'NR==1 && /^# /{next} NR==2 && /^$/{next} {print}' "$src"
  } | rewrite_links "$link_prefix" > "$dest"
}

# === Sync one locale from the content map ===
# $1 = source root, $2 = destination root, $3 = link prefix, $4 = title column (4=FR, 5=EN)
sync_locale() {
  local src_root="$1" dest_root="$2" prefix="$3" title_col="$4"
  local count=0

  for entry in "${CONTENT_MAP[@]}"; do
    IFS='|' read -r src dest order title_fr title_en <<< "$entry"
    local title
    [ "$title_col" = "4" ] && title="$title_fr" || title="$title_en"

    if [ -f "$src_root/$src" ]; then
      process_file "$src_root/$src" "$dest_root/$dest" "$title" "$order" "$prefix"
      count=$((count + 1))
    fi
  done

  echo "$count"
}

# === FRENCH (from content-source/) ===
FR_COUNT=$(sync_locale "$SUBMODULE" "$DOCS" "" 4)

# === ENGLISH (from content-en/) ===
if [ -d "$CONTENT_EN" ] && [ -n "$(ls -A "$CONTENT_EN"/*.md 2>/dev/null)" ]; then
  echo "Syncing English content..."
  EN_COUNT=$(sync_locale "$CONTENT_EN" "$DOCS/en" "/en" 5)
else
  EN_COUNT=0
  echo "No English content found in $CONTENT_EN/ — skipping EN sync."
fi

# === Report ===
echo ""
echo "Content synced successfully."
echo "  - $FR_COUNT French pages"
echo "  - $EN_COUNT English pages"
echo "      modules   : $(find "$DOCS/modules" -name '*.md' | wc -l | tr -d ' ')"
echo "      entretien : $(find "$DOCS/entretien" -name '*.md' | wc -l | tr -d ' ')"
echo "      references: $(find "$DOCS/references" -name '*.md' | wc -l | tr -d ' ')"
echo "      projet    : $(find "$DOCS/projet" -name '*.md' | wc -l | tr -d ' ')"
echo "  - $(find "$IMAGES" -type f | wc -l | tr -d ' ') assets"

# === Warn about unrewritten relative .md links (would 404 on the site) ===
BROKEN=$(grep -rhoE '\]\([^)]*\.md\)' "$DOCS" 2>/dev/null | sort -u || true)
if [ -n "$BROKEN" ]; then
  echo ""
  echo "WARNING: these relative .md links were not rewritten and will 404:"
  echo "$BROKEN" | sed 's/^/  /'
  echo "Add them to rewrite_links() in scripts/sync-content.sh"
fi
