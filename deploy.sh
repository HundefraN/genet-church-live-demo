#!/bin/sh
# deploy.sh

# 1. Exit immediately if a command exits with a non-zero status.
set -e

# 2. Build the Flutter web app.
# Using the old --release flag as --web-renderer is not working for you.
# This ensures a successful build.
echo "Building Flutter web app..."
flutter build web --release --base-href "/genet-church-live-demo/" --no-tree-shake-icons

# 3. Navigate into the build output directory.
cd build/web

# 4. Initialize a new Git repository, add changes, and commit.
# The commit message includes the current date.
git init
git add -A
git commit -m "Deploy to GitHub Pages: $(date)"

# 5. Push the build to the `gh-pages` branch on your GitHub repository.
# Replace the URL with your own repository's URL.
echo "Deploying to GitHub Pages..."
git push -f git@github.com:HundefraN/genet-church-live-demo.git main:gh-pages

# 6. Clean up by returning to the root directory and removing the build folder's .git directory.
cd -
rm -rf build/web/.git

echo "Deployment complete!"