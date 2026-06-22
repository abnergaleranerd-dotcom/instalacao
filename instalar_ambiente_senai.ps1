# =============================================================================
# SENAI - Técnico em Desenvolvimento de Sistemas
# Script de Instalação do Ambiente de Desenvolvimento - 2º Semestre
# =============================================================================

$ErrorActionPreference = "Continue"
$totalErros = 0

# ─────────────────────────────────────────────
# BYPASS SSL (resolve proxy escolar/corporativo)
# Deve ser a primeira coisa do script
# ─────────────────────────────────────────────
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

function Escrever-Cabecalho {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  SENAI - Instalacao do Ambiente - 2 Semestre               " -ForegroundColor Cyan
    Write-Host "  Tecnico em Desenvolvimento de Sistemas                     " -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Escrever-Etapa {
    param([string]$mensagem)
    Write-Host ""
    Write-Host ">> $mensagem" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
}

function Instalar-Choco {
    param([string]$pacote, [string]$nome)
    Write-Host "   Instalando $nome..." -NoNewline
    choco install $pacote -y --no-progress --ignore-checksums 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALHOU (codigo: $LASTEXITCODE)" -ForegroundColor Red
        $script:totalErros++
    }
}

function Instalar-Pip {
    param([string]$pacote)
    Write-Host "   pip install $pacote..." -NoNewline
    pip install $pacote --quiet --trusted-host pypi.org --trusted-host files.pythonhosted.org 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALHOU" -ForegroundColor Red
        $script:totalErros++
    }
}

function Instalar-VsCodeExtensao {
    param([string]$extensao, [string]$nome)
    Write-Host "   Extensao: $nome..." -NoNewline
    code --install-extension $extensao --force 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALHOU" -ForegroundColor Red
        $script:totalErros++
    }
}

# ─────────────────────────────────────────────
# VERIFICACAO INICIAL
# ─────────────────────────────────────────────
Escrever-Cabecalho

Escrever-Etapa "Verificando pre-requisitos"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "   ERRO: Execute como ADMINISTRADOR." -ForegroundColor Red
    exit 1
}
Write-Host "   Executando como Administrador: OK" -ForegroundColor Green
Write-Host "   Bypass SSL ativo: OK" -ForegroundColor Green

# ─────────────────────────────────────────────
# 1. CHOCOLATEY
# ─────────────────────────────────────────────
Escrever-Etapa "1. Instalando Chocolatey"

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "   Instalando Chocolatey..." -NoNewline
    Set-ExecutionPolicy Bypass -Scope Process -Force
    $installScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
    Invoke-Expression $installScript
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host "   Chocolatey ja instalado: OK" -ForegroundColor Green
}

choco feature enable -n allowGlobalConfirmation 2>&1 | Out-Null

# ─────────────────────────────────────────────
# 2. IDEs e EDITORES
# ─────────────────────────────────────────────
Escrever-Etapa "2. IDEs e Editores"

Instalar-Choco "vscode"             "Visual Studio Code"
Instalar-Choco "pycharm-community"  "PyCharm Community"
Instalar-Choco "notepadplusplus"    "Notepad++"

Write-Host "   Google Antigravity..." -NoNewline
Write-Host " Download manual: https://antigravity.google/download" -ForegroundColor Cyan

# ─────────────────────────────────────────────
# 3. CONTROLE DE VERSAO
# ─────────────────────────────────────────────
Escrever-Etapa "3. Controle de Versao"

Instalar-Choco "git"             "Git"
Instalar-Choco "github-desktop"  "GitHub Desktop"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "   Configurando Git (encoding)..." -NoNewline
git config --global core.autocrlf true
git config --global core.encoding utf-8
Write-Host " OK" -ForegroundColor Green

# ─────────────────────────────────────────────
# 4. LINGUAGENS E RUNTIMES
# ─────────────────────────────────────────────
Escrever-Etapa "4. Linguagens e Runtimes"

Instalar-Choco "python312"  "Python 3.12"
Instalar-Choco "temurin21"  "Java JDK 21"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ─────────────────────────────────────────────
# 5. PACOTES PYTHON (pip)
# ─────────────────────────────────────────────
Escrever-Etapa "5. Pacotes Python (pip)"

Write-Host "   Atualizando pip..." -NoNewline
python -m pip install --upgrade pip --quiet --trusted-host pypi.org --trusted-host files.pythonhosted.org 2>&1 | Out-Null
Write-Host " OK" -ForegroundColor Green

Instalar-Pip "flask"
Instalar-Pip "mysql-connector-python"
Instalar-Pip "python-dotenv"

# ─────────────────────────────────────────────
# 6. BANCO DE DADOS
# ─────────────────────────────────────────────
Escrever-Etapa "6. Banco de Dados"

Instalar-Choco "mysql"           "MySQL Server"
Instalar-Choco "mysql.workbench" "MySQL Workbench"

Escrever-Etapa "6.1 Configurando MySQL (root / senai105)"

Write-Host "   Aguardando servico MySQL..." -NoNewline
$tentativas = 0
do {
    Start-Sleep -Seconds 3
    $tentativas++
    $servico = Get-Service -Name "MySQL*" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Running" }
} while (-not $servico -and $tentativas -lt 10)
Write-Host " OK" -ForegroundColor Green

