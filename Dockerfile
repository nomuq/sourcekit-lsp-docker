FROM satishbabariya/swift as lsp-builder

RUN apt-get -q update && \
    apt-get -q install -y \
    sqlite3 \
    libsqlite3-dev \
    libblocksruntime-dev

RUN curl -fSsL https://github.com/apple/sourcekit-lsp/archive/$(echo "$SWIFT_VERSION" | tr -d .).tar.gz -o sourcekit-lsp.tar.gz \
    && tar -xzf sourcekit-lsp.tar.gz --directory /
RUN mv sourcekit-lsp-$(echo "$SWIFT_VERSION" | tr -d .) sourcekit-lsp

WORKDIR /sourcekit-lsp
RUN swift build -Xcxx -I/usr/lib/swift && mv `swift build --show-bin-path`/sourcekit-lsp /usr/bin/
RUN chmod -R o+r /usr/bin/sourcekit-lsp


FROM satishbabariya/swift

# Set absolute path to the swift toolchain
ENV SOURCEKIT_TOOLCHAIN_PATH=/usr/lib/swift

# ENV SOURCEKIT_LOGGING=3
ENV DEBIAN_FRONTEND noninteractive

# Sourcekit-LSP Executable
COPY --from=lsp-builder /usr/bin/sourcekit-lsp /usr/bin/
ENV PATH=/usr/bin/sourcekit-lsp:$PATH
