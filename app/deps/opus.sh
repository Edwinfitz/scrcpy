#!/usr/bin/env bash
set -ex
. $(dirname ${BASH_SOURCE[0]})/_init
process_args "$@"

VERSION=1.6.1
URL="https://downloads.xiph.org/releases/opus/opus-$VERSION.tar.gz"
SHA256SUM=6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1

PROJECT_DIR="opus-$VERSION"
FILENAME="$PROJECT_DIR.tar.gz"

cd "$SOURCES_DIR"

if [[ -d "$PROJECT_DIR" ]]
then
    echo "$PWD/$PROJECT_DIR" found
else
    get_file "$URL" "$FILENAME" "$SHA256SUM"
    tar xf "$FILENAME"  # First level directory is "$PROJECT_DIR"
fi

mkdir -p "$BUILD_DIR/$PROJECT_DIR"
cd "$BUILD_DIR/$PROJECT_DIR"

if [[ -d "$DIRNAME" ]]
then
    echo "'$PWD/$DIRNAME' already exists, not reconfigured"
    cd "$DIRNAME"
else
    mkdir "$DIRNAME"
    cd "$DIRNAME"

    conf=(
        --prefix="$INSTALL_DIR/$DIRNAME"
        --libdir="$INSTALL_DIR/$DIRNAME/lib"
        # Always build opus statically
        --disable-shared
        --enable-static
        --with-pic
        --disable-doc
        --disable-extra-programs
    )

    if [[ "$BUILD_TYPE" == cross ]]
    then
        case "$HOST" in
            win32)
                conf+=(--host=i686-w64-mingw32)
                ;;

            win64)
                conf+=(--host=x86_64-w64-mingw32)
                ;;

            *)
                echo "Unsupported host: $HOST" >&2
                exit 1
        esac
    fi

    "$SOURCES_DIR/$PROJECT_DIR/configure" "${conf[@]}"
fi

make -j"$(nproc)"
make install