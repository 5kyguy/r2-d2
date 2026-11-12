#!/bin/bash

r2-d2-refresh-applications
update-desktop-database ~/.local/share/applications

# Open directories in the file manager
xdg-mime default robin.desktop inode/directory

# Open images with Robin
xdg-mime default robin.desktop image/png
xdg-mime default robin.desktop image/jpeg
xdg-mime default robin.desktop image/gif
xdg-mime default robin.desktop image/webp
xdg-mime default robin.desktop image/bmp
xdg-mime default robin.desktop image/tiff

# Open editable images with Pinta
xdg-mime default com.github.PintaProject.Pinta.desktop image/x-xcf

# Open PDFs with Zathura
xdg-mime default org.pwmt.zathura-pdf-mupdf.desktop application/pdf

# Use Brave Origin as the default browser
xdg-settings set default-web-browser brave-origin-nightly.desktop
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/http
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/https

# Open video and audio files with Robin
xdg-mime default robin.desktop video/mp4
xdg-mime default robin.desktop video/x-msvideo
xdg-mime default robin.desktop video/x-matroska
xdg-mime default robin.desktop video/x-flv
xdg-mime default robin.desktop video/x-ms-wmv
xdg-mime default robin.desktop video/mpeg
xdg-mime default robin.desktop video/ogg
xdg-mime default robin.desktop video/webm
xdg-mime default robin.desktop video/quicktime
xdg-mime default robin.desktop video/3gpp
xdg-mime default robin.desktop video/3gpp2
xdg-mime default robin.desktop video/x-ms-asf
xdg-mime default robin.desktop video/x-ogm+ogg
xdg-mime default robin.desktop video/x-theora+ogg
xdg-mime default robin.desktop audio/mpeg
xdg-mime default robin.desktop audio/flac
xdg-mime default robin.desktop audio/ogg
xdg-mime default robin.desktop audio/wav
xdg-mime default robin.desktop audio/x-wav
xdg-mime default robin.desktop audio/mp4
xdg-mime default robin.desktop audio/aac
xdg-mime default robin.desktop audio/x-m4a

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
