# Syrx PostgreSQL Test Database Docker Image
# This image provides a pre-configured PostgreSQL instance with all test objects for Syrx.Npgsql.Tests.Integration

FROM postgres:16-alpine

# Set environment variables for PostgreSQL
ENV POSTGRES_DB=syrx
ENV POSTGRES_USER=syrx_user
ENV POSTGRES_PASSWORD=YourStrong!Passw0rd

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy initialization scripts
COPY init-scripts/*.sql /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432

# The base postgres image already handles initialization scripts in /docker-entrypoint-initdb.d
# so we don't need a custom entrypoint