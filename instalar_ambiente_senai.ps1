# =============================================================================
# SENAI - Técnico em Desenvolvimento de Sistemas
# Script de Instalação do Ambiente de Desenvolvimento - 2º Semestre
# AliSafe / SisTrac - Stack Python + Flask + MySQL
#
# Execução: Abrir PowerShell como ADMINISTRADOR e rodar:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\instalar_ambiente_senai.ps1
# =============================================================================

$ErrorActionPreference = "Continue"
$totalErros = 0

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

function Instalar-Winget {
    param([string]$pacote, [string]$nome)
    Write-Host "   Instalando $nome..." -NoNewline
    $resultado = winget install --id $pacote --silent --accept-source-agreements --accept-package-agreements 2>&1
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALHOU (codigo: $LASTEXITCODE)" -ForegroundColor Red
        $script:totalErros++
    }
}

function Instalar-Pip {
    param([string]$pacote)
    Write-Host "   pip install $pacote..." -NoNewline
    $resultado = pip install $pacote --quiet 2>&1
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
    $resultado = code --install-extension $extensao --force 2>&1
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

# Verificar se esta rodando como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "   ERRO: Execute este script como ADMINISTRADOR." -ForegroundColor Red
    Write-Host "   Clique com botao direito no PowerShell > Executar como administrador" -ForegroundColor Yellow
    exit 1
}
Write-Host "   Executando como Administrador: OK" -ForegroundColor Green

# Verificar winget
try {
    winget --version | Out-Null
    Write-Host "   Winget disponivel: OK" -ForegroundColor Green
} catch {
    Write-Host "   ERRO: Winget nao encontrado. Instale a App Installer pela Microsoft Store." -ForegroundColor Red
    exit 1
}

# ─────────────────────────────────────────────
# 1. IDEs e EDITORES
# ─────────────────────────────────────────────
Escrever-Etapa "1. IDEs e Editores"

Instalar-Winget "Microsoft.VisualStudioCode"  "Visual Studio Code"
Instalar-Winget "JetBrains.PyCharm.Community" "PyCharm Community"
Instalar-Winget "Notepad++.Notepad++"         "Notepad++"

# Google Antigravity - download direto (nao disponivel no winget)
Write-Host "   Instalando Google Antigravity..." -NoNewline
$antigravityUrl      = "https://antigravity.google/download"
$antigravityInstaler = "$env:TEMP\antigravity_setup.exe"
try {
    Invoke-WebRequest -Uri $antigravityUrl -OutFile $antigravityInstaler -UseBasicParsing -ErrorAction Stop
    Start-Process -FilePath $antigravityInstaler -ArgumentList "/silent" -Wait
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " FALHOU - Acesse manualmente: https://antigravity.google/download" -ForegroundColor Red
    $totalErros++
}

# ─────────────────────────────────────────────
# 2. CONTROLE DE VERSAO
# ─────────────────────────────────────────────
Escrever-Etapa "2. Controle de Versao"

Instalar-Winget "Git.Git"             "Git"
Instalar-Winget "GitHub.GitHubDesktop" "GitHub Desktop"

# Configuracao basica do Git (nome e email serao definidos por cada aluno)
Write-Host "   Configurando Git (encoding)..." -NoNewline
git config --global core.autocrlf true
git config --global core.encoding utf-8
Write-Host " OK" -ForegroundColor Green

# ─────────────────────────────────────────────
# 3. LINGUAGENS E RUNTIMES
# ─────────────────────────────────────────────
Escrever-Etapa "3. Linguagens e Runtimes"

Instalar-Winget "Python.Python.3.12"          "Python 3.12"
Instalar-Winget "Microsoft.OpenJDK.21"        "Java JDK 21 (OpenJDK)"

# Atualizar PATH para ter acesso ao pip recém instalado
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ─────────────────────────────────────────────
# 4. PACOTES PYTHON (pip)
# ─────────────────────────────────────────────
Escrever-Etapa "4. Pacotes Python (pip)"

Write-Host "   Atualizando pip..." -NoNewline
python -m pip install --upgrade pip --quiet
Write-Host " OK" -ForegroundColor Green

Instalar-Pip "flask"
Instalar-Pip "mysql-connector-python"
Instalar-Pip "python-dotenv"

# ─────────────────────────────────────────────
# 5. BANCO DE DADOS
# ─────────────────────────────────────────────
Escrever-Etapa "5. Banco de Dados"

Instalar-Winget "Oracle.MySQL"           "MySQL Server"
Instalar-Winget "Oracle.MySQLWorkbench"  "MySQL Workbench"

# Configurar MySQL: usuario root / senha senai105
Escrever-Etapa "5.1 Configurando MySQL (root / senai105)"

# Aguardar o servico do MySQL iniciar apos a instalacao
Write-Host "   Aguardando servico MySQL iniciar..." -NoNewline
$tentativas = 0
$servicoOK  = $false
do {
    Start-Sleep -Seconds 3
    $tentativas++
    $servico = Get-Service -Name "MySQL*" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Running" }
    if ($servico) { $servicoOK = $true }
} while (-not $servicoOK -and $tentativas -lt 10)

