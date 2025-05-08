USE guacamole_db;

INSERT INTO guacamole_connection (connection_name, protocol)
VALUES ('QGIS Remote', 'rdp');

SET @connection_id := LAST_INSERT_ID();

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
VALUES
  (@connection_id, 'hostname', 'qgis'),
  (@connection_id, 'port', '3389'),
  (@connection_id, 'username', 'qgis'),
  (@connection_id, 'password', 'qgis'),
  (@connection_id, 'enable-drive', 'true'),
  (@connection_id, 'drive-name', 'transfer'),
  (@connection_id, 'drive-path', '/tmp/transfer'),
  (@connection_id, 'create-drive-path', 'true');
