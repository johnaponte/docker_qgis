# MySQL Backend for Guacamole

This MySQL container serves as the backend for Guacamole, which provides the frontend interface to access a containerized application, such as QGIS. The necesary tables for autentification and setup a connection are created with the container

## Image Info

- **Image name:** `rd-mysql-8_4:1.0.0`
- **Build tool:** `build_image.sh` script
- **Base:** MySQL 8.4
- **Tags:** `1.0.0`, `latest`

## Docker Compose Example

```yaml
mysql:
  image: rd-mysql-8_4:1.0.0
  container_name: mysql
  restart: unless-stopped
  environment:
    - HOST_NAME=qgis
    - HOST_PORT=3389
    - CONNECTION_NAME=${CONNECTION_NAME}
    - MYSQL_DATABASE=guacamole_db
    - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    - MYSQL_USER=${MYSQL_USER}
    - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    - GUACADMIN_USER=${GUACADMIN_USER}
    - GUACADMIN_PASS=${GUACADMIN_PASS}
    - GUAC_USER=${USER_NAME}
    - GUAC_PASS=${USER_PASSWORD}
  volumes:
    - ./data/mysql:/var/lib/mysql
```

## Environment Variables

| Variable              | Description                             |
|-----------------------|-----------------------------------------|
| `MYSQL_ROOT_PASSWORD` | Root password for the MySQL instance    |
| `MYSQL_USER`          | Username for Guacamole DB               |
| `MYSQL_PASSWORD`      | Password for `MYSQL_USER`               |
| `MYSQL_DATABASE`      | Database name (default: `guacamole_db`)|
| `GUACADMIN_USER`      | Guacamole admin username                |
| `GUACADMIN_PASS`      | Guacamole admin password                |
| `GUAC_USER`           | Default user for remote connection      |
| `GUAC_PASS`           | Password for `GUAC_USER`                |

Environment variables could be defined in an `.env`file

## Build Instructions

Use the provided script to build the image:

```bash
./build_image.sh [--docker-user <optional_dockerhub_user>]
```

The image will be tagged with `1.0.0` and `latest`, and includes proper OCI labels.

## License

MIT

