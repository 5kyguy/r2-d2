#!/bin/bash

# Install tesseract OCR + English language data for the new capture-text-extraction
# bin. Lets K-2SO read on-screen text via the r2d2_ocr MCP tool. Port of omarchy 75eec087.

echo "Installing tesseract OCR and language data"

r2-d2-pkg-add tesseract tesseract-data-eng
