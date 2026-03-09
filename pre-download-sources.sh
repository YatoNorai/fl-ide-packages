#!/usr/bin/env bash
##
##  pre-download-sources.sh
##
##  Pré-baixa os pacotes que usam fossies.org (bloqueado no Brasil)
##  diretamente para o cache do termux antes do Docker rodar.
##
##  O termux build system verifica o SHA256 do cache antes de baixar.
##  Se o arquivo já estiver em packages/$pkg/cache/$file com o hash certo,
##  ele pula o download completamente — fossies.org não é consultado.
##
##  COMO USAR:
##    chmod +x pre-download-sources.sh
##    ./pre-download-sources.sh
##    ./build-flide-bootstrap.sh   ← depois disso
##

set -e
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*"; }

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
cd "$SCRIPT_DIR"

FAILED=0
CACHED=0
DOWNLOADED=0

##────────────────────────────────────────────────────────────────
## Função principal de download com fallback
##────────────────────────────────────────────────────────────────
cache_pkg() {
    local pkg="$1"
    local filename="$2"
    local sha256="$3"
    shift 3
    local urls=("$@")

    local cache_dir="packages/${pkg}/cache"
    local dest="${cache_dir}/${filename}"

    mkdir -p "$cache_dir"

    # Se já está no cache com hash correto, pular
    if [ -f "$dest" ]; then
        local actual
        actual=$(sha256sum "$dest" | cut -d' ' -f1)
        if [ "$actual" = "$sha256" ]; then
            success "$pkg  →  já no cache"
            CACHED=$((CACHED+1))
            return 0
        else
            warn "$pkg  →  cache corrompido, re-baixando..."
            rm -f "$dest"
        fi
    fi

    # Tentar cada URL em ordem
    local ok=false
    for url in "${urls[@]}"; do
        info "$pkg  →  baixando de: $(echo $url | cut -c1-70)"
        if curl -fsSL \
               --connect-timeout 30 \
               --retry 3 \
               --retry-delay 5 \
               --retry-connrefused \
               -o "$dest" \
               "$url" 2>/dev/null; then
            # Verificar SHA256
            local actual
            actual=$(sha256sum "$dest" | cut -d' ' -f1)
            if [ "$actual" = "$sha256" ]; then
                success "$pkg  →  ok  ($(du -sh "$dest" | cut -f1))"
                DOWNLOADED=$((DOWNLOADED+1))
                ok=true
                break
            else
                warn "$pkg  →  SHA256 errado de $url"
                rm -f "$dest"
            fi
        else
            warn "$pkg  →  falhou: $url"
            rm -f "$dest"
        fi
    done

    if [ "$ok" = false ]; then
        error "$pkg  →  FALHOU em todos os mirrors!"
        error "     O Docker vai tentar baixar diretamente (pode falhar no BR)"
        FAILED=$((FAILED+1))
    fi
}

##────────────────────────────────────────────────────────────────
## Pacotes que usam fossies.org  (14 pacotes)
## Mirrors em ordem de confiabilidade global
##────────────────────────────────────────────────────────────────

echo ""
echo -e "\033[1m=== Pré-download de fontes (bypass fossies.org) ===\033[0m"
echo ""

# ── libbz2 1.0.8 ──────────────────────────────────────────────
cache_pkg "libbz2" "bzip2-1.0.8.tar.xz" \
    "47fd74b2ff83effad0ddf62074e6fad1f6b4a77a96e121ab421c20a216371a1f" \
    "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.xz" \
    "https://mirrors.kernel.org/pub/bzip2/bzip2-1.0.8.tar.xz" \
    "https://mirror.aarnet.edu.au/pub/bzip2/bzip2-1.0.8.tar.xz" \
    "https://ftp.osuosl.org/pub/bzip2/bzip2-1.0.8.tar.xz"

