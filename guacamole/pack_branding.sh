#!/bin/bash

# Set paths
BRANDING_DIR="../branding"
OUTPUT_JAR="./template/extensions/qgis-branding.jar"

mkdir -p ./template/extensions/

# Create the JAR (ZIP) from inside the branding directory, without including the top-level folder
(cd "$BRANDING_DIR" && zip -r "../temp_branding.jar" . -x "**/.DS_Store" -x "**/__MACOSX/*" > /dev/null)

# Move the JAR to the final destination
mv "$BRANDING_DIR/../temp_branding.jar" "$OUTPUT_JAR"
