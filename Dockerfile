ARG PORTAGEDATE

FROM gentoo/portage:${PORTAGEDATE} AS portage-image

FROM gentoo/stage3:${PORTAGEDATE}
RUN --mount=type=bind,from=ghcr.io/fouzes/distcc,source=/var/cache/binpkgs,target=/cache \
    --mount=type=bind,from=portage-image,source=/var/db/repos/gentoo,target=/var/db/repos/gentoo \
    set -eux; \
    cp -av /cache/. /var/cache/binpkgs; \
    cp -a /var/db/repos/gentoo/profiles/. /profiles; \
    export NEW_PROFILE_PATH=$(readlink /etc/portage/make.profile | sed -e 's/..\/..\/var\/db\/repos\/gentoo//'); \
    echo ${NEW_PROFILE_PATH}; \
    rm /etc/portage/make.profile; \
    ln -s ${NEW_PROFILE_PATH} /etc/portage/make.profile; \
    export EMERGE_DEFAULT_OPTS="--buildpkg --color=y --quiet-build --tree --usepkg --verbose"; \
    emerge sys-devel/distcc sys-devel/clang; \
    distcc --version; \
    emerge --oneshot gentoolkit; \
    eclean-pkg -d; \
    rm -rf /var/cache/distfiles/*; \
    CLEAN_DELAY=0 emerge --depclean gentoolkit; \
    env-update;
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3632
