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

# === Link rewriting functions ===
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

# === MODULES ===
process_file "$SUBMODULE/00-prerequisites.md" "$DOCS/modules/00-prerequisites.md" "Module 0 : Prérequis" 0
process_file "$SUBMODULE/01-linux-basics.md"  "$DOCS/modules/01-linux-basics.md"  "Module 1 : Linux" 1
process_file "$SUBMODULE/02-networking.md"    "$DOCS/modules/02-networking.md"    "Module 2 : Réseau" 2
process_file "$SUBMODULE/03-docker.md"        "$DOCS/modules/03-docker.md"        "Module 3 : Docker" 3
process_file "$SUBMODULE/04-cicd.md"          "$DOCS/modules/04-cicd.md"          "Module 4 : CI/CD" 4
process_file "$SUBMODULE/05-aws.md"           "$DOCS/modules/05-aws.md"           "Module 5 : AWS" 5
process_file "$SUBMODULE/06-terraform.md"     "$DOCS/modules/06-terraform.md"     "Module 6 : Terraform" 6
process_file "$SUBMODULE/07-ansible.md"       "$DOCS/modules/07-ansible.md"       "Module 7 : Ansible" 7
process_file "$SUBMODULE/08-monitoring.md"    "$DOCS/modules/08-monitoring.md"    "Module 8 : Monitoring" 8
process_file "$SUBMODULE/09-kubernetes.md"    "$DOCS/modules/09-kubernetes.md"    "Module 9 : Kubernetes" 9

# === ENTRETIEN ===
process_file "$SUBMODULE/interview-questions.md"     "$DOCS/entretien/interview-questions.md"  "Questions d'entretien" 0
process_file "$SUBMODULE/interview-experience.md"    "$DOCS/entretien/interview-experience.md" "Questions d'expérience" 1
process_file "$SUBMODULE/system-design-exercises.md" "$DOCS/entretien/system-design.md"        "System Design" 2

# === REFERENCES ===
process_file "$SUBMODULE/cheatsheet.md"      "$DOCS/references/cheatsheet.md"      "Cheatsheet" 0
process_file "$SUBMODULE/troubleshooting.md" "$DOCS/references/troubleshooting.md" "Troubleshooting" 1
process_file "$SUBMODULE/aller-plus-loin.md" "$DOCS/references/aller-plus-loin.md" "Aller plus loin" 2

# === PROJET ===
process_file "$SUBMODULE/devops-project/README.md" "$DOCS/projet/index.md" "Projet fil rouge" 0

