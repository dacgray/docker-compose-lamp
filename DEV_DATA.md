### Options for Dumping and Scrambling Data for Dev Environments

To generate a development MySQL image with sensitive fields scrambled, you can use one of the two following demonstrated scripts.

#### Option 1: SQL-Based Scrambling (Temporary DB)
1. Ensure your database container is running.
2. Run the script `generate-dev-dump.sh` from your host machine.
   ```bash
   ./generate-dev-dump.sh
   ```
3. This script:
   - Creates a temporary database.
   - Imports your current data into it.
   - Uses SQL `UPDATE` commands to scramble sensitive fields.
   - Dumps the scrambled results to `dev-initdb-scrambled.sql`.
   - Cleans up the temporary database.

#### Option 2: PHP-Based Scrambling (Custom Logic)
1. Ensure your webserver container is running.
2. Run the script `generate-dev-dump.php` inside the web container.
   ```bash
   docker-compose exec webserver php /var/www/html/bin/generate-dev-dump.php
   ```
3. This script uses PHP for more complex data scrambling logic.
4. The scrambled dump is saved to `dev-initdb-scrambled-php.sql`.

---

### Generating a Custom Dev Docker Image
Once you have generated a scrambled SQL file (e.g., `dev-initdb-scrambled.sql`), you can build a custom database image for developers.

1. **Dockerfile**: Use `Mysql.Dev.Dockerfile`. It is already pre-configured to use the scrambled dump.
2. **Build Script**: Run the helper script `build-dev-db.sh`.
   ```bash
   ./build-dev-db.sh
   ```
3. This will create a Docker image named `hospital-mysql-dev:latest` containing your scrambled data.
4. **Pushing the image**: The `build-dev-db.sh` script also contains example commands (commented out) to tag and push the image to a private registry.

### Accessing the Dev Database via phpMyAdmin
A dedicated phpMyAdmin service for the development database is available:
- **Service Name**: `dev-phpmyadmin`
- **URL**: `http://localhost:8081` (default)
- **Database Host**: `dev-database`
- **Credentials**: Same as production (root/tiger by default)
