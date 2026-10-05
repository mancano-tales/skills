---
autor: "Tales Mançano / Ecossistema"
name: review-pr
description: Revisa Pull Requests no GitHub usando a GitHub CLI (gh) e a metodologia dual-axis (Padrões e Especificação). Extrai diff e metadados via gh CLI, avalia conformidade com a issue/plano de origem, checa governança local (AGENTS.md) e entrega parecer estruturado com link do GitHub para a decisão de merge. Use quando o usuário pedir para revisar um PR, avaliar pull requests abertos ou preparar parecer de PR antes do merge.
---

# review-pr — Revisão Estruturada de Pull Requests via GitHub CLI e Dual-Axis

Esta skill implementa o fluxo de revisão independente de Pull Requests no GitHub, combinando a extração via GitHub CLI (`gh`), a avaliação técnica em dois eixos (Padrões e Especificação) inspirada no `code-review`, a checagem de conformidade com a governança local (`AGENTS.md`) e um protocolo de handoff para que outro agente executor aplique correções antes do merge.

---

## 1. Princípios Operacionais

- **Maker vs. Checker**: O agente revisor atua com postura estritamente analítica e cética. Ele nunca altera o código na mesma etapa em que revisa.
- **Autoridade Final e Governança**: o agente revisa e emite o parecer; **quem pode mergear é o que o `AGENTS.md` do repositório define**. No ecossistema do autor, o agente mergeia quando o autor pede no chat, ou com checks verdes e revisão de outro harness sem achado bloqueante. **Quem escreveu o PR não o revisa** (PR do Claude é revisado pelo Codex, e vice-versa).
- **Agilidade e Rastreabilidade**: Uso intensivo da GitHub CLI (`gh`) para dispensar navegação manual na interface web, garantindo links diretos, diffs precisos e histórico auditável.

---

## 2. Parâmetros e Resolução do Alvo

A skill aceita:
1. **Número do PR** (ex.: `32`, `#32`) ou URL do PR no GitHub.
2. **Repositório** (opcional via `--repo <dono/repo>`). Se omitido, opera sobre o repositório git do diretório atual.

### Resolução Automática:
Se nenhum PR for especificado na chamada:
```bash
gh pr list --limit 10
```
- Se houver apenas 1 PR aberto, seleciona-o automaticamente informando o usuário.
- Se houver múltiplos PRs abertos, exibe a tabela resumida (Número, Título, Branch, Autor) e solicita confirmação de qual PR deve ser revisado.

---

## 3. Fluxo de Execução

### Passo 1: Extração de Metadados e Link via `gh`

Execute a consulta de metadados estruturados:
```bash
gh pr view <numero> --json number,title,url,body,baseRefName,headRefName,author,createdAt,commits,files
```

Identifique:
- **URL Direta**: Link clicável no formato `https://github.com/<dono>/<repo>/pull/<numero>`.
- **Branch Base vs. Head**: Base (ex.: `main`) e Head (ex.: `feat/...` ou `claude/...`).
- **Especificação / Contexto de Origem**: Busque referências na descrição (`body`) e nos commits:
  - Issues vinculadas: `refs #<id>`, `Closes #<id>`, `Fixes #<id>`.
  - Planos (opcionais em boa parte dos repositórios): na pasta declarada no `AGENTS.md` (chave `diretorio_governanca`; por exemplo `repo-governance/plan/` ou `docs/plans/`).
  - Se houver issue associada, consulte seu conteúdo com `gh issue view <id>`.

---

### Passo 2: Extração e Inspeção do Diff

Obtenha o diff completo das mudanças propostas:
```bash
gh pr diff <numero>
```
E o log conciso de commits:
```bash
gh pr view <numero> --json commits --jq '.commits[] | "\(.oid[0:7]) \(.messageHeadline)"'
```

Verifique:
- Número de arquivos alterados e linhas modificadas (`+` / `-`).
- Lista de arquivos afetados (identificando se tocou em governança, código, testes, documentação ou dados).

---

### Passo 3: Avaliação em Dois Eixos (Metodologia `code-review`)

A análise deve ser conduzida separando estritamente os dois eixos para evitar que conformidade técnica mascare desvios de escopo (ou vice-versa):

#### Eixo A: Padrões e Qualidade Técnica (Standards)
1. **Padrões do Repositório**:
   - Respeita as diretrizes em `CODING_STANDARDS.md`, `AGENTS.md` ou convenções da linguagem (R, Python, Shell, etc.)?
   - Os commits seguem Conventional Commits (se adotado no repositório)?