# === ENGLISH CONTENT (from content-en/) ===
if [ -d "$CONTENT_EN" ] && [ "$(ls -A "$CONTENT_EN"/*.md 2>/dev/null)" ]; then
  echo "Syncing English content..."

  EN_PREFIX="/en"

  # === EN MODULES ===
  [ -f "$CONTENT_EN/00-prerequisites.md" ] && process_file "$CONTENT_EN/00-prerequisites.md" "$DOCS/en/modules/00-prerequisites.md" "Module 0: Prerequisites" 0 "$EN_PREFIX"
  [ -f "$CONTENT_EN/01-linux-basics.md" ]  && process_file "$CONTENT_EN/01-linux-basics.md"  "$DOCS/en/modules/01-linux-basics.md"  "Module 1: Linux" 1 "$EN_PREFIX"
  [ -f "$CONTENT_EN/02-networking.md" ]    && process_file "$CONTENT_EN/02-networking.md"    "$DOCS/en/modules/02-networking.md"    "Module 2: Networking" 2 "$EN_PREFIX"
  [ -f "$CONTENT_EN/03-docker.md" ]        && process_file "$CONTENT_EN/03-docker.md"        "$DOCS/en/modules/03-docker.md"        "Module 3: Docker" 3 "$EN_PREFIX"
  [ -f "$CONTENT_EN/04-cicd.md" ]          && process_file "$CONTENT_EN/04-cicd.md"          "$DOCS/en/modules/04-cicd.md"          "Module 4: CI/CD" 4 "$EN_PREFIX"
  [ -f "$CONTENT_EN/05-aws.md" ]           && process_file "$CONTENT_EN/05-aws.md"           "$DOCS/en/modules/05-aws.md"           "Module 5: AWS" 5 "$EN_PREFIX"
  [ -f "$CONTENT_EN/06-terraform.md" ]     && process_file "$CONTENT_EN/06-terraform.md"     "$DOCS/en/modules/06-terraform.md"     "Module 6: Terraform" 6 "$EN_PREFIX"
  [ -f "$CONTENT_EN/07-ansible.md" ]       && process_file "$CONTENT_EN/07-ansible.md"       "$DOCS/en/modules/07-ansible.md"       "Module 7: Ansible" 7 "$EN_PREFIX"
  [ -f "$CONTENT_EN/08-monitoring.md" ]    && process_file "$CONTENT_EN/08-monitoring.md"     "$DOCS/en/modules/08-monitoring.md"    "Module 8: Monitoring" 8 "$EN_PREFIX"
  [ -f "$CONTENT_EN/09-kubernetes.md" ]    && process_file "$CONTENT_EN/09-kubernetes.md"    "$DOCS/en/modules/09-kubernetes.md"    "Module 9: Kubernetes" 9 "$EN_PREFIX"

  # === EN INTERVIEW ===
  [ -f "$CONTENT_EN/interview-questions.md" ]     && process_file "$CONTENT_EN/interview-questions.md"     "$DOCS/en/entretien/interview-questions.md"  "Interview Questions" 0 "$EN_PREFIX"
  [ -f "$CONTENT_EN/interview-experience.md" ]    && process_file "$CONTENT_EN/interview-experience.md"    "$DOCS/en/entretien/interview-experience.md" "Experience Questions" 1 "$EN_PREFIX"
  [ -f "$CONTENT_EN/system-design-exercises.md" ] && process_file "$CONTENT_EN/system-design-exercises.md" "$DOCS/en/entretien/system-design.md"        "System Design" 2 "$EN_PREFIX"

  # === EN REFERENCES ===
  [ -f "$CONTENT_EN/cheatsheet.md" ]      && process_file "$CONTENT_EN/cheatsheet.md"      "$DOCS/en/references/cheatsheet.md"      "Cheatsheet" 0 "$EN_PREFIX"
  [ -f "$CONTENT_EN/troubleshooting.md" ] && process_file "$CONTENT_EN/troubleshooting.md" "$DOCS/en/references/troubleshooting.md" "Troubleshooting" 1 "$EN_PREFIX"
  [ -f "$CONTENT_EN/aller-plus-loin.md" ] && process_file "$CONTENT_EN/aller-plus-loin.md" "$DOCS/en/references/aller-plus-loin.md" "Going Further" 2 "$EN_PREFIX"

  # === EN PROJECT ===
  [ -f "$CONTENT_EN/devops-project/README.md" ] && process_file "$CONTENT_EN/devops-project/README.md" "$DOCS/en/projet/index.md" "Hands-on Project" 0 "$EN_PREFIX"

  echo "  - $(find "$DOCS/en" -name '*.md' ! -name 'index.mdx' | wc -l | tr -d ' ') English pages"
else
  echo "No English content found in $CONTENT_EN/ — skipping EN sync."
fi

echo ""
echo "Content synced successfully."
echo "  - $(find "$DOCS/modules" -name '*.md' | wc -l | tr -d ' ') modules (FR)"
echo "  - $(find "$DOCS/entretien" -name '*.md' | wc -l | tr -d ' ') entretien pages (FR)"
echo "  - $(find "$DOCS/references" -name '*.md' | wc -l | tr -d ' ') reference pages (FR)"
echo "  - $(find "$DOCS/projet" -name '*.md' | wc -l | tr -d ' ') projet pages (FR)"
echo "  - $(find "$IMAGES" -type f | wc -l | tr -d ' ') assets"
