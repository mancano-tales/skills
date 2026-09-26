# AGENTS.md — skills (repositório de skills agênticas)

Contexto operacional para agentes de IA. É o **único** arquivo de instruções: o `CLAUDE.md` contém só `@AGENTS.md` e o `.github/copilot-instructions.md` só aponta para cá. Para humanos: `README.md` e `GUIDANCE.md`. A história está no `NEWS.md`.

## 1. O que é

Fonte das skills do ecossistema do autor, para Claude Code, Codex, Gemini/Antigravity e Copilot. O hub (`mancano-repo-hub`) e os repos consumidores puxam daqui com `sync-skills` (`tools/.skills-source` → `../skills`); **nunca há sincronização automática**.

## 2. Estrutura

| Caminho | O que é |
|---|---|
| `.claude/skills/<nome>/SKILL.md` | Skills ativas: as de governança (`close-task`, `export-conversation`, `git-cleanup`, `request-audit`, `sync-skills`…) e as de pesquisa e desenvolvimento |
| `skills/` | Skills autorais publicáveis (`tts-html-builder`, `conventional-commits`). **Autoria primária** |
| `.agents` | Junção/symlink para `.claude` (gitignorada; recriar com `setup` do template se sumir) |
| `0-meta/` | Governança: `plan/` (índice em `plan/README.md`), `llm-reviews/` |
| `tools/` | `sync-skills.ps1`/`.sh`, `export_conversa.R`, `validate-governance.R` |
| `hooks/` | `post-merge`, `post-checkout`: relatório de sincronização de skills |

## 3. Regras

- **Staging cirúrgico**: `git add <arquivo>`; nunca `git add .`/`-A`.
- **Co-commit**: toda mudança leva a entrada no `NEWS.md` no mesmo commit (cabeçalho `## YYYY-MM-DD — Título`, só a data), terminando com:
  ```markdown
  **Metadados de Execução**:
  - **Data**: YYYY-MM-DD
  - **Agente**: [Nome] / [Modelo] / [Plataforma]
  - **Mensagem do Commit**: "..."
  - **Arquivos afetados**: ...
  ```
- **Skills genéricas não hardcodeiam nada** do repo que as usa: valores específicos vêm da seção "Configuração de Skills" do `AGENTS.md` de cada consumidor. Mudou a interface (uma chave nova), avise no `NEWS.md` e no `README.md`.
- **Skills portadas de terceiros** (ex. [mattpocock/skills](https://github.com/mattpocock/skills)) ficam fiéis ao original, com a licença e a origem no `README.md`.
- **Exportar conversa só quando o autor pedir**, uma vez por sessão (nunca ao fim de toda tarefa): `Rscript tools/export_conversa.R <session_uuid> [slug]`.
- Validar antes de commitar: `Rscript tools/validate-governance.R`.

## 4. Configuração de Skills

| Chave | Usada por | Valor neste repositório |
|---|---|---|
| `diretorio_governanca` | todas as skills | `0-meta/` |
| `diretorio_autoria_primaria` | `close-task`, `git-cleanup` | `skills/` |
| `script_exportar_conversa` | `close-task`, `export-conversation` (só quando o autor pedir) | `tools/export_conversa.R` |
| `diretorios_trabalho_continuo` | `git-cleanup` | `0-meta/plan/` |
