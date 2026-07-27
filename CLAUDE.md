# CLAUDE.md — Skills (Repositório de Skills Agênticas)

> 🚨 **CRITICAL AGENT RULES (COVENANT) — READ FIRST:**
> - **HARD LINK RULE:** AI Agents **MUST NOT waste time** testing, auditing, or manually recreating hard links (mklink). Automated governance scripts (alidate-governance.R / setup) handle this automatically in the background. Focus strictly on your primary task.
> - **RULE 1:** You are operating under the **Agent Covenant** framework. Every commit is audited. Run `Rscript tools/validate-governance.R` to test your edits before committing.
> - **RULE 2:** Any modification in main files REQUIRES an update in the root `NEWS.md` file in the same commit.
> - **RULE 3:** When completing a task or plan, you MUST run the conversation exporter to save your session log (`Rscript tools/export_conversa.R <session_uuid> [slug]`).
> - **RULE 4 (MULTI-AGENT INTEROPERABILITY):** This repository supports Claude Code (`.claude/`), Antigravity/Gemini (`.agents/`), OpenAI/Codex (`AGENTS.md`), and GitHub Copilot (`.github/copilot-instructions.md`). Hard links and junctions maintain full physical parity across all platforms.
> - **For humans:** see [GUIDANCE.md](GUIDANCE.md) for the sitemap.

---

## Current State of the Project (version dated 2026-07-27)

> **Esta seção é a única fonte de verdade sobre a concepção ATUAL do repositório.** Alterações de design, arquitetura e convenções devem ser registradas aqui.

- **Descrição Geral**: Repositório central de **Skills customizadas** e de governança para assistentes de IA (Antigravity, Claude Code, OpenAI, Gemini). Versiona tanto a coleção pública de skills quanto as 11 skills compartilhadas do ecossistema `MancanoSync`.
- **Arquitetura & Componentes**:
  - `skills/`: Diretório contendo skills autorais customizadas (ex.: `tts-html-builder`).
  - `.claude/skills/`: Diretório de skills ativas de governança e ferramentas (11 skills compartilhadas da matriz `agentic-research-template`).
  - `.agents`: Junction NTFS / Symlink apontando fisicamente para `.claude` (garante que IAs que buscam `.agents` acessem as mesmas skills sem duplicação de dados).
  - `0-governance/`: Scaffold de governança (`0-governance/plan/` para planos, `0-governance/llm-reviews/` para auditorias de conversas).
  - `tools/`: Scripts de sincronização (`sync-skills.ps1`/`.sh`), exportação (`export_conversa.R`) e validação (`validate-governance.R`).
  - `hooks/`: Git Hooks (`post-merge`, `post-checkout`) para verificação automática de sincronização em segundo plano.
- **Proibições Estritas (Standing Prohibitions)**:
  - Nunca execute `git add .` ou `git add -A`. Apenas adicione os arquivos específicos modificados (`git add <file>`).
  - Nunca edite manualmente arquivos gerenciados externamente sem registrar no `NEWS.md`.
  - Nunca quebre os hard links físicos (`AGENTS.md` ≡ `CLAUDE.md`, `.github/copilot-instructions.md` ≡ `CLAUDE.md`).- **Planos ativos**: consulte o índice de status em `0-governance/plan/README.md`.

---

## Guidance Documents: Map and Precedence Rules

**Regras de Precedência:**
1. Em caso de conflito, a seção "Current State" acima + o plano ativo em `0-governance/plan/` correspondente prevalecem sobre qualquer outro documento.
2. Arquivos marcados com banner de desatualização/arquivamento são mantidos apenas para histórico.

| Documento | Público | Função | Quando Atualizar |
|---|---|---|---|
| `CLAUDE.md` / `AGENTS.md` | Agentes | Estado ATUAL do projeto, convenções e mapa | Mudança de arquitetura |
| `TODO.md` | Ambos | Log append-only de tarefas (Pendente/Prospectivo/Concluído) | A cada tarefa |
| `README.md` | Humanos | Apresentação do repositório, guia de uso e lista de skills | Adição de skill |
| `NEWS.md` | Ambos | Registro intelectual de alterações | A cada commit |
| `0-governance/plan/README.md` | Ambos | Índice de status dos planos | Criação ou mudança de status |

---

## Git e Convenções de Documentação

- **Commits Permitidos**: Agentes de IA estão autorizados a fazer commits diretamente no repositório.
- **Staging Cirúrgico**: Agentes **NUNCA** devem utilizar `git add .`. Devem adicionar cirurgicamente apenas os arquivos modificados (ex: `git add .claude/skills/sync-skills/SKILL.md`).
- **Synchronized Commit Policy (Co-committing)**: Cada commit com mudanças deve atualizar o `NEWS.md` na mesma transação de commit, incluindo o bloco de metadados:
  ```markdown
  **Metadados de Execução**:
  - **Data/Hora**: YYYY-MM-DD HH:MM (Horário Local)
  - **Agente**: [Nome do Agente] / [Modelo] / [Plataforma]
  - **Mensagem do Commit**: "sua mensagem aqui"
  - **Arquivos afetados**: caminho/do/arquivo1, caminho/do/arquivo2
  ```

---

## Configuração de Skills (Skill Configuration)

| Chave | Usada por | Valor neste repositório |
|---|---|---|
| `diretorio_governanca` | todas as skills | `0-governance/` |
| `diretorio_autoria_primaria` | `close-task`, `git-cleanup` | `skills/` |
| `script_exportar_conversa` | `close-task`, `export-conversation` | `tools/export_conversa.R` |
| `diretorios_trabalho_continuo` | `git-cleanup` | `0-governance/plan/` |


