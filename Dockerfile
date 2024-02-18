ARG PORTAGEDATE

FROM gentoo/portage:${PORTAGEDATE} AS portage-image

FROM gentoo/stage3:latest
RUN --mount=type=bind,from=ghcr.io/fouzes/distcc,source=/var/cache/binpkgs,target=/cache \
    --mount=type=bind,from=portage-image,source=/var/db/repos/gentoo,target=/var/db/repos/gentoo \
    set -eux; \
    cp -av /cache/. /var/cache/binpkgs; \
    cp -av /var/db/repos/gentoo/profiles/. /profiles; \
    rm /etc/portage/make.profile; \
    ln -s /profiles/default/linux/amd64/17.1 /etc/portage/make.profile; \
    export EMERGE_DEFAULT_OPTS="--buildpkg --color=y --quiet-build --tree --usepkg --verbose"; \
    emerge sys-devel/distcc sys-devel/clang; \
    distcc --version; \
    emerge --oneshot gentoolkit; \
    eclean packages; \
    CLEAN_DELAY=0 emerge --depclean gentoolkit; \
    env-update;
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3632
