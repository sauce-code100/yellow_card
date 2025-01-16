#!/bin/bash


if [ -d "migrate-test" ]; then
    rm -rf migrate-test
fi
mkdir migrate-test
cd migrate-test

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 <target-repo-url> <migrating-service-name> "
    echo
    echo "Arguments:"
    echo "  <target-repo-url>     URL of your new pod repo (e.g., 'https://github.com/yellowcardfinancial/commercial-pod.git') "
    echo "  <migrating-service-name>   Name of the service to migrate (e.g., 'rates') "
    echo   
    echo 'example command: ./migrate-service.sh "https://github.com/yellowcardfinancial/commercial-pod.git" "freezer"'
    exit 1
}

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
    usage
fi

# Input arguments
SOURCE_FOLDER="services/$2"
TARGET_FOLDER="services/serverless/services"
TARGET_REPO_URL=$1
MIGRATING_SERVICE=$2

# Repository URLs
SOURCE_REPO_URL="https://github.com/yellowcardfinancial/yellowcard-transaction-api.git"
TEMP_REPO_URL="https://github.com/yellowcardfinancial/pod-migration.git"

# Branch names
EXTRACT_BRANCH="extract-$MIGRATING_SERVICE"  
MIGRATE_BRANCH="migrate-$MIGRATING_SERVICE"

echo "Starting migration of '$SOURCE_FOLDER' to '$TARGET_FOLDER' in repository: $TARGET_REPO_URL..."

# Step 1: Clone the source repository
echo "Cloning source repository: $SOURCE_REPO_URL"
git clone $SOURCE_REPO_URL source-repo
cd source-repo

# Step 2: Create a branch for folder extraction
echo "Creating branch '$EXTRACT_BRANCH' for folder extraction"
git checkout -b $EXTRACT_BRANCH

# Step 3: Extract the specified folder and move it to the root
echo "Extracting folder '$SOURCE_FOLDER'..."
git filter-repo --path $SOURCE_FOLDER --path-rename $SOURCE_FOLDER/:$MIGRATING_SERVICE/ --force

# Step 4: Push the filtered branch to the temporary repository
echo "Pushing extracted folder to the temporary repository: $TEMP_REPO_URL"
git remote add temp-repo $TEMP_REPO_URL
git push temp-repo $EXTRACT_BRANCH --force

# Step 5: Clean up source repository
echo "Cleaning up source repository"
cd ..
rm -rf source-repo

# Step 6: Clone the target repository
echo "Cloning target repository: $TARGET_REPO_URL"
git clone $TARGET_REPO_URL your-pod-repo
cd your-pod-repo

# Step 7: Create a new branch for the migration
echo "Creating branch '$MIGRATE_BRANCH' in the target repository"
git checkout -b $MIGRATE_BRANCH 

# Step 8: Add the temporary repository as a remote and fetch the extracted branch
echo "Adding temporary repository as remote and fetching branch '$EXTRACT_BRANCH'"
git remote add temp-repo $TEMP_REPO_URL
git fetch temp-repo $EXTRACT_BRANCH  ##########

# Step 9: Merge the folder into the target repository
echo "Merging folder into target path '$TARGET_FOLDER'"
git checkout -b $MIGRATING_SERVICE-extract temp-repo/$EXTRACT_BRANCH
git checkout $MIGRATE_BRANCH
git read-tree --prefix=$TARGET_FOLDER/ -u $MIGRATING_SERVICE-extract
git commit -m "Merged folder '$SOURCE_FOLDER' into '$TARGET_FOLDER' with history"

# Step 10: Push the migration branch to the target repository
echo "Pushing migration branch '$MIGRATE_BRANCH' to the target repository"
git push origin $MIGRATE_BRANCH

# Cleanup temporary repository reference
echo "Cleaning up temporary repository references"
git remote remove temp-repo

# Final message
echo "Migration completed!" 
echo "Your pod repo was cloned inside the migrate-test folder."
echo "The folder '$SOURCE_FOLDER' has been migrated to '$TARGET_FOLDER' in the '$MIGRATE_BRANCH' branch of the target repository: $TARGET_REPO_URL."


# Exit script
exit 0
