FROM ghcr.io/linuxserver/baseimage-selkies:arch

ARG BUILD_DATE
ARG VERSION
ARG CACHE_BUST
ARG PLEZY_VERSION=2.6.0
ARG PLEZY_SHA256=4f3f1911bc679b8d07b341a4051ede5b8b6dc39f88250f4b7e61e6fd1e6dffce

LABEL build_version="Custom Arch Plezy image - Build-date:- ${BUILD_DATE}"
LABEL maintainer="Serph91P"
LABEL org.opencontainers.image.title="docker-webtop-plezy"
LABEL org.opencontainers.image.description="Plezy running in LinuxServer Selkies"
LABEL org.opencontainers.image.source="https://github.com/Serph91P/docker-webtop-plezy"

ENV TITLE="Plezy"     PIXELFLUX_WAYLAND=true     SELKIES_DESKTOP=false     AUTO_GPU=true     NO_GAMEPAD=true     NO_DECOR=true

RUN set -eux;   echo "**** cache bust ${CACHE_BUST} ****";   echo "**** install Plezy runtime packages ****";   pacman -Sy --noconfirm --needed     alsa-lib     ca-certificates     curl     dbus     glib2     gtk3     libepoxy     libevdev     mpv     xdg-user-dirs;   echo "**** install Plezy binary package ****";   curl -fsSL -o /tmp/plezy-linux-x64.pkg.tar.zst     "https://github.com/edde746/plezy/releases/download/${PLEZY_VERSION}/plezy-linux-x64.pkg.tar.zst";   echo "${PLEZY_SHA256}  /tmp/plezy-linux-x64.pkg.tar.zst" | sha256sum -c -;   pacman -U --noconfirm /tmp/plezy-linux-x64.pkg.tar.zst;   ls -la /usr/bin/plezy /opt/plezy/plezy;   echo "**** verify nginx config stays compatible with baseimage modules ****";   nginx -t;   echo "**** add icon ****";   cp /usr/share/icons/hicolor/256x256/apps/plezy.png /usr/share/selkies/www/icon.png;   echo "**** set bash as default shell ****";   sed -i 's|/bin/sh$|/bin/bash|g' /etc/passwd;   echo "**** create user directories ****";   mkdir -p /config/Documents;   echo "**** cleanup ****";   rm -rf     /config/.cache     /tmp/*     /var/cache/pacman/pkg/*     /var/lib/pacman/sync/*

COPY root/ /

RUN chmod +x /defaults/autostart /defaults/autostart_wayland /defaults/startwm_wayland.sh /usr/local/bin/run-plezy &&     echo "**** verify final Plezy image contents ****" &&     ls -la /usr/bin/plezy /opt/plezy/plezy &&     (/usr/local/bin/run-plezy --version >/tmp/plezy-version.log 2>&1 || true) &&     HOME=/config XDG_CONFIG_HOME=/config/.config xdg-user-dir DOCUMENTS &&     touch /tmp/plezy-version.log &&     cat /tmp/plezy-version.log

EXPOSE 3000

VOLUME /config
