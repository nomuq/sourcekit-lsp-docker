FROM swift as lsp-builder

RUN apt-get -q update && \
    apt-get -q install -y \
    sqlite3 \
    libsqlite3-dev \
    libblocksruntime-dev

# Download and Build Sourcekit-LSP
RUN git clone --depth 1 https://github.com/apple/sourcekit-lsp
WORKDIR /sourcekit-lsp
# RUN swift build -Xcxx -I/usr/lib/swift && mv `swift build --show-bin-path`/sourcekit-lsp /usr/bin/
RUN swift build -Xcxx -I/usr/lib/swift -I/usr/lib/swift/Block && mv `swift build --show-bin-path`/sourcekit-lsp /usr/bin/
RUN chmod -R o+r /usr/bin/sourcekit-lsp

FROM swift

# Set absolute path to the swift toolchain
ENV SOURCEKIT_TOOLCHAIN_PATH=/usr/lib/swift

# ENV SOURCEKIT_LOGGING=3
ENV DEBIAN_FRONTEND noninteractive

# Sourcekit-LSP Executable
COPY --from=lsp-builder /usr/bin/sourcekit-lsp /usr/bin/
ENV PATH=/usr/bin/sourcekit-lsp:$PATH
