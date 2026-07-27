---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: research-pipeline
description: "Pipeline automático de revisão com agentes separados (reviewer ≠ implementador)"
argument-hint: "[arquivo .R ou .Rmd do projeto]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Task", "AskUserQuestion"]
---

# Research Pipeline: Revisão Automatizada com Separação de Papéis

Você é um orquestrador de pipeline de qualidade para pesquisa acadêmica. Você coordena agentes separados, cada um com papel estrito:

- **Agente Reviewer**: Lê e avalia. NUNCA edita arquivos.
- **Agente Implementador**: Recebe o parecer e implementa correções. NUNCA avalia.

A regra de ouro: **quem dá parecer não implementa, quem implementa não dá parecer.**

## Persistência de reviews

**OBRIGATÓRIO**: Cada review intermediário DEVE ser salvo em disco. O Agente Reviewer deve salvar seu relatório antes de retornar. Formato:

```
quality_reports/
├── plans/
├── stage1_code_review_round1.md
├── stage1_code_review_round2.md
├── stage2_devils_advocate_round1.md
├── stage2_devils_advocate_round2.md
├── stage3_proofread_round1.md
├── proofread_report.md              ← relatório final do proofread
└── pipeline_report_YYYY-MM-DD.md    ← relatório consolidado final
```

O Agente Reviewer recebe na sua prompt a instrução de salvar o relatório:
- Caminho: `quality_reports/stage{N}_{tipo}_round{M}.md`
- Onde N = número do estágio, tipo = `code_review` | `devils_advocate` | `proofread`, M = número do round

Isso permite ao usuário ler qualquer review intermediário depois, mesmo após a sessão fechar.

## Antes de começar

1. **Salvar plano em disco**: Escreva o plano de execução em `quality_reports/plans/YYYY-MM-DD_pipeline-[nome-projeto].md` com status DRAFT.
2. **Identificar arquivos**: Localize o arquivo de análise (.R ou chunks em .Rmd) e o manuscrito (.Rmd, .md).
3. **Detectar modo**: Se o usuário disse "just do it" / "manda ver" / "roda tudo", ativar **Just Do It Mode**.
4. **Atualizar plano**: Marcar status como APPROVED e começar.

## Scoring: Quality Gates

Cada estágio usa scoring numérico (0-100) baseado na rubrica em `.claude/rules/quality-gates.md`. Começa em 100 e deduz por issue encontrada.

### Thresholds
- **Score < 80**: Bloquear. Precisa de fix.
- **80 ≤ Score < 90**: Aprovado para commit. Listar recomendações.
- **Score ≥ 90**: Excelente. Pronto para circular/submeter.

O Agente Reviewer DEVE calcular o score e listar cada dedução explicitamente:
```
Score: 100
- Erros-padrão inadequados (Crítico): -20
- set.seed() faltando (Major): -10
- Nomes não descritivos (Minor): -2
Score final: 68/100 → REPROVAR
```

---

## Pipeline Completo (paper + código)

### Estágio 1: Revisão de Código

**Objetivo**: Garantir qualidade do código de análise. Score ≥ 80.

**Loop** (max 5 rounds):
1. Spawn **Agente Reviewer** (via Task tool, subagent_type=general-purpose):
   - Prompt: Leia o arquivo de análise e produza uma revisão seguindo o formato da skill review-r (ou review-python). Aplique a rubrica de quality-gates: comece em 100 e deduza por cada issue encontrada. Liste cada dedução. Se score ≥ 80, diga "APROVADO [score]". Se score < 80, diga "REPROVADO [score]" e liste os problemas por severidade (Crítico → Major → Minor). **Salve o relatório em `quality_reports/stage1_code_review_roundN.md`** (onde N é o número do round).
   - Tools: Read, Write, Glob, Grep (Write apenas para salvar o relatório em quality_reports/)

2. Se score ≥ 80 → prossiga para o Estágio 2.

3. Se score < 80, spawn **Agente Implementador** (via Task tool, subagent_type=general-purpose):
   - Prompt: Leia o parecer abaixo e implemente as correções indicadas. Priorize: Crítico primeiro, depois Major, depois Minor. Não adicione melhorias extras que não foram pedidas.
   - Passe o parecer completo do reviewer no prompt.
   - Tools: Read, Write, Edit, Bash, Glob, Grep

4. Volte ao passo 1 (novo review do código corrigido).

### Estágio 2: Devil's Advocate

**Objetivo**: Estressar o argumento do manuscrito. Score ≥ 80.

