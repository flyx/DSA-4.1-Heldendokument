FROM dsa-4.1-heldendokument

COPY docker/index.html docker/serve.go /heldendokument/
COPY templates /heldendokument/templates

RUN apt install -y --no-install-recommends golang-1.15-go && \
    env GO111MODULE=off /usr/lib/go-1.15/bin/go build -o serve && \
    apt remove -y --purge golang-1.15-go && \
    apt autoremove -y && \
    rm serve.go && mkdir -p /ramdisk

EXPOSE 80/tcp

ENTRYPOINT ["/heldendokument/serve"]