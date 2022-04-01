FROM archlinux:base-devel

RUN pacman -Syu --needed --noconfirm git

RUN groupadd -f -r wheel
RUN useradd -m -G wheel -s /bin/bash builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
