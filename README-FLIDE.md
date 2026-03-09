# FL IDE — Termux Fork (com.yato.fl_ide)

Este repositório é uma versão modificada do termux-packages configurada para o app **FL IDE** com package name `com.yato.fl_ide`.

## Como gerar o bootstrap no WSL2

### Pré-requisitos
- WSL2 com Ubuntu 20.04+ instalado no Windows
- Conexão com a internet (vai baixar ~100-300MB por arquitetura)

### Passos

1. **Abra o WSL2** (Ubuntu) no Windows
2. **Copie esta pasta** para dentro do WSL (ex: `~/fl-ide-packages`)
3. **Execute:**
   ```bash
   cd ~/fl-ide-packages
   chmod +x build-flide-bootstrap.sh
   ./build-flide-bootstrap.sh
   ```
4. **Aguarde.** O script vai instalar dependências e baixar os pacotes automaticamente.
5. O resultado será `bootstrap-aarch64.zip` (e outros se configurado).

### Configurar arquiteturas

Edite o arquivo `build-flide-bootstrap.sh` e altere a linha:
```bash
ARCHITECTURES="aarch64"
```
Para gerar mais arquiteturas:
```bash
ARCHITECTURES="aarch64,arm,i686,x86_64"
```

### Pacotes padrão incluídos

O bootstrap já inclui `git` e `adb` por padrão além dos pacotes essenciais do Termux.

Para adicionar mais pacotes:
```bash
EXTRA_PACKAGES="git,adb,python,nodejs"
```

## Modificações feitas

| Arquivo | O que foi modificado |
|---------|----------------------|
| `scripts/properties.sh` | Package name `com.termux` → `com.yato.fl_ide` |
| `repo.json` | Nome do repositório principal |
| `build-flide-bootstrap.sh` | Script de build para WSL |

## Usando o bootstrap no app Android

Após gerar, coloque os `bootstrap-*.zip` em:
```
app/src/main/assets/bootstrap-aarch64.zip
```

No código Java/Kotlin do app, atualize `TermuxConstants.java`:
```java
public static final String TERMUX_APP_PACKAGE_NAME = "com.yato.fl_ide";
```

## Hospedar pacotes customizados (grátis)

Veja o guia completo em `FL_IDE_Termux_Guide.docx`.