# ── libev 4.33 ────────────────────────────────────────────────
cache_pkg "libev" "libev-4.33.tar.gz" \
    "507eb7b8d1015fbec5b935f34ebed15bf346bed04a11ab82b8eee848c4205aea" \
    "http://dist.schmorp.de/libev/libev-4.33.tar.gz" \
    "http://dist.schmorp.de/libev/Attic/libev-4.33.tar.gz" \
    "https://mirrors.dotsrc.org/pub/libev/libev-4.33.tar.gz" \
    "http://ftp.iij.ad.jp/pub/network/libev/libev-4.33.tar.gz"

# ── liblzo 2.10 ───────────────────────────────────────────────
cache_pkg "liblzo" "lzo-2.10.tar.xz" \
    "37ed4369e45944c53306b0d6a36b66f03e5b6aede8849c9b6388f4b62b20b443" \
    "http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz" \
    "https://www.mirrorservice.org/sites/ftp.oberhumer.com/pub/lzo/lzo-2.10.tar.gz"

# Nota: liblzo usa .tar.xz no build.sh mas mirrors têm .tar.gz
# Se ambos falharem, o script de patch abaixo vai lidar com isso

# ── libpcap 1.10.5 ────────────────────────────────────────────
cache_pkg "libpcap" "libpcap-1.10.5.tar.xz" \
    "84fa89ac6d303028c1c5b754abff77224f45eca0a94eb1a34ff0aa9ceece3925" \
    "https://www.tcpdump.org/release/libpcap-1.10.5.tar.xz" \
    "https://mirrors.dotsrc.org/tcpdump/libpcap-1.10.5.tar.xz"

# ── libsasl (cyrus-sasl) 2.1.28 ───────────────────────────────
cache_pkg "libsasl" "cyrus-sasl-2.1.28.tar.xz" \
    "67f1945057d679414533a30fe860aeb2714f5167a8c03041e023a65f629a9351" \
    "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz" \
    "https://www.cyrusimap.org/releases/cyrus-sasl-2.1.28.tar.gz"

# ── lzop 1.04 ─────────────────────────────────────────────────
cache_pkg "lzop" "lzop-1.04.tar.xz" \
    "dd294d2425a646952e5a316907356ea3c6bddab0f47d5f88ac808c89b290467b" \
    "https://www.lzop.org/download/lzop-1.04.tar.gz" \
    "https://downloads.sourceforge.net/lzop/lzop-1.04.tar.gz"

# ── psmisc 23.7 ───────────────────────────────────────────────
cache_pkg "psmisc" "psmisc-23.7.tar.xz" \
    "58c55d9c1402474065adae669511c191de374b0871eec781239ab400b907c327" \
    "https://gitlab.com/psmisc/psmisc/-/archive/v23.7/psmisc-v23.7.tar.gz" \
    "https://github.com/psmisc/psmisc/archive/refs/tags/v23.7.tar.gz"

# ── cscope 15.9 ───────────────────────────────────────────────
cache_pkg "cscope" "cscope-15.9.tar.gz" \
    "c5505ae075a871a9cd8d9801859b0ff1c09782075df281c72c23e72115d9f159" \
    "https://sourceforge.net/projects/cscope/files/cscope/15.9/cscope-15.9.tar.gz/download" \
    "https://download.sourceforge.net/cscope/cscope-15.9.tar.gz"

# ── libdb 18.1.40 (Oracle Berkeley DB) ───────────────────────
cache_pkg "libdb" "db-18.1.40.tar.gz" \
    "0cecb2ef0c67b166de93732769abdeba0555086d51de1090df325e18ee8da9c8" \
    "https://download.oracle.com/berkeley-db/db-18.1.40.tar.gz" \
    "https://github.com/berkeleydb/libdb/archive/refs/tags/v18.1.40.tar.gz"

# ── libwv 1.2.9 ───────────────────────────────────────────────
cache_pkg "libwv" "wv-1.2.9.tar.gz" \
    "4c730d3b325c0785450dd3a043eeb53e1518598c4f41f155558385dd2635c19d" \
    "https://www.abisource.com/downloads/wv/1.2.9/wv-1.2.9.tar.gz" \
    "https://downloads.sourceforge.net/wvware/wv-1.2.9.tar.gz"