2. **Regras Invioláveis de Governança Local**:
   - **Caminhos absolutos**: Proibição estrita de caminhos absolutos de máquina (ex.: `C:/Users/...`, `.../MancanoSync/...`). Apenas caminhos relativos ou variáveis de ambiente/configuração.
   - **Registro**: commits em Conventional Commits, com o trailer `Agent:` e `refs #N` quando houver issue. Se o `AGENTS.md` do repositório ainda exigir `NEWS.md`, ele foi atualizado no mesmo commit? Onde o `NEWS.md` foi aposentado, o PR não pode criá-lo nem editá-lo.
   - **Staging cirúrgico**: Nenhum arquivo temporário, log desnecessário ou arquivo de sistema (`desktop.ini`, `.DS_Store`) introduzido.
3. **Smell Baseline (Heurísticas de Qualidade)**:
   - *Mysterious Name*: nomes de funções, variáveis ou arquivos que não revelam intenção.
   - *Duplicated Code*: lógica duplicada que deveria ser extraída.
   - *Feature Envy / Tight Coupling*: acoplamento desnecessário entre módulos.
   - *Primitive Obsession*: uso inadequado de primitivos soltos onde tipos estruturados caberiam.
   - *Scope Creep / Speculative Generality*: abstrações e parâmetros criados sem necessidade prática atual.

#### Eixo B: Especificação e Escopo (Spec)
1. **Requisitos Atendidos**:
   - A alteração entrega tudo o que a issue ou o plano de origem solicitaram?
2. **Requisitos Faltantes ou Incompletos**:
   - O que foi prometido na issue/plano mas ficou de fora do PR?
3. **Escopo Não Solicitado (Scope Creep)**:
   - Foram feitas alterações em arquivos alheios ao escopo do plano/issue?
   - Houve refatorações oportunistas ou "melhorias cosméticas" não combinadas?

---

### Passo 4: Estrutura do Parecer de Revisão

Apresente o resultado no seguinte formato padronizado:

```markdown
# Parecer de Revisão: PR #[Número] — [Título]

- **Link no GitHub**: [Acessar PR #[Número]](https://github.com/<owner>/<repo>/pull/<numero>)
- **Branch**: `[headRefName]` → `[baseRefName]`
- **Autor**: @[author]
- **Especificação de Origem**: Issue #[ID] / Plano [Nome_do_Plano]

---

## 1. Resumo das Alterações
[Síntese em 2 a 4 frases do que o PR faz tecnicamente e quais arquivos principais foram alterados.]

---

## 2. Avaliação por Eixos

### Eixo A: Padrões e Governança (Standards)
| Arquivo | Item / Linha | Tipo (Violação / Sugestão) | Descrição |
|---|---|---|---|
| `...` | L.. | ... | ... |

*(Se nenhum problema for detectado: "Em conformidade com os padrões e regras de governança.")*

### Eixo B: Especificação e Escopo (Spec)
| Requisito da Origem | Status no PR | Observação |
|---|---|---|
| [Requisito 1] | Atendido / Parcial / Ausente | ... |
| [Item fora de escopo] | Desvio de escopo | ... |

---

## 3. Recomendação Final

- [ ] **APTO PARA MERGE**: Alteração íntegra, testada, sem desvios de escopo e em conformidade com as regras de governança.
- [ ] **REQUER AJUSTES**: Pendências identificadas que devem ser corrigidas antes do merge.

### Próximos Passos Sugeridos:
- Se aprovado: o merge segue a autorização do `AGENTS.md` (autor no chat, ou checks verdes e revisão de outro harness sem achado bloqueante), via web ou `gh pr merge <numero>`.
- Se ajustes necessários: Repassar o bloco de diretrizes abaixo para o agente executor na branch.
```

---

## 4. Protocolo de Handoff para Correção por Outro Agente

Caso o PR exija ajustes, a skill deve gerar um bloco de instruções pronto para ser passado ao agente executor (no terminal, Claude Code, Codex ou Antigravity):

```markdown
### 📋 Tarefa de Correção para Agente Executor:
1. Mude para a branch do PR:
   `git checkout <headRefName>`
2. Aplique estritamente as seguintes correções pontuais:
   - [Item 1 detalhado com arquivo e linha]
   - [Item 2 detalhado com arquivo e linha]
3. Valide a integridade do código e governança:
   - Nenhum caminho absoluto introduzido.
   - `git diff` limpo e cirúrgico.
4. Faça o commit e envie para a branch remota:
   `git add <arquivos>`
   `git commit -m "fix(escopo): descrição da correção refs #<issue>"`
   `git push origin <headRefName>`
```

---

## 5. Publicação de Comentário no GitHub (Opcional)

Se o usuário solicitar registrar o feedback no GitHub:
```bash
gh pr review <numero> --comment -b "<conteúdo resumido do parecer>"
```

> **Lembrete de Governança**: esta skill só revisa. Mergear é outra etapa, que segue a autorização do `AGENTS.md` do repositório; na dúvida, pergunte ao autor.
