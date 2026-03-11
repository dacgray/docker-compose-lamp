FROM mysql:8.0

# Copy the scrambled dump to the entrypoint directory
# This ensures the database is initialized with scrambled data on first run
COPY dev-initdb-scrambled.sql /docker-entrypoint-initdb.d/

# Set default environment variables for the dev image
ENV MYSQL_ROOT_PASSWORD=tiger
ENV MYSQL_DATABASE=hospital
