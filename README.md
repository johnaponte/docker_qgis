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

Custom branding can be added via the `branding/` directory. Use `pack_branding.sh` to generate a `.jar` file used by the Guacamole image — it is automatically called by the release script.

---

## 🐳 Releasing Images to Docker Hub

All three images are built and published from a single script at the root of the repository:

```bash
./release_to_dockerhub.sh
```

The script automatically reads the latest tag published on Docker Hub for each image and bumps the **minor** version (e.g. `1.0.0` → `1.1.0`). This convention is used for security-only updates. If an image has never been published, it starts at `1.0.0`.

Both a versioned tag and `latest` are pushed for each image.

> You must be logged in to Docker Hub before running the script (`docker login`).

### Options

| Flag | Description |
|------|-------------|
| `--guacamole` | Release only the Guacamole image |
| `--mysql` | Release only the MySQL image |
| `--qgis` | Release only the QGIS image |
| `--no-push` | Build locally (single-platform, loaded into local daemon) without pushing |
| `--dry-run` | Show the release plan without building or pushing anything |
| `--yes` / `-y` | Skip the confirmation prompt |

### Examples

```bash
# Release all three images
./release_to_dockerhub.sh

# Release only the QGIS image
./release_to_dockerhub.sh --qgis

# Build all images locally for testing (no push)
./release_to_dockerhub.sh --no-push

# Preview what would be released without doing anything
./release_to_dockerhub.sh --dry-run
```

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
