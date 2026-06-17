#!/bin/bash

r2-d2-refresh-applications
update-desktop-database ~/.local/share/applications

# Open directories in file manager
xdg-mime default org.gnome.Nautilus.desktop inode/directory

# Open images with Eye of GNOME
xdg-mime default org.gnome.eog.desktop image/png
xdg-mime default org.gnome.eog.desktop image/jpeg
xdg-mime default org.gnome.eog.desktop image/gif
xdg-mime default org.gnome.eog.desktop image/webp
xdg-mime default org.gnome.eog.desktop image/bmp
xdg-mime default org.gnome.eog.desktop image/tiff

# Open editable images with Pinta
xdg-mime default com.github.PintaProject.Pinta.desktop image/x-xcf

# Open PDFs with the Document Viewer
xdg-mime default org.gnome.Evince.desktop application/pdf

# Use Brave Origin as the default browser
xdg-settings set default-web-browser brave-origin-nightly.desktop
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/http
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/https

# Open video files with Totem (GNOME Videos)
xdg-mime default org.gnome.Totem.desktop video/mp4
xdg-mime default org.gnome.Totem.desktop video/x-msvideo
xdg-mime default org.gnome.Totem.desktop video/x-matroska
xdg-mime default org.gnome.Totem.desktop video/x-flv
xdg-mime default org.gnome.Totem.desktop video/x-ms-wmv
xdg-mime default org.gnome.Totem.desktop video/mpeg
xdg-mime default org.gnome.Totem.desktop video/ogg
xdg-mime default org.gnome.Totem.desktop video/webm
xdg-mime default org.gnome.Totem.desktop video/quicktime
xdg-mime default org.gnome.Totem.desktop video/3gpp
xdg-mime default org.gnome.Totem.desktop video/3gpp2
xdg-mime default org.gnome.Totem.desktop video/x-ms-asf
xdg-mime default org.gnome.Totem.desktop video/x-ogm+ogg
xdg-mime default org.gnome.Totem.desktop video/x-theora+ogg
xdg-mime default org.gnome.Totem.desktop application/ogg

# Open text files with nano
xdg-mime default Nano.desktop text/plain
xdg-mime default Nano.desktop text/english
xdg-mime default Nano.desktop text/x-makefile
xdg-mime default Nano.desktop text/x-c++hdr
xdg-mime default Nano.desktop text/x-c++src
xdg-mime default Nano.desktop text/x-chdr
xdg-mime default Nano.desktop text/x-csrc
xdg-mime default Nano.desktop text/x-java
xdg-mime default Nano.desktop text/x-moc
xdg-mime default Nano.desktop text/x-pascal
xdg-mime default Nano.desktop text/x-tcl
xdg-mime default Nano.desktop text/x-tex
xdg-mime default Nano.desktop application/x-shellscript
xdg-mime default Nano.desktop text/x-c
xdg-mime default Nano.desktop text/x-c++
xdg-mime default Nano.desktop application/xml
xdg-mime default Nano.desktop text/xml
