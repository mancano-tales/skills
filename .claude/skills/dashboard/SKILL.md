---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: dashboard
description: "Visualizar e atualizar o dashboard centralizado de projetos de pesquisa"
argument-hint: "[refresh | nome-do-projeto]"
allowed-tools: ["Read", "Edit", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# Dashboard de Projetos de Pesquisa

Gerencie a visão centralizada de todos os projetos de pesquisa/consultoria DCP.

**Arquivo do dashboard**: `/Users/manoelgaldino/Documents/DCP/DASHBOARD.md`

## Modos de operação

### 1. Visão geral (sem argumentos)

Quando invocado como `/dashboard` sem argumentos:

1. Leia `/Users/manoelgaldino/Documents/DCP/DASHBOARD.md`
2. Apresente ao usuário:
   - A tabela resumo completa
   - Destaque projetos com urgência ALTA em primeiro lugar
   - Liste bloqueios ativos que impedem progresso
   - Mostre pontos de decisão pendentes (onde o usuário precisa decidir algo)
3. Ao final, informe a data da última atualização de cada projeto

### 2. Refresh (`/dashboard refresh`)

Quando invocado com argumento `refresh`:

1. Leia o dashboard atual
2. Escaneie os MEMORY.md de todos os projetos listados no dashboard:
   - Para cada projeto, busque o MEMORY.md em `~/.claude/projects/` usando o diretório do projeto como referência
   - Use Glob para encontrar: `~/.claude/projects/**/memory/MEMORY.md`
3. Compare o status no dashboard com o status no MEMORY.md de cada projeto
4. Para cada discrepância encontrada:
   - Mostre ao usuário: campo, valor no dashboard, valor no MEMORY.md
   - Proponha a atualização
5. **NÃO aplique mudanças sem aprovação explícita do usuário**
6. Após aprovação, atualize o dashboard com Edit

### 3. Detalhe de projeto (`/dashboard [nome]`)

Quando invocado com nome de um projeto (ex: `/dashboard IVB`, `/dashboard RDD-Trade`):

1. Leia o dashboard e localize a seção do projeto (busca case-insensitive e parcial)
2. Mostre a seção detalhada completa do dashboard
3. Localize e leia o MEMORY.md correspondente do projeto
4. Apresente informações complementares do MEMORY.md que não estão no dashboard:
   - Detalhes técnicos relevantes
   - Histórico recente de decisões
   - Arquivos-chave do projeto
5. Se houver discrepâncias entre dashboard e MEMORY.md, sinalize ao usuário

## Regras

- O dashboard é um **resumo** — nunca duplique todo o conteúdo do MEMORY.md
- Mantenha o formato padronizado (tabela resumo + seções detalhadas)
- Projetos de ensino, infra de agentes e pessoais ficam FORA do dashboard
- Se um projeto não for encontrado pelo nome fornecido, liste os projetos disponíveis e peça clarificação

