#!/bin/sh
# deploy.sh

set -e

deploy_to_repo() {
    REPO_URL=$1
    BASE_HREF=$2
    REPO_NAME=$3

    echo "--------------------------------------------------"
    echo "Building and Deploying to $REPO_NAME..."
    echo "Base Href: $BASE_HREF"
    echo "--------------------------------------------------"

    # Build the app
    flutter build web --release --base-href "$BASE_HREF" --no-tree-shake-icons --no-wasm-dry-run

    # Navigate to build directory
    cd build/web

    # Initialize git and push
    git init
    git add -A
    git commit -m "Deploy to GitHub Pages ($REPO_NAME): $(date)"
    git push -f "$REPO_URL" main:gh-pages

    # Clean up
    cd -
    rm -rf build/web/.git
}

# 1. Deploy to Genet-Church/gdev-frontend
deploy_to_repo "https://github.com/Genet-Church/gdev-frontend.git" "/gdev-frontend/" "Genet-Church"

# 2. Deploy to HundefraN/genet-church-live-demo
deploy_to_repo "https://github.com/HundefraN/genet-church-live-demo.git" "/genet-church-live-demo/" "HundefraN"

echo "Double deployment complete!"