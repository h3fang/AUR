FROM archlinux:base-devel

RUN pacman -Syu --needed --noconfirm git

RUN groupadd -f -r wheel
RUN useradd -d /builder -m builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /builder

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
