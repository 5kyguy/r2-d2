#!/bin/bash

omarchy-refresh-applications
update-desktop-database ~/.local/share/applications

# Open directories in file manager
xdg-mime default org.gnome.Nautilus.desktop inode/directory

# Open all images with eog (Eye of GNOME)
xdg-mime default org.gnome.eog.desktop image/png
xdg-mime default org.gnome.eog.desktop image/jpeg
xdg-mime default org.gnome.eog.desktop image/gif
xdg-mime default org.gnome.eog.desktop image/webp
xdg-mime default org.gnome.eog.desktop image/bmp
xdg-mime default org.gnome.eog.desktop image/tiff

# Open PDFs with the Document Viewer
xdg-mime default org.gnome.Evince.desktop application/pdf

# Use Brave as the default browser
xdg-settings set default-web-browser brave-browser.desktop
xdg-mime default brave-browser.desktop x-scheme-handler/http
xdg-mime default brave-browser.desktop x-scheme-handler/https

# Open video files with VLC
xdg-mime default vlc.desktop video/mp4
xdg-mime default vlc.desktop video/x-msvideo
xdg-mime default vlc.desktop video/x-matroska
xdg-mime default vlc.desktop video/x-flv
xdg-mime default vlc.desktop video/x-ms-wmv
xdg-mime default vlc.desktop video/mpeg
xdg-mime default vlc.desktop video/ogg
xdg-mime default vlc.desktop video/webm
xdg-mime default vlc.desktop video/quicktime
xdg-mime default vlc.desktop video/3gpp
xdg-mime default vlc.desktop video/3gpp2
xdg-mime default vlc.desktop video/x-ms-asf
xdg-mime default vlc.desktop video/x-ogm+ogg
xdg-mime default vlc.desktop video/x-theora+ogg
xdg-mime default vlc.desktop application/ogg

# Open text files with nvim
xdg-mime default nvim.desktop text/plain
xdg-mime default nvim.desktop text/english
xdg-mime default nvim.desktop text/x-makefile
xdg-mime default nvim.desktop text/x-c++hdr
xdg-mime default nvim.desktop text/x-c++src
xdg-mime default nvim.desktop text/x-chdr
xdg-mime default nvim.desktop text/x-csrc
xdg-mime default nvim.desktop text/x-java
xdg-mime default nvim.desktop text/x-moc
xdg-mime default nvim.desktop text/x-pascal
xdg-mime default nvim.desktop text/x-tcl
xdg-mime default nvim.desktop text/x-tex
xdg-mime default nvim.desktop application/x-shellscript
xdg-mime default nvim.desktop text/x-c
xdg-mime default nvim.desktop text/x-c++
xdg-mime default nvim.desktop application/xml
xdg-mime default nvim.desktop text/xml