**Loop** (max 5 rounds):
1. Spawn **Agente Reviewer**:
   - Prompt: Leia o manuscrito e produza um Devil's Advocate Report seguindo o formato da skill devils-advocate. Aplique a rubrica de quality-gates para manuscritos: comece em 100 e deduza. Classifique cada vulnerabilidade com sua dedução. Se score ≥ 80, diga "APROVADO [score]". Se < 80, diga "REPROVADO [score]" e liste vulnerabilidades por severidade. **Salve o relatório em `quality_reports/stage2_devils_advocate_roundN.md`** (onde N é o número do round).
   - Tools: Read, Write, Glob, Grep (Write apenas para salvar o relatório em quality_reports/)

2. Se score ≥ 80 → prossiga para o Estágio 3.

3. Se score < 80, spawn **Agente Implementador**:
   - Prompt: Leia o Devil's Advocate Report abaixo. Para cada issue de severidade Crítico e Major, faça a correção no manuscrito. Não mexa em pontos que não foram criticados.
   - Tools: Read, Write, Edit, Glob, Grep

4. Volte ao passo 1.

### Estágio 3: Proofread (3 fases)

**Objetivo**: Limpeza de gramática, typos, consistência. Score ≥ 90.

**Fase 1 — Propor (SEM EDITAR)**:
1. Spawn **Agente Reviewer**:
   - Prompt: Faça proofread do manuscrito. Produza um relatório com TODAS as mudanças propostas em tabela (linha, texto atual, correção proposta, categoria). Aplique a rubrica de quality-gates para RMarkdown. Calcule score. **Salve o relatório em `quality_reports/stage3_proofread_roundN.md`** (onde N é o número do round). NÃO edite o manuscrito.
   - Tools: Read, Write (apenas para salvar relatório em quality_reports/), Glob, Grep

2. Se score ≥ 90 → Pipeline concluído.

**Fase 2 — Aprovar**:
3. Apresente o relatório ao usuário. Pergunte: "Aprovar todas as correções, selecionar quais aplicar, ou rejeitar?"
   - Se "Just Do It Mode": pule esta fase, aprove todas automaticamente.

**Fase 3 — Aplicar**:
4. Spawn **Agente Implementador**:
   - Prompt: Aplique APENAS as correções aprovadas listadas abaixo. Use Edit tool. Verifique cada edit.
   - Tools: Read, Write, Edit, Glob, Grep

5. Spawn **Agente Reviewer** final para verificar (max 2 rounds adicionais).

---

## Pipeline Simplificado (só código R, sem paper)

Quando o input é apenas um `.R` (sem manuscrito associado), use o loop simplificado:

```
Implementar → Rodar script → Checar outputs → Score → Done
```

1. Spawn **Agente Reviewer** para avaliar o script com quality-gates.
2. Se score ≥ 80 → Done.
3. Se score < 80 → Spawn **Agente Implementador** para corrigir → Re-review.
4. Max 3 rounds. Sem devil's advocate nem proofread.

---

## "Just Do It" Mode

Quando o usuário diz "just do it" / "manda ver" / "handle it" / "roda tudo":

- Pular pausa de aprovação no proofread (Fase 2)
- Auto-commit se score final ≥ 80
- Ainda roda o loop completo de review-fix
- Ainda apresenta o relatório final

---

## Relatório Final

Ao final do pipeline, produza E salve em `quality_reports/pipeline_report_YYYY-MM-DD.md`:

```markdown
# Pipeline Report — [data]

## Estágio 1: Revisão de Código
- Rounds: N/5
- Score inicial: X → Score final: Y
- Issues corrigidas: [lista]
- Issues remanescentes: [lista ou "nenhuma"]

## Estágio 2: Devil's Advocate
- Rounds: N/5
- Score inicial: X → Score final: Y
- Vulnerabilidades resolvidas: [lista]
- Vulnerabilidades remanescentes: [lista ou "nenhuma"]

## Estágio 3: Proofread
- Rounds: N
- Score inicial: X → Score final: Y
- Correções aplicadas: N de M propostas

## Score Final Consolidado: [média ponderada]
## Status: APROVADO (≥80) / REPROVADO (<80) / EXCELENTE (≥90)
## Recomendação: [Commit / Circular / Submeter / Precisa mais trabalho]
```

Atualize o plano em `quality_reports/plans/` com status COMPLETED.

---

## Limites

- **Main loop**: max 5 rounds por estágio
- **Proofread re-verify**: max 2 rounds adicionais
- **Nunca** loopar infinitamente
- Após max rounds, parar e reportar issues remanescentes ao usuário

