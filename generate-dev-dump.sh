#!/bin/bash

# Configuration
DB_CONTAINER=$(docker-compose ps -q database)
DB_NAME="hospital"
TEMP_DB_NAME="hospital_temp_scramble"
OUTPUT_FILE="dev-initdb-scrambled.sql"

# Function to pause between steps
pause_for_user() {
    echo ""
    read -p "### Previous step finished. Press [Enter] to continue to the next step..."
    echo ""
}

if [ -z "$DB_CONTAINER" ]; then
    echo "Error: Database container not found. Please run 'docker-compose up -d' first."
    exit 1
fi

echo "### Starting SQL-based scrambling using a temporary database..."

# 1. Create a temporary database for scrambling
pause_for_user
echo "### Creating temporary database: $TEMP_DB_NAME..."
docker-compose exec -T database mysql -u root -ptiger -e "CREATE DATABASE IF NOT EXISTS $TEMP_DB_NAME;"

# 2. Copy the schema and data from the original database to the temporary one
echo "### Finished creating temporary database."
pause_for_user
echo "### Copying data from $DB_NAME to $TEMP_DB_NAME..."
docker-compose exec -T database mysqldump -u root -ptiger $DB_NAME | \
docker-compose exec -T database mysql -u root -ptiger $TEMP_DB_NAME

# 3. Scramble the sensitive fields in the temporary database
echo "### Finished copying data."
pause_for_user
echo "### Scrambling data in $TEMP_DB_NAME..."
SCRAMBLE_SQL="
UPDATE patients SET
    name = CONCAT('Dev User ', id),
    email = CONCAT('user', id, '@dev.example.com');
"
docker-compose exec -T database mysql -u root -ptiger $TEMP_DB_NAME -e "$SCRAMBLE_SQL"

# 4. Dump the scrambled data from the temporary database
echo "### Finished scrambling data."
pause_for_user
echo "### Dumping scrambled data to $OUTPUT_FILE..."
# We use --databases to ensure the CREATE DATABASE and USE statements are included in the dump
# But we need to rename it back to the original database name in the dump file
docker-compose exec -T database mysqldump -u root -ptiger --databases $TEMP_DB_NAME | \
sed "s/$TEMP_DB_NAME/$DB_NAME/g" > $OUTPUT_FILE

# 5. Drop the temporary database
echo "### Finished dumping scrambled data."
pause_for_user
echo "### Dropping temporary database..."
docker-compose exec -T database mysql -u root -ptiger -e "DROP DATABASE IF EXISTS $TEMP_DB_NAME;"

echo "### Scrambled dump created: $OUTPUT_FILE"
echo "### To use this in a dev image, you can create a Dockerfile like this:"
echo ""
echo "FROM mysql:8"
echo "COPY $OUTPUT_FILE /docker-entrypoint-initdb.d/"
echo ""
