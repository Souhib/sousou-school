#!/bin/bash
set -euo pipefail

SUBMODULE="content-source"
DOCS="src/content/docs"
IMAGES="public/images"

# Verify submodule exists
if [ ! -d "$SUBMODULE" ] || [ ! -f "$SUBMODULE/README.md" ]; then
  echo "ERROR: Submodule '$SUBMODULE' not found. Run: git submodule update --init --recursive"
  exit 1
fi

# Clean previous sync (preserve hand-written files: index.mdx, en/)
rm -rf "$DOCS/modules" "$DOCS/entretien" "$DOCS/references" "$DOCS/projet"
rm -rf "$IMAGES"

# Create dirs
mkdir -p "$DOCS/modules" "$DOCS/entretien" "$DOCS/references" "$DOCS/projet" "$IMAGES"

# Copy assets
cp "$SUBMODULE"/assets/*.png "$IMAGES/" 2>/dev/null || true
cp "$SUBMODULE"/assets/*.pdf "$IMAGES/" 2>/dev/null || true

# === Link rewriting function ===
rewrite_links() {
  sed \
    -e 's|](00-prerequisites.md)|](/modules/00-prerequisites/)|g' \
    -e 's|](01-linux-basics.md)|](/modules/01-linux-basics/)|g' \
    -e 's|](02-networking.md)|](/modules/02-networking/)|g' \
    -e 's|](03-docker.md)|](/modules/03-docker/)|g' \
    -e 's|](04-cicd.md)|](/modules/04-cicd/)|g' \
    -e 's|](05-aws.md)|](/modules/05-aws/)|g' \
    -e 's|](06-terraform.md)|](/modules/06-terraform/)|g' \
    -e 's|](07-ansible.md)|](/modules/07-ansible/)|g' \
    -e 's|](08-monitoring.md)|](/modules/08-monitoring/)|g' \
    -e 's|](09-kubernetes.md)|](/modules/09-kubernetes/)|g' \
    -e 's|](system-design-exercises.md)|](/entretien/system-design/)|g' \
    -e 's|](interview-questions.md)|](/entretien/interview-questions/)|g' \
    -e 's|](interview-experience.md)|](/entretien/interview-experience/)|g' \
    -e 's|](cheatsheet.md)|](/references/cheatsheet/)|g' \
    -e 's|](troubleshooting.md)|](/references/troubleshooting/)|g' \
    -e 's|](aller-plus-loin.md)|](/references/aller-plus-loin/)|g' \
    -e 's|](assets/|](/images/|g' \
    -e 's|(assets/|(/images/|g'
}

# === Process a file: inject frontmatter, strip H1, rewrite links ===
process_file() {
  local src="$1"
  local dest="$2"
  local title="$3"
  local order="$4"

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
  } | rewrite_links > "$dest"
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

echo "Content synced successfully."
echo "  - $(find "$DOCS/modules" -name '*.md' | wc -l | tr -d ' ') modules"
echo "  - $(find "$DOCS/entretien" -name '*.md' | wc -l | tr -d ' ') entretien pages"
echo "  - $(find "$DOCS/references" -name '*.md' | wc -l | tr -d ' ') reference pages"
echo "  - $(find "$DOCS/projet" -name '*.md' | wc -l | tr -d ' ') projet pages"
echo "  - $(find "$IMAGES" -type f | wc -l | tr -d ' ') assets"
