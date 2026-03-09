#!/usr/bin/env bash
set -e

PACKAGE_NAME="com.yato.fl_ide"
ARCH="aarch64"
EXTRA="git,android-tools"
IMAGE="ghcr.io/termux/package-builder:latest"

SCRIPT_DIR="$(pwd)"

echo ""
echo "FL IDE Bootstrap Builder"
echo ""
echo "Docker: $(docker --version)"
echo ""

##────────────────────────────────────────────────────────────────
## MODO RESUME
## O build pode ser retomado de onde parou:
##   - output/          → .deb já compilados (persistem entre runs)
##   - .built-packages-aarch64/ → marcadores de pacotes prontos
## Basta rodar o script de novo que pacotes já compilados são pulados.
##────────────────────────────────────────────────────────────────
RESUME=false
if [ -d "$SCRIPT_DIR/.built-packages-aarch64" ] && \
   [ "$(ls -A "$SCRIPT_DIR/.built-packages-aarch64" 2>/dev/null)" ]; then
    COUNT=$(ls "$SCRIPT_DIR/.built-packages-aarch64" | wc -l)
    echo ">> Encontrados $COUNT pacotes já compilados."
    echo ">> O build vai continuar de onde parou (sem recompilar esses pacotes)."
    RESUME=true
fi

echo ""
read -p "ENTER para iniciar..."

##────────────────────────────────────────────────────────────────
## PRÉ-DOWNLOAD (bypass fossies.org bloqueado no BR)
##────────────────────────────────────────────────────────────────
pre_cache() {
    local pkg="$1" filename="$2" sha256="$3"
    shift 3
    local dest="packages/${pkg}/cache/${filename}"
    mkdir -p "packages/${pkg}/cache"

    if [ -f "$dest" ]; then
        local actual; actual=$(sha256sum "$dest" | cut -d' ' -f1)
        if [ "$actual" = "$sha256" ]; then
            echo "  [cache] $pkg"
            return 0
        fi
        rm -f "$dest"
    fi

    echo "  [baixando] $pkg..."
    local ok=false
    for url in "$@"; do
        if curl -fsSL --connect-timeout 30 --retry 3 --retry-delay 5 \
               -o "$dest" "$url" 2>/dev/null; then
            local actual; actual=$(sha256sum "$dest" | cut -d' ' -f1)
            if [ "$actual" = "$sha256" ]; then
                echo "  [ok] $pkg"
                ok=true; break
            fi
            rm -f "$dest"
        fi
    done

    if [ "$ok" = false ]; then
        echo "  [aviso] $pkg nao pre-baixado — Docker vai tentar direto"
    fi
}

echo "Pre-baixando fontes que usam fossies.org (bloqueado no BR)..."

# bzip2 — URL oficial: https://sourceware.org/pub/bzip2/
pre_cache "libbz2" "bzip2-1.0.8.tar.gz" \
    "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269" \
    "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz" \
    "https://mirror.bazel.build/sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"

pre_cache "libpcap" "libpcap-1.10.5.tar.xz" \
    "84fa89ac6d303028c1c5b754abff77224f45eca0a94eb1a34ff0aa9ceece3925" \
    "https://www.tcpdump.org/release/libpcap-1.10.5.tar.xz"

pre_cache "libev" "libev-4.33.tar.gz" \
    "507eb7b8d1015fbec5b935f34ebed15bf346bed04a11ab82b8eee848c4205aea" \
    "http://dist.schmorp.de/libev/libev-4.33.tar.gz" \
    "http://dist.schmorp.de/libev/Attic/libev-4.33.tar.gz"

pre_cache "liblzo" "lzo-2.10.tar.xz" \
    "37ed4369e45944c53306b0d6a36b66f03e5b6aede8849c9b6388f4b62b20b443" \
    "http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"

pre_cache "libsasl" "cyrus-sasl-2.1.28.tar.xz" \
    "67f1945057d679414533a30fe860aeb2714f5167a8c03041e023a65f629a9351" \
    "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz"

pre_cache "lzop" "lzop-1.04.tar.xz" \
    "dd294d2425a646952e5a316907356ea3c6bddab0f47d5f88ac808c89b290467b" \
    "https://www.lzop.org/download/lzop-1.04.tar.gz"

pre_cache "psmisc" "psmisc-23.7.tar.xz" \
    "58c55d9c1402474065adae669511c191de374b0871eec781239ab400b907c327" \
    "https://gitlab.com/psmisc/psmisc/-/archive/v23.7/psmisc-v23.7.tar.gz" \
    "https://github.com/psmisc/psmisc/archive/refs/tags/v23.7.tar.gz"

pre_cache "cscope" "cscope-15.9.tar.gz" \
    "c5505ae075a871a9cd8d9801859b0ff1c09782075df281c72c23e72115d9f159" \
    "https://sourceforge.net/projects/cscope/files/cscope/15.9/cscope-15.9.tar.gz/download"

pre_cache "libdb" "db-18.1.40.tar.gz" \
    "0cecb2ef0c67b166de93732769abdeba0555086d51de1090df325e18ee8da9c8" \
    "https://download.oracle.com/berkeley-db/db-18.1.40.tar.gz"

pre_cache "autossh" "autossh-1.4g.tgz" \
    "83766463763364a1be56d6bf1a75b40a59302586645bf0c4fa885188cf01ebfc" \
    "https://www.harding.motd.ca/autossh/autossh-1.4g.tgz" \
    "http://www.harding.motd.ca/autossh/autossh-1.4g.tgz"

echo ""

##────────────────────────────────────────────────────────────────
## DOCKER RUN
##────────────────────────────────────────────────────────────────
mkdir -p output

echo "Baixando imagem..."
docker pull $IMAGE

echo ""
echo "Iniciando container..."

docker run --rm -it --user root \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -v "$SCRIPT_DIR:/home/builder/termux-packages" \
    -e TERMUX_APP_PACKAGE=$PACKAGE_NAME \
    $IMAGE bash -c "
        set -e
        cd /home/builder/termux-packages

        # ── Fix clock skew (WSL2/Docker podem ter relógio levemente dessincronizado)
        # O Perl detecta arquivos com timestamp 'no futuro' e falha o make.
        # Sincronizar o relógio do container com o hardware resolve.
        hwclock --hctosys 2>/dev/null || ntpdate -u pool.ntp.org 2>/dev/null || true

        # NDK
        mkdir -p /root/lib
        if [ ! -d /root/lib/android-ndk-r29 ]; then
            echo 'Baixando NDK...'
            apt update -qq
            apt install -y curl unzip
            curl -L https://dl.google.com/android/repository/android-ndk-r29-linux.zip -o ndk.zip
            unzip -q ndk.zip
            mv android-ndk-r29 /root/lib/
            rm ndk.zip
        fi
        echo 'NDK pronto'

        ./scripts/build-bootstraps.sh --architectures $ARCH --add $EXTRA
        echo ''
        echo 'Zips gerados:'
        ls -lh bootstrap-*.zip || echo 'Nenhum bootstrap-*.zip encontrado'
    "

sudo chown -R $USER:$USER "$SCRIPT_DIR" 2>/dev/null || true

echo ""
echo "Build finalizado!"
echo ""
echo "Verificar caminhos corretos:"
echo "  unzip -p bootstrap-aarch64.zip SYMLINKS.txt | head -5"
echo "  (deve mostrar /data/data/com.yato.fl_ide/...)"
