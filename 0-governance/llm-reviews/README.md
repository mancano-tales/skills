# llm-reviews/ — Inventário de Auditorias e Conversas de IA (skills)

Esta pasta armazena o histórico das conversas de IA exportadas (logs de sessão em Markdown) referentes ao repositório **skills**.

Ao concluir uma tarefa ou plano, o agente deve exportar a sessão utilizando o script:
```powershell
Rscript tools/export_conversa.R <session_uuid> [slug]
```
E registrar a nova entrada no inventário abaixo.

---

## Inventário de Sessões Exportadas

| Data/Hora | UUID | Slug / Descrição | Agente / Modelo | Plano Relacionado |
|---|---|---|---|---|
| 2026-07-27 13:14 | `9c8ba0d0-8ce6-4238-ae4f-92fc79a7a6e1` | instalacao-governanca-skills | Gemini 3.6 Flash (Antigravity) | `0-meta/plan/2026-07-27_Plano_Instalar-Governanca-Skills-Repo.md` |
