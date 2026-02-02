FROM quay.io/gmanka/archlinuxarm:base-devel

ARG TARGETARCH

LABEL com.github.containers.toolbox="true" \
      name="arch-arm-toolbox" \
      version="base-devel" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Base image for creating Arch Linux Toolbx containers" \
      maintainer="gmanka https://github.com/gmanka-containers"

# Install extra packages
RUN --mount=type=cache,id=pacman-pkg-$TARGETARCH,target=/var/cache/pacman/pkg \
    --mount=type=cache,id=pacman-sync-$TARGETARCH,target=/var/lib/pacman/sync \
    --mount=type=bind,source=extra-packages,target=/extra-packages,ro,z \
    pacman --disable-sandbox -Syu --needed --noconfirm < extra-packages

# Enable man pages, enable progress bars
RUN sed -i -e 's/NoProgressBar/#NoProgressBar/' -e 's/NoExtract/#NoExtract/' /etc/pacman.conf

# Force reinstall of packages which have man pages (shouldn't redownload any that were just upgraded)
RUN --mount=type=cache,id=pacman-pkg-$TARGETARCH,target=/var/cache/pacman/pkg \
    --mount=type=cache,id=pacman-sync-$TARGETARCH,target=/var/lib/pacman/sync \
    mkdir -p /usr/share/man && pacman -Qo /usr/share/man | awk '{print $5}' | xargs pacman --disable-sandbox -S --noconfirm man-db

# Enable sudo permission for wheel users
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/toolbox
