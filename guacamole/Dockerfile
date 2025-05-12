ARG GUACAMOLE_VERSION=1.5.5
FROM guacamole/guacamole:${GUACAMOLE_VERSION}

USER root

# Set default GUACAMOLE_HOME_TEMPLATE
ENV GUACAMOLE_HOME_TEMPLATE=/template

# Copy the custom start.sh
COPY start.sh /opt/guacamole/bin/start.sh

# Copy the template directory
COPY template /template

# Copy custom index.jsp into the ROOT webapp
COPY index.jsp /home/guacamole/tomcat/webapps/ROOT/index.jsp

# Ensure permissions are correct
RUN chmod +x /opt/guacamole/bin/start.sh && \
    chown -R guacamole:guacamole /home/guacamole /template

USER guacamole