# ── mathomatic 16.0.5 ─────────────────────────────────────────
cache_pkg "mathomatic" "mathomatic-16.0.5.tar.xz" \
    "7f525bdb2e13006549dd8f17906c26f926f5ac51174f02f074107c612491e05c" \
    "https://github.com/nilqed/mathomatic/archive/refs/tags/v16.0.5.tar.gz"

# ── autossh 1.4g ──────────────────────────────────────────────
cache_pkg "autossh" "autossh-1.4g.tgz" \
    "83766463763364a1be56d6bf1a75b40a59302586645bf0c4fa885188cf01ebfc" \
    "https://www.harding.motd.ca/autossh/autossh-1.4g.tgz" \
    "http://www.harding.motd.ca/autossh/autossh-1.4g.tgz"

# ── alpine 2.26 ───────────────────────────────────────────────
cache_pkg "alpine" "alpine-2.26.tar.xz" \
    "c0779c2be6c47d30554854a3e14ef5e36539502b331068851329275898a9baba" \
    "https://alpineapp.email/alpine/release/src/alpine-2.26.tar.xz" \
    "https://invisible-island.net/archives/alpine/alpine-2.26.tar.xz"

##────────────────────────────────────────────────────────────────
## PATCH automático: adaptar build.sh para usar .tar.gz quando
## o download foi .tar.gz em vez de .tar.xz
##────────────────────────────────────────────────────────────────
patch_srcurl_if_needed() {
    local pkg="$1"
    local old_file="$2"   # ex: bzip2-1.0.8.tar.xz
    local new_file="$3"   # ex: bzip2-1.0.8.tar.gz
    local new_sha="$4"
    local new_url="$5"

    local cache_dir="packages/${pkg}/cache"
    local build_sh="packages/${pkg}/build.sh"

    # Se o .tar.gz existe no cache mas o .tar.xz não, patch o build.sh
    if [ -f "${cache_dir}/${new_file}" ] && [ ! -f "${cache_dir}/${old_file}" ]; then
        info "Adaptando ${pkg}/build.sh para usar .tar.gz..."
        sed -i "s|${old_file}|${new_file}|g" "$build_sh"
        sed -i "s|TERMUX_PKG_SHA256=.*|TERMUX_PKG_SHA256=${new_sha}|g" "$build_sh"
        sed -i "s|TERMUX_PKG_SRCURL=.*|TERMUX_PKG_SRCURL=${new_url}|g" "$build_sh"
        success "  ${pkg}/build.sh patchado"
    fi
}

# Aplicar patches se necessário (para os que baixaram .tar.gz em vez de .tar.xz)
# liblzo: o mirror tem .tar.gz mas o build.sh espera .tar.xz
if [ -f "packages/liblzo/cache/lzo-2.10.tar.gz" ] && [ ! -f "packages/liblzo/cache/lzo-2.10.tar.xz" ]; then
    # SHA256 do .tar.gz
    patch_srcurl_if_needed "liblzo" "lzo-2.10.tar.xz" "lzo-2.10.tar.gz" \
        "$(sha256sum packages/liblzo/cache/lzo-2.10.tar.gz | cut -d' ' -f1)" \
        "http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"
fi

##────────────────────────────────────────────────────────────────
## RESUMO
##────────────────────────────────────────────────────────────────
echo ""
echo -e "\033[1m=== Resumo ===\033[0m"
echo -e "  ${GREEN}✓${NC} No cache:   ${CACHED}"
echo -e "  ${GREEN}✓${NC} Baixados:   ${DOWNLOADED}"
if [ $FAILED -gt 0 ]; then
    echo -e "  ${RED}✗${NC} Falhas:     ${FAILED}"
    echo ""
    warn "Alguns pacotes não puderam ser pré-baixados."
    warn "O Docker vai tentar baixá-los durante o build."
    warn "Se falhar de novo, tente usar uma VPN ou proxy."
else
    echo ""
    success "Tudo pronto! Rode agora: ./build-flide-bootstrap.sh"
fi
echo ""
