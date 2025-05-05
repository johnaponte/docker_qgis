# QGIS 3.40.6 + Apache Guacamole en Docker

Este proyecto permite ejecutar **QGIS 3.40.6 (LTR)** en un contenedor Docker con escritorio remoto accesible desde el navegador usando **Apache Guacamole**.

## 📁 Estructura del proyecto

```
qgis-guacamole/
│
├── docker-compose.yml       # Orquestación de servicios Docker
├── qgis/                    # Imagen personalizada con QGIS
│   └── Dockerfile           # Basada en Ubuntu + QGIS 3.40.6
└── README.md                # Este archivo
```

## 🚀 Cómo iniciar

### 1. Requisitos

- Docker
- Docker Compose v2+

### 2. Clonar y levantar

```bash
docker compose up --build -d
```

## 🌐 Acceso a Guacamole

1. Visita: [http://localhost:8080/guacamole](http://localhost:8080/guacamole)
2. Usuario: `guacadmin` | Contraseña: `guacadmin`
3. Crea una conexión tipo **VNC** apuntando a:
   - Hostname: `qgis`
   - Puerto: `5901`

## 📦 Persistencia

- Datos de usuario y conexiones de Guacamole: `./data/mysql`
- Proyectos QGIS: `./data/qgis-projects`
- Configuración y plugins de QGIS: `./data/qgis-config`

## 🛑 Detener

```bash
docker compose down
```

## 🔗 Fuentes

- https://qgis.org/resources/installation-guide/
- https://guacamole.apache.org
