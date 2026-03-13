#!/bin/bash
set -e

# Provide help if requested
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: ./branch.sh [new_directory] [App Title] [app_snake_case] [github_username/repo_name]"
    echo "Example: ./branch.sh my_app \"My Awesome App\" my_awesome_app Omustardo/my_awesome_app"
    return 0 2>/dev/null
fi

# Interactive prompts if arguments are not provided
NEW_DIR=$1
if [ -z "$NEW_DIR" ]; then
    read -p "Enter the new directory name to clone into: " NEW_DIR
fi

APP_TITLE=$2
if [ -z "$APP_TITLE" ]; then
    read -p "Enter the app title (e.g. 'My Awesome App'): " APP_TITLE
fi

APP_SNAKE=$3
if [ -z "$APP_SNAKE" ]; then
    read -p "Enter the app name in snake_case (e.g. 'my_awesome_app'): " APP_SNAKE
fi

GITHUB_REPO=$4
if [ -z "$GITHUB_REPO" ]; then
    read -p "Enter your GitHub username/repo_name (e.g. 'Omustardo/my_awesome_app'): " GITHUB_REPO
fi

# 1. Branch the project from github.com
echo "Cloning the template from github.com into $NEW_DIR..."
git clone https://github.com/Omustardo/app_template "$NEW_DIR"
cd "$NEW_DIR"

# 2. Modify all of the names/etc
echo "Modifying names and references..."

REPO_NAME=$(echo "$GITHUB_REPO" | cut -d'/' -f2)
GITHUB_USER=$(echo "$GITHUB_REPO" | cut -d'/' -f1)
APP_KEBAB=$(echo "$APP_SNAKE" | tr '_' '-')

if [[ "$OSTYPE" == "darwin"* ]]; then
    SEDI=("sed" "-i" "")
else
    SEDI=("sed" "-i")
fi

mv src/crates/app src/crates/$APP_SNAKE

find . -type f -not -path "*/\.git/*" -not -path "*/target/*" -not -path "*/dist/*" -not -path "*/pkg/*" -not -name "branch.sh" -print0 | while IFS= read -r -d '' file; do
    if grep -Iq . "$file"; then # Only process text files
        "${SEDI[@]}" "s|My App|$APP_TITLE|g" "$file"
        "${SEDI[@]}" "s|my_app|$APP_SNAKE|g" "$file"
        "${SEDI[@]}" "s|my-app|$APP_KEBAB|g" "$file"
        "${SEDI[@]}" "s|app_template|$REPO_NAME|g" "$file"
        "${SEDI[@]}" "s|Omustardo|$GITHUB_USER|g" "$file"

        # In main.rs, replace `app::` with `${APP_SNAKE}::`
        if [[ "$file" == *"main.rs" ]]; then
            "${SEDI[@]}" "s/[[:<:]]app::/${APP_SNAKE}::/g" "$file" 2>/dev/null || true
            "${SEDI[@]}" "s/\bapp::/${APP_SNAKE}::/g" "$file" 2>/dev/null || true
        fi

        # Remove lines that are just TEMPLATE_TODO comments
        "${SEDI[@]}" "/^[[:space:]]*\/\/ TEMPLATE_TODO/d" "$file"
        "${SEDI[@]}" "/^[[:space:]]*# TEMPLATE_TODO/d" "$file"
        # Remove inline TEMPLATE_TODO comments
        "${SEDI[@]}" "s| \/\/ TEMPLATE_TODO.*||g" "$file"
        "${SEDI[@]}" "s| # TEMPLATE_TODO.*||g" "$file"
    fi
done

# 3. Modify `name = "app"` in Cargo.toml and `APP_PACKAGE` in Makefile
"${SEDI[@]}" "s|name = \"app\"|name = \"$APP_SNAKE\"|g" src/crates/$APP_SNAKE/Cargo.toml
"${SEDI[@]}" "s|APP_PACKAGE := app|APP_PACKAGE := $APP_SNAKE|g" Makefile
"${SEDI[@]}" "s|crates/app|crates/$APP_SNAKE|g" Makefile
"${SEDI[@]}" "s|crates/app|crates/$APP_SNAKE|g" README.md

# Modify manifest.json TEMPLATE_TODO manually since it's JSON
if [ -f "src/crates/$APP_SNAKE/assets/manifest.json" ]; then
    "${SEDI[@]}" "/TEMPLATE_TODO/d" src/crates/$APP_SNAKE/assets/manifest.json
fi

# 4. Delete most of the README
echo "Cleaning up README.md..."
"${SEDI[@]}" '/## Branching this template/,$d' README.md

# 5. Re-init git
echo "Re-initializing git repository..."
rm -rf .git
git init
git add .
git commit -m "Initial commit from $APP_TITLE branched from app_template" || true

echo "--------------------------------------------------------"
echo "Project successfully branched into $NEW_DIR!"
echo ""
echo "Deleting branch.sh from $NEW_DIR as it is no longer needed..."
rm -f branch.sh
echo ""
echo "You can now cd into $NEW_DIR and start building."
echo "--------------------------------------------------------"
