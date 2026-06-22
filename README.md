# Ambiente de Desenvolvimento — 2º Semestre
**SENAI · Técnico em Desenvolvimento de Sistemas**
Stack: Python + Flask + MySQL · Cenário: AliSafe / SisTrac

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
mysql --version
```
Todos devem retornar uma versão sem erro.

---

## Cenário pedagógico
Este ambiente suporta o desenvolvimento do **SisTrac**, sistema de rastreabilidade da AliSafe Indústria de Alimentos, desenvolvido ao longo dos 7 Sprints do 2º semestre.
