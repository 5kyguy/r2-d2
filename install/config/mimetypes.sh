#!/bin/bash

r2-d2-refresh-applications
update-desktop-database ~/.local/share/applications

# Open directories in the file manager
xdg-mime default thunar.desktop inode/directory

# Open images with Omaroll
xdg-mime default io.github.tsouth89.omaroll.desktop image/png
xdg-mime default io.github.tsouth89.omaroll.desktop image/jpeg
xdg-mime default io.github.tsouth89.omaroll.desktop image/gif
xdg-mime default io.github.tsouth89.omaroll.desktop image/webp
xdg-mime default io.github.tsouth89.omaroll.desktop image/bmp
xdg-mime default io.github.tsouth89.omaroll.desktop image/tiff

# Open editable images with Pinta
xdg-mime default com.github.PintaProject.Pinta.desktop image/x-xcf

# Open PDFs with Zathura
xdg-mime default org.pwmt.zathura-pdf-mupdf.desktop application/pdf

# Use Brave Origin as the default browser
xdg-settings set default-web-browser brave-origin-nightly.desktop
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/http
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/https

# Open video files with Omaroll
xdg-mime default io.github.tsouth89.omaroll.desktop video/mp4
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-msvideo
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-matroska
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-flv
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-ms-wmv
xdg-mime default io.github.tsouth89.omaroll.desktop video/mpeg
xdg-mime default io.github.tsouth89.omaroll.desktop video/ogg
xdg-mime default io.github.tsouth89.omaroll.desktop video/webm
xdg-mime default io.github.tsouth89.omaroll.desktop video/quicktime
xdg-mime default io.github.tsouth89.omaroll.desktop video/3gpp
xdg-mime default io.github.tsouth89.omaroll.desktop video/3gpp2
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-ms-asf
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-ogm+ogg
xdg-mime default io.github.tsouth89.omaroll.desktop video/x-theora+ogg

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
