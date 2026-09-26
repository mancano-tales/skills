---
autor: "Tales Mançano / Ecossistema"
name: export-conversation
description: DESCONTINUADA em 2026-09-26 — não use. O exportador de conversas foi desativado em todo o ecossistema por decisão do autor; o registro de uma sessão é o NEWS.md, o plano, a issue e o git log.
---

# (Descontinuada) Exportar conversa

**Esta skill foi descontinuada em 2026-09-26**, por decisão do autor: "quero desabilitar o exportador de conversas em todos os meus repositórios". Plano no hub: `repo-governance/plan/2026-09-26_Plano_Descontinuar_Exportador_Conversas.md`.

- **Não exporte sessões** para `llm-reviews/`. O script `tools/export_conversa.R` recusa rodar.
- **O registro de uma sessão** é a entrada no `NEWS.md`, o plano, a issue e o `git log`.
- **Os exports antigos** em `llm-reviews/` ficam como histórico. Não apague nem reescreva.

Se o usuário pedir explicitamente para exportar uma conversa, diga que o exportador foi descontinuado e pergunte se ele quer reverter a decisão. Não contorne o bloqueio do script.