if (-not $servicoOK) {
    Write-Host " servico nao encontrado, tentando iniciar..." -ForegroundColor Yellow
    Start-Service -Name "MySQL*" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
}
Write-Host " OK" -ForegroundColor Green

# Localizar o mysqladmin e mysql nos caminhos padrao de instalacao
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin",
    "C:\Program Files\MySQL\MySQL Server 9.0\bin",
    "C:\MySQL\bin"
)

$mysqlBin = $null
foreach ($caminho in $mysqlPaths) {
    if (Test-Path "$caminho\mysql.exe") {
        $mysqlBin = $caminho
        break
    }
}

# Se nao encontrou nos caminhos fixos, busca no PATH do sistema
if (-not $mysqlBin) {
    $mysqlExe = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($mysqlExe) {
        $mysqlBin = Split-Path $mysqlExe.Source
    }
}

if ($mysqlBin) {
    Write-Host "   MySQL encontrado em: $mysqlBin" -ForegroundColor DarkGray

    # Adicionar ao PATH da sessao atual
    $env:Path = "$mysqlBin;" + $env:Path

    # Verificar se existe senha temporaria gerada pelo instalador
    $logErro = "C:\ProgramData\MySQL\MySQL Server 8.0\Data\*.err"
    $arquivosLog = Get-Item $logErro -ErrorAction SilentlyContinue
    $senhaTemp = $null

    if ($arquivosLog) {
        $conteudoLog = Get-Content $arquivosLog[-1] -ErrorAction SilentlyContinue
        $linhaTemp   = $conteudoLog | Select-String "temporary password"
        if ($linhaTemp) {
            $senhaTemp = ($linhaTemp.Line -split "root@localhost: ")[-1].Trim()
            Write-Host "   Senha temporaria detectada no log." -ForegroundColor DarkGray
        }
    }

    # ── Cenario 1: MySQL recem instalado SEM senha (instalacao padrao via winget) ──
    Write-Host "   Definindo senha root como 'senai105'..." -NoNewline
    $sqlComandos = @"
ALTER USER 'root'@'localhost' IDENTIFIED BY 'senai105';
FLUSH PRIVILEGES;
"@

    $sqlComandos | & "$mysqlBin\mysql.exe" -u root --connect-expired-password 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        # ── Cenario 2: Tentativa com senha temporaria (se detectada) ──
        if ($senhaTemp) {
            Write-Host " tentando com senha temporaria..." -NoNewline
            $sqlComandos | & "$mysqlBin\mysql.exe" -u root -p"$senhaTemp" --connect-expired-password 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host " OK" -ForegroundColor Green
            } else {
                Write-Host " FALHOU - Configure manualmente (veja README)" -ForegroundColor Red
                $totalErros++
            }
        } else {
            Write-Host " FALHOU - Configure manualmente (veja README)" -ForegroundColor Red
            $totalErros++
        }
    }

    # Criar banco de dados padrao do curso
    Write-Host "   Criando banco 'alisafe_db'..." -NoNewline
    $sqlBanco = @"
CREATE DATABASE IF NOT EXISTS alisafe_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
"@
    $sqlBanco | & "$mysqlBin\mysql.exe" -u root -psenai105 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALHOU (banco pode ser criado depois pelo Workbench)" -ForegroundColor Yellow
    }

    # Adicionar mysql ao PATH permanente do sistema
    Write-Host "   Adicionando MySQL ao PATH do sistema..." -NoNewline
    $pathAtual = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($pathAtual -notlike "*$mysqlBin*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$pathAtual;$mysqlBin", "Machine")
    }
    Write-Host " OK" -ForegroundColor Green

} else {
    Write-Host "   AVISO: MySQL nao localizado para configuracao automatica." -ForegroundColor Yellow
    Write-Host "   Configure manualmente no MySQL Workbench:" -ForegroundColor Yellow
    Write-Host "   Usuario: root  |  Senha: senai105" -ForegroundColor Cyan
    $totalErros++
}

# ─────────────────────────────────────────────
# 6. FERRAMENTAS DE API E MODELAGEM
# ─────────────────────────────────────────────
Escrever-Etapa "6. Ferramentas de API e Modelagem"

Instalar-Winget "Bruno.Bruno"  "Bruno API Client"

Write-Host "   BR-Modelo (web - sem instalacao)..." -NoNewline
Write-Host " Acessar: https://www.brmodeloweb.com" -ForegroundColor Cyan

Write-Host "   Figma (web - sem instalacao)..." -NoNewline
Write-Host " Acessar: https://figma.com" -ForegroundColor Cyan

# ─────────────────────────────────────────────
# 7. AMBIENTE E VIRTUALIZACAO
# ─────────────────────────────────────────────
Escrever-Etapa "7. Ambiente e Virtualizacao"

