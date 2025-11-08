#!/bin/sh
# deploy.sh

set -e

echo "Building Flutter web app..."
flutter build web --release --base-href "/genet-church-live-demo/" --no-tree-shake-icons

echo "Navigating to build directory..."
cd build/web

git init
git add -A
git commit -m "Deploy to GitHub Pages: $(date)"

echo "Deploying to gh-pages branch..."
git push -f git@github.com:HundefraN/genet-church-live-demo.git main:gh-pages

cd -
rm -rf build/web/.git

echo "Deployment complete!"