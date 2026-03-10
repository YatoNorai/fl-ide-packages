# Terminal Packages - FL_IDE Edition

Este é um fork do projeto terminal-packages modificado especificamente para o aplicativo **FL_IDE** (com.yato.fl_ide).

## Sobre

Este repositório contém scripts e configurações para compilar binários do Bootstrap do Termux que funcionarão com o aplicativo FL_IDE. Todos os pacotes são configurados para serem instalados no diretório:

```
/data/data/com.yato.fl_ide/files/usr/
```

## Diferenças do Original

Este fork foi modificado do projeto AndroidIDE terminal-packages com as seguintes mudanças principais:

- ✅ Nome do pacote alterado de `com.itsaky.androidide` para `com.yato.fl_ide`
- ✅ Todos os paths de instalação atualizados
- ✅ Scripts de build atualizados
- ✅ Workflow de CI/CD configurado para FL_IDE

## Quick Start

### Requisitos

- Ubuntu/Linux (recomendado Ubuntu 20.04+)
- Git
- Bash
- Docker (opcional, mas recomendado)

### Gerar Bootstraps Localmente

```bash
# Clone o repositório
git clone <seu-repositorio>
cd terminal-packages-master

# Gerar bootstraps para todas as arquiteturas
./scripts/generate-bootstraps.sh

# Ou para uma arquitetura específica
./scripts/generate-bootstraps.sh --architectures aarch64
```

### Usar com GitHub Actions

1. Faça fork deste repositório
2. Os workflows estão em `.github/workflows/`
3. O workflow `bootstrap_archives.yml` gera os binários automaticamente

Para executar manualmente:
- Vá em Actions > Generate bootstrap archives > Run workflow

## Arquiteturas Suportadas

- **aarch64** (ARM 64-bit) - Recomendado para dispositivos modernos
- **arm** (ARM 32-bit) - Dispositivos mais antigos
- **x86_64** (Intel/AMD 64-bit) - Emuladores
- **i686** (Intel/AMD 32-bit) - Emuladores antigos

## Estrutura do Projeto

```
terminal-packages-master/
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── scripts/
│   ├── properties.sh       # Configurações principais (MODIFICADO)
│   ├── generate-bootstraps.sh
│   └── build-bootstraps.sh
├── packages/               # Definições de pacotes
├── x11-packages/          # Pacotes X11
├── disabled-packages/     # Pacotes desabilitados
└── build-package.sh       # Script principal de build
```

## Configurações Importantes

### scripts/properties.sh

```bash
# Pacote do app FL_IDE
TERMUX_APP_PACKAGE="com.yato.fl_ide"

# Diretório base
TERMUX_BASE_DIR="/data/data/${TERMUX_APP_PACKAGE}/files"

# Prefix para instalação
TERMUX_PREFIX="${TERMUX_BASE_DIR}/usr"
```

## Pacotes Incluídos no Bootstrap

### Essenciais
- bash, dash
- coreutils, util-linux
- apt (gerenciador de pacotes)
- curl, wget
- tar, gzip, xz-utils, bzip2, zstd
- grep, sed, gawk
- findutils, diffutils
- procps, psmisc

### Ferramentas de Desenvolvimento
- wget, jq
- androidide-tools
- which, file
- brotli

### Editores
- nano
- ed

### Utilitários de Rede
- inetutils
- net-tools
- lsof

### Outros
- dos2unix
- patch
- unzip
- less

## Customização

### Adicionar Pacotes ao Bootstrap

```bash
./scripts/generate-bootstraps.sh --add "git,python,nodejs"
```

### Usar Repositório Customizado

```bash
./scripts/generate-bootstraps.sh --repository "https://seu-repo.com/apt/termux"
```

## Build de Pacotes Individuais

```bash
# Build de um pacote específico
./build-package.sh <nome-do-pacote>

# Exemplo
./build-package.sh git
```

## Troubleshooting

### Erro: "package not found"
Certifique-se de que o repositório está acessível e contém os pacotes necessários.

### Erro: "permission denied"
Os scripts precisam de permissão de execução:
```bash
chmod +x scripts/*.sh
chmod +x build-package.sh
```

### Erro no Android 10+
Use a flag `--android10`:
```bash
./scripts/generate-bootstraps.sh --android10
```

## Integração com FL_IDE

1. **Gere os bootstraps** usando este repositório
2. **Baixe os arquivos** `.zip` gerados
3. **Integre no FL_IDE** copiando para os assets ou baixando dinamicamente
4. **Extraia no diretório** `/data/data/com.yato.fl_ide/files/usr/`

Exemplo de código para extração:

```java
// No FL_IDE App
String bootstrapPath = "/data/data/com.yato.fl_ide/files/usr/";
// Extrair bootstrap-aarch64.zip para bootstrapPath
```

## Manutenção

### Atualizar Pacotes

Os pacotes são baixados do repositório configurado. Para atualizar:

1. Regenere os bootstraps
2. Os pacotes mais recentes serão baixados automaticamente

### Atualizar NDK/SDK

Edite `scripts/properties.sh`:

```bash
TERMUX_SDK_REVISION=9123335
TERMUX_NDK_VERSION_NUM=26
TERMUX_NDK_REVISION=b
```

## Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça commit das mudanças
4. Abra um Pull Request

## Licença

Este projeto mantém a licença original do termux-packages.

## Suporte

Para questões específicas do FL_IDE, abra uma issue neste repositório.

Para questões do Termux em geral, consulte:
- https://termux.com
- https://github.com/termux/termux-packages

## Links Úteis

- [Termux Wiki](https://wiki.termux.com/)
- [Termux Packages Original](https://github.com/termux/termux-packages)
- [AndroidIDE Fork Original](https://github.com/itsaky/terminal-packages)

---

**Versão**: FL_IDE Edition
**Baseado em**: AndroidIDE terminal-packages
**Modificado para**: com.yato.fl_ide
**Data**: Março 2026
