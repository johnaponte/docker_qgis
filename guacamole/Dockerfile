
FROM guacamole/guacamole:1.5.5

WORKDIR /home/guacamole

# Redirección desde / hacia /guacamole
RUN mkdir -p /home/guacamole/tomcat/webapps/ROOT
COPY index.jsp /home/guacamole/tomcat/webapps/ROOT/index.jsp
COPY --chown=guacamole:guacamole branding.jar /home/guacamole/.guacamole/extensions/
