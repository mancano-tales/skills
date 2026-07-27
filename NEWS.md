# Registro de Alterações (Log do Repositório Skills)

Este arquivo documenta as mudanças importantes na estrutura, adiantamento de skills e convenções de governança do repositório `skills`.

## 2026-07-27 13:14 — Instalação do Template de Governança Agêntica, 11 Skills Compartilhadas e Git Hooks

* **Governança Agêntica**: Adotado o scaffold do `agentic-research-template` (`0-meta/`, `tools/`, `CLAUDE.md`, `AGENTS.md`, `TODO.md`, `GUIDANCE.md`).
* **Interoperabilidade Multiagente**: Estabelecido o hard link `AGENTS.md` ≡ `CLAUDE.md`, `.github/copilot-instructions.md` ≡ `CLAUDE.md` e a NTFS Junction `.agents` -> `.claude`.
* **Skills Compartilhadas**: Sincronizadas as 11 skills da matriz (`close-task`, `code-review`, `edit-article`, `export-conversation`, `git-cleanup`, `grill-me`, `grill-with-docs`, `grilling`, `pdf-text-extractor`, `request-audit`, `sync-skills`) em `.claude/skills/` e integrada a skill autoral `tts-html-builder`.
* **Git Hooks**: Ativados os hooks `post-merge` e `post-checkout` em `hooks/` via `core.hooksPath` para verificação de versão em segundo plano.
* **Automação de Commit**: Atualizados os scripts `tools/sync-skills.ps1` e `tools/sync-skills.sh` para suporte ao parâmetro `-Commit` / `--commit` com Conventional Commits.

**Metadados de Execução**:
- **Data/Hora**: 2026-07-27 13:14 (Horário Local)
- **Agente**: Antigravity / Gemini 3.6 Flash (High) / Antigravity IDE
- **Mensagem do Commit**: "feat(governance): instala template de governanca agentica, 11 skills e git hooks"
- **Arquivos afetados**: `CLAUDE.md`, `AGENTS.md`, `NEWS.md`, `TODO.md`, `README.md`, `GUIDANCE.md`, `0-meta/`, `tools/`, `hooks/`, `.claude/skills/`
