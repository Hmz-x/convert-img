FROM archlinux:latest

WORKDIR /usr/local/bin/

# Install necessary packages
RUN pacman --noconfirm -Syu && \
    pacman --noconfirm -S ffmpeg imagemagick

# Copy scripts and set permissions
COPY . /usr/local/bin/

# No need to use install.sh when in a dockerized env since convert scripts are copied to path
RUN chmod 755 /usr/local/bin/convert-img.sh /usr/local/bin/convert-vid.sh \ 
    /usr/local/bin/process.sh

# Change workdir to where photo uploads are to be made
WORKDIR /usr/local/app/uploads
CMD ["process.sh"]
