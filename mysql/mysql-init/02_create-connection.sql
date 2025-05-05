USE guacamole_db;

-- Crear la conexión "QGIS Remote"
INSERT INTO guacamole_connection (connection_name, protocol)
VALUES ('QGIS Remote', 'vnc');

-- Obtener el ID generado
SET @connection_id := LAST_INSERT_ID();

-- Insertar los parámetros de conexión
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
VALUES
  (@connection_id, 'hostname', 'qgis'),
  (@connection_id, 'port', '5901'),
  (@connection_id, 'password', 'vncpass'),
  (@connection_id, 'color-depth', '24'),
  (@connection_id, 'security', 'none');