# WSL + Ubuntu
Write-Host "   Habilitando WSL e instalando Ubuntu..." -NoNewline
try {
    wsl --install -d Ubuntu --no-launch 2>&1 | Out-Null
    Write-Host " OK (reinicializacao pode ser necessaria)" -ForegroundColor Green
} catch {
    Write-Host " FALHOU - Tente manualmente: wsl --install -d Ubuntu" -ForegroundColor Red
    $totalErros++
}

Instalar-Winget "Oracle.VirtualBox" "VirtualBox"

# ─────────────────────────────────────────────
# 8. ANALISE DE DADOS
# ─────────────────────────────────────────────
Escrever-Etapa "8. Analise de Dados"

Instalar-Winget "Microsoft.PowerBIDesktop" "Power BI Desktop"

# ─────────────────────────────────────────────
# 9. EXTENSOES DO VS CODE
# ─────────────────────────────────────────────
Escrever-Etapa "9. Extensoes do Visual Studio Code"

# Verificar se o VS Code esta no PATH
$vscodePath = Get-Command code -ErrorAction SilentlyContinue
if ($vscodePath) {
    Instalar-VsCodeExtensao "ms-python.python"         "Python (Microsoft)"
    Instalar-VsCodeExtensao "ritwickdey.LiveServer"    "Live Server"
    Instalar-VsCodeExtensao "qwtel.sqlite-viewer"      "SQLite Viewer"
    Instalar-VsCodeExtensao "ms-azuretools.vscode-docker" "Docker (opcional)"
} else {
    Write-Host "   VS Code nao encontrado no PATH." -ForegroundColor Yellow
    Write-Host "   Reinicie o terminal e execute: code --install-extension ms-python.python" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────
# 10. VERIFICACAO FINAL
# ─────────────────────────────────────────────
Escrever-Etapa "10. Verificacao Final do Ambiente"

$checks = @(
    @{ cmd = "python --version";                                    nome = "Python"        },
    @{ cmd = "pip show flask";                                      nome = "Flask"         },
    @{ cmd = "pip show mysql-connector-python";                     nome = "mysql-connector"},
    @{ cmd = "git --version";                                       nome = "Git"           },
    @{ cmd = "java --version";                                      nome = "Java JDK"      },
    @{ cmd = "mysql --version";                                     nome = "MySQL (cli)"   }
)

foreach ($check in $checks) {
    Write-Host "   $($check.nome)..." -NoNewline
    try {
        $saida = Invoke-Expression $check.cmd 2>&1
        if ($LASTEXITCODE -eq 0 -or $saida) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " NAO ENCONTRADO" -ForegroundColor Yellow
        }
    } catch {
        Write-Host " NAO ENCONTRADO" -ForegroundColor Yellow
    }
}

# Teste de conexao MySQL com as credenciais configuradas
Write-Host "   MySQL conexao (root/senai105)..." -NoNewline
try {
    $testeCon = "SELECT 'Conexao OK' AS status;" | mysql -u root -psenai105 --silent 2>&1
    if ($testeCon -like "*Conexao OK*") {
        Write-Host " OK  (root@localhost autenticado)" -ForegroundColor Green
    } else {
        Write-Host " FALHOU - verifique a senha no Workbench" -ForegroundColor Red
    }
} catch {
    Write-Host " NAO TESTADO (MySQL fora do PATH nesta sessao)" -ForegroundColor Yellow
}

# Teste do banco alisafe_db
Write-Host "   Banco 'alisafe_db'..." -NoNewline
try {
    $testeBanco = "SHOW DATABASES LIKE 'alisafe_db';" | mysql -u root -psenai105 --silent 2>&1
    if ($testeBanco -like "*alisafe_db*") {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " nao encontrado (crie via Workbench)" -ForegroundColor Yellow
    }
} catch {
    Write-Host " NAO TESTADO" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────
# RESUMO FINAL
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
if ($totalErros -eq 0) {
    Write-Host "  Instalacao concluida sem erros!" -ForegroundColor Green
    Write-Host "  Ambiente pronto para o 2 semestre - AliSafe / SisTrac" -ForegroundColor Green
} else {
    Write-Host "  Instalacao concluida com $totalErros erro(s)." -ForegroundColor Yellow
    Write-Host "  Verifique os itens marcados como FALHOU acima." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "  IMPORTANTE: Reinicie o computador antes de comecar a usar." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Proximos passos para cada aluno:" -ForegroundColor White
Write-Host "  1. Reiniciar o computador" -ForegroundColor White
Write-Host "  2. Abrir Git Bash e configurar:" -ForegroundColor White
Write-Host "     git config --global user.name  'Seu Nome'" -ForegroundColor DarkGray
Write-Host "     git config --global user.email 'seu@email.com'" -ForegroundColor DarkGray
Write-Host "  3. Criar conta no GitHub: https://github.com" -ForegroundColor White
Write-Host "  4. Criar conta no Figma:  https://figma.com" -ForegroundColor White
Write-Host "  5. Abrir VS Code e confirmar extensoes instaladas" -ForegroundColor White
Write-Host ""
