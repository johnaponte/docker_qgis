# QGIS Remote Desktop Project (Containerized)

## 🧭 Objective

This project sets up a containerized remote desktop environment for QGIS, accessible via a web browser using [Apache Guacamole](https://guacamole.apache.org/). The system is composed of:

- A customized QGIS desktop image
- A Guacamole frontend
- `guacd` and `mysql` containers for backend support

It allows you to create and manage QGIS projects in isolated environments with persistent data and user configurations.

---

## 🧱 Components

The main directories represent custom Docker images:

- `qgis/`: Customized QGIS image
- `mysql/`: MySQL database image configured for Guacamole
- `guacamole/`: Custom-branded Guacamole frontend

Each of these directories contains a `./build_image.sh` script to build the image.  
Custom branding can be added via the `branding/` directory. Use `pack_branding.sh` to generate a `.jar` file used by the Guacamole image — it is automatically called inside `guacamole/build_image.sh`.

---

## 🚀 Getting Started

To create a new QGIS project setup:

```bash
./create_qgis_project.sh
```

This script will create in the current directory:

- `.env`: Environment variables (users/passwords)
- `docker-compose.yml`: Service definitions
- `projects/`: Directory to store QGIS projects
- `qgis-config/`: Directory for QGIS user configuration
- `.gitignore`: Basic Git exclusions
-  `README.md`: Basic instructions
> ⚠️ `.env` contains plaintext credentials. Do **not** commit it to Git.

---

## 📁 Persistence & Data

The following directories are used for persistent data:

- `projects/`: Stores QGIS project files
- `qgis-config/`: Stores user-specific QGIS configuration

In addition the follwoing named Docker volumens are used:
- `thinclient_data/`: Enables file transfer between the container and the web browser
- `mysql_data/`: Persists the MySQL database used by Guacamole

---

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