$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin",
    "C:\Program Files\MySQL\MySQL Server 9.0\bin",
    "C:\tools\mysql\current\bin"
)
$mysqlBin = $null
foreach ($p in $mysqlPaths) {
    if (Test-Path "$p\mysql.exe") { $mysqlBin = $p; break }
}
if (-not $mysqlBin) {
    $mysqlExe = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($mysqlExe) { $mysqlBin = Split-Path $mysqlExe.Source }
}

if ($mysqlBin) {
    $env:Path = "$mysqlBin;" + $env:Path
    Write-Host "   Definindo senha root como 'senai105'..." -NoNewline
    "ALTER USER 'root'@'localhost' IDENTIFIED BY 'senai105'; FLUSH PRIVILEGES;" | & "$mysqlBin\mysql.exe" -u root --connect-expired-password 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALHOU - configure manualmente no Workbench" -ForegroundColor Red
        $totalErros++
    }
    $pathAtual = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    if ($pathAtual -notlike "*$mysqlBin*") {
        [System.Environment]::SetEnvironmentVariable("Path","$pathAtual;$mysqlBin","Machine")
    }
} else {
    Write-Host "   MySQL nao localizado - configure manualmente." -ForegroundColor Yellow
    $totalErros++
}

# ─────────────────────────────────────────────
# 7. FERRAMENTAS DE API
# ─────────────────────────────────────────────
Escrever-Etapa "7. Ferramentas de API e Modelagem"

Instalar-Choco "bruno" "Bruno API Client"

Write-Host "   BR-Modelo: https://www.brmodeloweb.com" -ForegroundColor Cyan
Write-Host "   Figma:     https://figma.com"           -ForegroundColor Cyan

# ─────────────────────────────────────────────
# 8. AMBIENTE E VIRTUALIZACAO
# ─────────────────────────────────────────────
Escrever-Etapa "8. Ambiente e Virtualizacao"

Write-Host "   Habilitando WSL + Ubuntu..." -NoNewline
try {
    wsl --install -d Ubuntu --no-launch 2>&1 | Out-Null
    Write-Host " OK (reinicialize o PC apos o script)" -ForegroundColor Green
} catch {
    Write-Host " FALHOU" -ForegroundColor Red; $totalErros++
}

Instalar-Choco "virtualbox" "VirtualBox"

# ─────────────────────────────────────────────
# 9. ANALISE DE DADOS
# ─────────────────────────────────────────────
Escrever-Etapa "9. Analise de Dados"

Instalar-Choco "powerbi" "Power BI Desktop"

# ─────────────────────────────────────────────
# 10. EXTENSOES DO VS CODE
# ─────────────────────────────────────────────
Escrever-Etapa "10. Extensoes do Visual Studio Code"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (Get-Command code -ErrorAction SilentlyContinue) {
    Instalar-VsCodeExtensao "ms-python.python"      "Python (Microsoft)"
    Instalar-VsCodeExtensao "ritwickdey.LiveServer" "Live Server"
    Instalar-VsCodeExtensao "qwtel.sqlite-viewer"   "SQLite Viewer"
} else {
    Write-Host "   Reinicie o PC e instale as extensoes manualmente." -ForegroundColor Yellow
}

# ─────────────────────────────────────────────
# 11. VERIFICACAO FINAL
# ─────────────────────────────────────────────
Escrever-Etapa "11. Verificacao Final"

foreach ($check in @(
    @{ cmd="python --version";                 nome="Python"           },
    @{ cmd="pip show flask";                   nome="Flask"            },
    @{ cmd="pip show mysql-connector-python";  nome="mysql-connector"  },
    @{ cmd="git --version";                    nome="Git"              },
    @{ cmd="java --version";                   nome="Java JDK"         },
    @{ cmd="mysql --version";                  nome="MySQL (cli)"      }
)) {
    Write-Host "   $($check.nome)..." -NoNewline
    try {
        $s = Invoke-Expression $check.cmd 2>&1
        if ($LASTEXITCODE -eq 0 -or $s) { Write-Host " OK" -ForegroundColor Green }
        else { Write-Host " NAO ENCONTRADO" -ForegroundColor Yellow }
    } catch { Write-Host " NAO ENCONTRADO" -ForegroundColor Yellow }
}

Write-Host "   MySQL conexao (root/senai105)..." -NoNewline
try {
    $t = "SELECT 'OK';" | mysql -u root -psenai105 --silent 2>&1
    if ($t -like "*OK*") { Write-Host " OK" -ForegroundColor Green }
    else { Write-Host " FALHOU" -ForegroundColor Red }
} catch { Write-Host " NAO TESTADO" -ForegroundColor Yellow }

# ─────────────────────────────────────────────
# RESUMO
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
if ($totalErros -eq 0) {
    Write-Host "  Instalacao concluida sem erros!" -ForegroundColor Green
} else {
    Write-Host "  Instalacao concluida com $totalErros erro(s)." -ForegroundColor Yellow
    Write-Host "  Verifique os itens FALHOU acima." -ForegroundColor Yellow
}
Write-Host "  REINICIE o computador antes de usar." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Proximos passos (cada aluno):" -ForegroundColor White
Write-Host "  1. Reiniciar o computador" -ForegroundColor White
Write-Host "  2. git config --global user.name  'Seu Nome'" -ForegroundColor DarkGray
Write-Host "  3. git config --global user.email 'seu@email.com'" -ForegroundColor DarkGray
Write-Host "  4. Criar conta: https://github.com" -ForegroundColor White
Write-Host "  5. Baixar Antigravity: https://antigravity.google/download" -ForegroundColor White
Write-Host ""
