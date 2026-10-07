#!/bin/bash

echo "Replace Evince with Zathura for PDFs"

r2-d2-pkg-add zathura zathura-pdf-mupdf
r2-d2-pkg-remove evince

if [[ -f /usr/share/applications/org.pwmt.zathura-pdf-mupdf.desktop ]]; then
  current=$(xdg-mime query default application/pdf 2>/dev/null || true)
  if [[ -z $current || $current == "org.gnome.Evince.desktop" ]]; then
    xdg-mime default org.pwmt.zathura-pdf-mupdf.desktop application/pdf
  fi
fi
