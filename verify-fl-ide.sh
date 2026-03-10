#!/bin/bash
##
## Script de verificação das modificações para FL_IDE
##

echo "========================================"
echo "Verificação de Modificações - FL_IDE"
echo "========================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de verificações
PASSED=0
FAILED=0

echo "1. Verificando pacote antigo (com.itsaky.androidide)..."
OLD_COUNT=$(grep -r "com\.itsaky\.androidide" . --include="*.sh" --include="*.yml" --include="*.yaml" --exclude="verify-fl-ide.sh" 2>/dev/null | wc -l)
if [ "$OLD_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Nenhuma referência ao pacote antigo encontrada"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - Encontradas $OLD_COUNT referências ao pacote antigo"
    echo "  Execute: grep -r 'com.itsaky.androidide' . --include='*.sh'"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "2. Verificando novo pacote (com.yato.fl_ide)..."
NEW_COUNT=$(grep -r "com\.yato\.fl_ide" . --include="*.sh" --include="*.yml" --include="*.yaml" 2>/dev/null | wc -l)
if [ "$NEW_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Encontradas $NEW_COUNT referências ao novo pacote"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - Nenhuma referência ao novo pacote encontrada"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "3. Verificando scripts/properties.sh..."
if grep -q 'TERMUX_APP_PACKAGE="com.yato.fl_ide"' scripts/properties.sh 2>/dev/null; then
    echo -e "${GREEN}✓ PASSOU${NC} - TERMUX_APP_PACKAGE está correto"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - TERMUX_APP_PACKAGE não está correto"
    FAILED=$((FAILED + 1))
fi

if grep -q 'TERMUX_REPO_PACKAGE="com.yato.fl_ide"' scripts/properties.sh 2>/dev/null; then
    echo -e "${GREEN}✓ PASSOU${NC} - TERMUX_REPO_PACKAGE está correto"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - TERMUX_REPO_PACKAGE não está correto"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "4. Verificando scripts essenciais..."
ESSENTIAL_SCRIPTS=(
    "scripts/test-runner.sh"
    "scripts/build-bootstraps.sh"
    "scripts/generate-bootstraps.sh"
    "build-package.sh"
)

for script in "${ESSENTIAL_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo -e "${GREEN}✓${NC} $script existe"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $script não encontrado"
        FAILED=$((FAILED + 1))
    fi
done
echo ""

echo "5. Verificando workflow de GitHub Actions..."
if [ -f ".github/workflows/bootstrap_archives.yml" ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Workflow de bootstrap encontrado"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - Workflow de bootstrap não encontrado"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "6. Verificando estrutura de diretórios..."
REQUIRED_DIRS=(
    "scripts"
    "packages"
    ".github/workflows"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} Diretório $dir existe"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} Diretório $dir não encontrado"
        FAILED=$((FAILED + 1))
    fi
done
echo ""

echo "========================================"
echo "Resumo da Verificação"
echo "========================================"
echo -e "Testes passados: ${GREEN}$PASSED${NC}"
echo -e "Testes falhados: ${RED}$FAILED${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ SUCESSO!${NC} Todas as verificações passaram!"
    echo ""
    echo "O projeto está pronto para compilar bootstraps para FL_IDE (com.yato.fl_ide)"
    echo ""
    echo "Próximos passos:"
    echo "1. Execute: ./scripts/generate-bootstraps.sh"
    echo "2. Ou use GitHub Actions para build automático"
    exit 0
else
    echo -e "${RED}✗ ATENÇÃO!${NC} Algumas verificações falharam."
    echo "Por favor, revise os erros acima antes de continuar."
    exit 1
fi
