# Ambiente de Desenvolvimento — 2º Semestre
**SENAI · Técnico em Desenvolvimento de Sistemas**
Stack: Python + Flask + MySQL · Cenário: AliSafe / SisTrac

---

## ⚡ Instalação Rápida

Abrir o **PowerShell como Administrador** e colar:

```powershell
iex(irm 'https://is.gd/Er1XXL')
```

> Baixa e executa o script automaticamente. Reinicie o computador ao final.

---

## O que este script instala

| Categoria | Software |
|-----------|----------|
| IDEs / Editores | VS Code, PyCharm Community, Notepad++, Google Antigravity, Google Antigravity IDE |
| Controle de Versão | Git, GitHub Desktop |
| Linguagens | Python 3.12, Java JDK 21 |
| Pacotes Python | Flask, mysql-connector-python, python-dotenv |
| Banco de Dados | MySQL Server, MySQL Workbench |
| Ferramentas de API | Bruno API Client |
| Ambiente / Virtualização | WSL + Ubuntu, VirtualBox |
| Análise de Dados | Power BI Desktop |
| Extensões VS Code | Python, Live Server, SQLite Viewer |
| Web (sem instalação) | BR-Modelo, Figma |

---

## Credenciais do MySQL (configuradas automaticamente)

| Campo    | Valor      |
|----------|------------|
| Usuário  | `root`     |
| Senha    | `senai105` |
| Host     | `localhost`|
| Porta    | `3306`     |

> **String de conexão Flask:**
> ```python
> app.config['MYSQL_HOST']     = 'localhost'
> app.config['MYSQL_USER']     = 'root'
> app.config['MYSQL_PASSWORD'] = 'senai105'
> ```

### Configuração manual (se o script falhar no MySQL)

Abrir o **MySQL Workbench**, conectar com usuário `root` sem senha e rodar:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'senai105';
FLUSH PRIVILEGES;
```

---

## Como executar

1. Abrir o **PowerShell como Administrador**
2. Navegar até a pasta do script:
   ```
   cd C:\caminho\para\instalacao
   ```
3. Liberar execução de scripts:
   ```
   Set-ExecutionPolicy Bypass -Scope Process -Force
   ```
4. Rodar o script:
   ```
   .\instalar_ambiente_senai.ps1
   ```
5. **Reiniciar o computador** ao final.

---

## Após a instalação — configuração individual (cada aluno)

```bash
git config --global user.name  "Seu Nome"
git config --global user.email "seu@email.com"
```

Criar contas em:
- GitHub: https://github.com
- Figma: https://figma.com
- Google (necessário para Antigravity): https://accounts.google.com

---

## Verificação rápida do ambiente

Abrir o **terminal** e rodar:
```
python --version
pip show flask
git --version
java --version
mysql -u root -psenai105 -e "SELECT 'Conexao OK';"
```
Todos devem retornar uma versão ou resultado sem erro.

---

## Cenário pedagógico
Este ambiente suporta o desenvolvimento do **SisTrac**, sistema de rastreabilidade da AliSafe Indústria de Alimentos, desenvolvido ao longo dos 7 Sprints do 2º semestre.
