ARG MYSQL_VERSION=8.4

FROM mysql:${MYSQL_VERSION}

# Install envsubst (gettext)
RUN microdnf install -y gettext \
    && microdnf clean all

# Copy the SQL template into the init directory
COPY mysql-init/ /mysql-init/

# Ensure it's executable
RUN chmod +x /mysql-init/init.sh

# Entrypoint definition
ENTRYPOINT ["/mysql-init/init.sh"]
CMD ["mysqld"]

