# Changelog - Modificações para FL_IDE

## Alterações realizadas para adaptação ao pacote com.yato.fl_ide

### Data: 10 de Março de 2026

Este projeto foi modificado para compilar binários do Bootstrap do Termux especificamente para o aplicativo **com.yato.fl_ide** ao invés de **com.itsaky.androidide**.

---

## Arquivos Modificados

### 1. **scripts/properties.sh**
Arquivo principal de configuração do projeto.

**Alterações:**
- `TERMUX_APP_PACKAGE`: Alterado de `"com.itsaky.androidide"` para `"com.yato.fl_ide"`
- `TERMUX_REPO_PACKAGE`: Alterado de `"com.itsaky.androidide"` para `"com.yato.fl_ide"`

**Impacto:**
- Define o pacote do app onde os binários serão instalados: `/data/data/com.yato.fl_ide/files/`
- Define o pacote do repositório de onde os pacotes serão baixados

---

### 2. **scripts/test-runner.sh**
Script de testes.

**Alterações:**
- Shebang alterado de `#!/data/data/com.itsaky.androidide/files/usr/bin/bash` para `#!/data/data/com.yato.fl_ide/files/usr/bin/bash`

---

### 3. **scripts/build-bootstraps.sh**
Script de build de bootstraps.

**Alterações:**
- Comentário de documentação atualizado para referenciar `com.yato.fl_ide`

---

### 4. **build-package.sh**
Script principal de build de pacotes.

**Alterações:**
- 4 ocorrências atualizadas em verificações de PATH e mensagens de erro
- Referências ao prefix `/data/data/com.itsaky.androidide/files/usr` alteradas para `/data/data/com.yato.fl_ide/files/usr`

---

### 5. **x11-packages/qt5-qmake/termux-build-qmake.sh**
Script de build do Qt5.

**Alterações:**
- Shebang atualizado: `#!/data/data/com.yato.fl_ide/files/usr/bin/bash`
- `TERMUX_PREFIX` alterado para: `/data/data/com.yato.fl_ide/files/usr`

---

### 6. **packages/nlohmann-json/build.sh**
Script de build da biblioteca nlohmann-json.

**Alterações:**
- Comentários com paths atualizados para o novo pacote

---

### 7. **packages/rust/build.sh**
Script de build do Rust.

**Alterações:**
- Comentários com paths de biblioteca atualizados

---

### 8. **packages/alpine/build.sh**
Script de build do Alpine.

**Alterações:**
- Script postinst com certificado SSL atualizado

---

## Como Usar

### Workflow de GitHub Actions

O workflow `.github/workflows/bootstrap_archives.yml` está configurado para:

1. **Build automatizado**: Gera archives de bootstrap para múltiplas arquiteturas
   - aarch64
   - arm
   - i686
   - x86_64

2. **Publicação**: Cria releases no GitHub com os binários compilados

### Build Manual

Para gerar os bootstraps manualmente:

```bash
# Gerar para todas as arquiteturas
./scripts/generate-bootstraps.sh

# Gerar para uma arquitetura específica
./scripts/generate-bootstraps.sh --architectures aarch64

# Gerar com pacotes adicionais
./scripts/generate-bootstraps.sh --add "git,python"
```

### Outputs Esperados

Os binários gerados serão:
- `bootstrap-aarch64.zip`
- `bootstrap-arm.zip`
- `bootstrap-i686.zip`
- `bootstrap-x86_64.zip`

Cada arquivo contém:
- Pacotes essenciais do Termux configurados para `/data/data/com.yato.fl_ide/files/usr/`
- Ferramentas específicas do AndroidIDE (agora FL_IDE)
- Gerenciador de pacotes APT configurado

---

## Notas Importantes

1. **Assinaturas**: Os binários serão compilados com as configurações para o pacote `com.yato.fl_ide`. Certifique-se de que seu aplicativo use este nome de pacote exato.

2. **Repositório**: Por padrão, o script busca pacotes de `https://packages.androidide.com/apt/termux-main`. Se você tiver um repositório customizado, use a opção `--repository` ao gerar os bootstraps.

3. **Compatibilidade**: Os bootstraps são compatíveis com Android 7.0+ por padrão. Use `--android10` se precisar de compatibilidade específica com Android 10+.

---

## Verificação

Para verificar se todas as alterações foram aplicadas:

```bash
# Buscar qualquer referência ao pacote antigo
grep -r "com.itsaky.androidide" . --include="*.sh" --include="*.yml"

# Deve retornar 0 resultados

# Verificar o novo pacote
grep -r "com.yato.fl_ide" . --include="*.sh" --include="*.yml"

# Deve retornar múltiplas ocorrências nos arquivos listados acima
```

---

## Próximos Passos

1. Configure seu repositório Git com este código
2. Configure o GitHub Actions com as secrets necessárias
3. Execute o workflow para gerar os binários
4. Integre os binários no seu app FL_IDE

---

**Modificado por**: Claude AI Assistant
**Data**: 10 de Março de 2026
**Versão Original**: terminal-packages (AndroidIDE fork)
**Versão Modificada**: terminal-packages (FL_IDE fork)
