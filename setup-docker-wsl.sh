#!/usr/bin/env bash
##
##  Setup Docker no WSL2 — rode UMA VEZ antes de tudo
##  Resolve o problema do Docker não iniciar automaticamente
##

set -e
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }

echo ""
echo -e "\033[1m=== Setup Docker no WSL2 para FL IDE ===\033[0m"
echo ""

## 1. Instalar Docker se não existir
if ! command -v docker &>/dev/null; then
    info "Instalando Docker..."
    sudo apt-get update -qq
    sudo apt-get install -y docker.io
    success "Docker instalado!"
else
    success "Docker já instalado: $(docker --version)"
fi

## 2. Adicionar usuário ao grupo docker (sem precisar de sudo)
if ! groups "$USER" | grep -q docker; then
    info "Adicionando $USER ao grupo docker..."
    sudo usermod -aG docker "$USER"
    warn "Você precisará fechar e reabrir o WSL para aplicar o grupo."
    warn "Após reabrir, rode este script novamente para continuar."
fi

## 3. Configurar auto-start do Docker no WSL2
WSL_CONF="/etc/wsl.conf"
if ! grep -q "service docker start" "$WSL_CONF" 2>/dev/null; then
    info "Configurando Docker para iniciar automaticamente no WSL2..."
    if ! grep -q "\[boot\]" "$WSL_CONF" 2>/dev/null; then
        echo "" | sudo tee -a "$WSL_CONF" > /dev/null
        echo "[boot]" | sudo tee -a "$WSL_CONF" > /dev/null
    fi
    echo "command=service docker start" | sudo tee -a "$WSL_CONF" > /dev/null
    success "Auto-start configurado em $WSL_CONF"
else
    success "Auto-start já configurado"
fi

## 4. Iniciar Docker agora
info "Iniciando Docker..."
sudo service docker start
sleep 3

## 5. Testar
if docker info &>/dev/null 2>&1; then
    success "Docker está rodando!"
    docker --version
else
    warn "Docker pode precisar de alguns segundos. Tente:"
    echo "  sudo service docker start"
    echo "  docker info"
fi

echo ""
echo -e "\033[1m\033[0;32mSetup concluído! Agora rode:\033[0m"
echo "  ./build-flide-bootstrap.sh"
echo ""
