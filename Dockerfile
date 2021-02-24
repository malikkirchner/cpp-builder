FROM archlinux/archlinux:base

ARG user=builder
ARG group=builder
ARG uid=1000
ARG gid=1000

ARG C_FLAGS="-march=x86_64 -O2 -pipe -fstack-protector-strong"
ARG CXX_FLAGS="-march=x86_64 -O2 -pipe -fstack-protector-strong"

ENV UBSAN_OPTIONS='print_stacktrace=1'

COPY ccache.conf /etc/ccache.conf

# explicitly generate and use en_US.UTF-8 locale
ENV LANG=en_US.UTF-8
RUN    echo "LANG=en_US.UTF-8" > /etc/locale.conf                                   \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen                                   \
    && locale-gen

# update system and install build env
RUN    pacman -Syu --noconfirm --needed                                             \
                             gcc git git-lfs cmake ninja vim automake autoconf      \
                             m4 wget ccache doxygen graphviz python patch file      \
                             python-pip python-virtualenv pixz pigz rsync glibc     \
                             sloccount libtool make unzip python-pytest perl-json   \
                             pkg-config fakeroot libunwind openssh clang            \
                             patchelf gdb openmp nodejs llvm gcc-fortran nasm       \
                             lsb-release bison flex byacc gettext boost openssl     \
                             gtest protobuf libffi                                  \
    # create builder user and group
    && groupadd -g ${gid} ${group}                                                  \
    && useradd -u ${uid} -g ${gid} -s /bin/bash -m -d /home/${user} ${user}         \
    && su ${user} -c 'mkdir -p /home/builder/ccache'                                \
    # create workspace directories
    && mkdir /workspace && chown -R ${user} /workspace                              \
    # build and install Clang's libc++ (Clang dependency)
    && su ${user} -c 'gpg --recv-key A2C794A986419D8A | true'                       \
    && su ${user} -c 'gpg --recv-key 0FC3042E345AD05D | true'                       \
    && su ${user} -c 'git clone https://aur.archlinux.org/libc++.git  /tmp/libc++'  \
    && cd /tmp/libc++                                                               \
    # FIXME: tests are failing due to a deprecated python function call, ignore failure for now
    && MAKEFLAGS="-j$(nproc)" CC=clang CXX=clang++ CFLAGS="${C_FLAGS}" CXXFLAGS="${CXX_FLAGS}" su ${user} -c makepkg | true \
    && yes | pacman -U /tmp/libc++/*.pkg.tar.* | true                               \
    # build and install
    && su ${user} -c 'git clone https://aur.archlinux.org/lcov.git /tmp/lcov'       \
    && cd /tmp/lcov                                                                 \
    && MAKEFLAGS="-j$(nproc)" CFLAGS="${C_FLAGS}" CXXFLAGS="${CXX_FLAGS}" su ${user} -c makepkg \
    && yes | pacman -U /tmp/lcov/*.pkg.tar.*                                        \
    # install conan
    && pip install conan                                                            \
    # cleanup
    && (pacman -Rns --noconfirm $(pacman -Qtdq) || true)                            \
    && rm -rf /tmp/*                                                                \
    && yes | pacman -Scc | true

VOLUME /workspace
VOLUME /home/builder/ccache

WORKDIR /workspace
