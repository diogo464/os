FROM quay.io/fedora/fedora-coreos:stable AS builder

RUN rpm-ostree install --assumeyes --apply-live binutils gcc make autoconf automake libtool rpm-build libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel kernel-devel python3 python3-devel python3-setuptools python3-cffi libffi-devel git ncompress libcurl-devel python3-packaging dkms

WORKDIR /var/zfs
RUN mkdir bin && ln -s /usr/bin/ld.gold bin/ld
ENV PATH="/var/zfs/bin:${PATH}"

RUN git clone https://github.com/openzfs/zfs
WORKDIR /var/zfs/zfs
RUN git checkout master && \
	sh autogen.sh && \
	./configure
RUN make -s -j $(nproc) && \
	make rpm
RUN rm *.src.rpm && rm *debug*.rpm && rm zfs-test*.rpm

FROM git.d464.sh/infra/os/kube:latest

COPY --from=builder /var/zfs/zfs/*.rpm ./
RUN rpm-ostree install --assumeyes --apply-live *.rpm man && rm *.rpm
RUN rpm-ostree override remove nfs-utils-coreos --install nfs-utils
RUN systemctl enable nfs-server
