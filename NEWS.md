# Registro de Alterações (Log do Repositório Skills)

Este arquivo documenta as mudanças importantes na estrutura, adiantamento de skills e convenções de governança do repositório `skills`.

## 2026-07-28 00:15 — `skills` assume o papel de repositório-mãe; decisão de 2026-07-17 finalmente propagada

**Decisão de arquitetura (autor, 2026-07-28).** O ecossistema tinha **duas mães declaradas** para as mesmas skills: o `agentic-research-template` se declarava mãe das skills de governança no seu `CLAUDE.md`, e este repositório reunia 101 skills incluindo as mesmas 11. Era isso que quebrava o `sync-skills` — ele comparava contra uma fonte que existia em duas versões, e o sinal "em dia / desatualizada" deixou de significar qualquer coisa.

Fica definido:

| Repositório | É dono de |
|---|---|
| **`skills`** (este) | as skills — os procedimentos, o *como* |
| **`agentic-research-template`** | hooks, policy-as-code, validador, estrutura — o que torna a regra obrigatória |

O template passa a ser **consumidor** das skills deste repositório. A interface entre os dois é a tabela **§ Configuração de Skills** do `CLAUDE.md` de cada consumidor: a skill permanece genérica e lê dali o que for específico do projeto (`diretorio_governanca`, `script_exportar_conversa`, `diretorio_autoria_primaria`). Esse contrato é o que permite duas mães sem acoplamento.

**Auditoria de divergência — o resultado surpreendeu.** Comparando as 11 skills sobrepostas, 9 apareciam divergentes. Normalizando BOM, CRLF e o campo `autor:` inserido na rodada das 15:30 de ontem, **8 das 9 eram ruído de formatação, com conteúdo idêntico**. A divergência tinha sido criada horas antes, pela própria padronização de frontmatter — não por deriva real.

Isso expõe um defeito do `sync-skills`: comparação por hash não distingue "conteúdo mudou" de "BOM foi adicionado". A ferramenta reportava informação verdadeira e inútil.

**A única divergência real, e ela era grave.** `grill-me`, `grill-with-docs` e `edit-article` estavam com `disable-model-invocation: true` aqui e `false` no template. O `NEWS.md` do template, entrada de **2026-07-17 10:38**, registra a decisão do autor de mudar as três para `false` "em todos os consumidores", com `allow_implicit_invocation: true` no `agents/openai.yaml` correspondente.

**A decisão nunca saiu do template.** Onze dias depois, o valor original do Matt Pocock persistia aqui **e nas duas cópias globais da máquina** (`~/.claude/skills/` e `~/.gemini/config/skills/`) — que são justamente as que os agentes carregam de fato. Na prática, a decisão do autor não estava em vigor em lugar nenhum.

Corrigido nas três camadas (repositório + os dois espelhos globais), em `SKILL.md` e `agents/openai.yaml`. Verificação final: as 11 skills em paridade de conteúdo com o template.

É o mesmo defeito que, no mesmo dia, fez uma correção nascida no `cha-affirmative-action-us-brazil` (commit `6f8e7e7`, 2026-07-21) ser reimplementada do zero no template seis dias depois. Correções e decisões não fluem entre repositórios; só viajam quando alguém lembra.

**Metadados de Execução**:
- **Data/Hora**: 2026-07-28 00:15 (Horário de Brasília)
- **Agente**: Claude Opus 5 / claude-opus-5 / Claude Code (VS Code)
- **Mensagem do Commit**: "fix(skills): propaga decisão de disable-model-invocation e define skills como repositório-mãe"
- **Arquivos afetados**: `.claude/skills/{grill-me,grill-with-docs,edit-article}/SKILL.md` e `/agents/openai.yaml`, `NEWS.md`

## 2026-07-27 15:30 — Auditoria Adversarial Zero-Trust, Padronização de Frontmatter e Catálogo de 101 Skills

* **Auditoria de Subagentes**: Concluída a auditoria adversarial mecânica com 12 subagentes (incluindo o modelo Pro em modo zero-trust).
* **Consolidação do Catálogo (101 Skills)**: Todas as 101 skills físicas presentes em `.claude/skills` foram catalogadas e ordenadas por autor no [`README.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/README.md) (42 Galdino, 37 Pocock, 15 Anthropic, 7 Mançano/Ecossistema).
* **Padronização de Autoria**: Inserido o campo `autor: "Tales Mançano / Ecossistema"` no YAML frontmatter de todas as skills de governança que omitiam a chave (`close-task`, `export-conversation`, `git-cleanup`, `request-audit`, `sync-skills`, `tts-html-builder`, `pdf-text-extractor`), e corrigido o autor de `data-collection`.
* **Espelhamento Global Tríplice**: Re-sincronizadas 100% das 101 skills para `C:\Users\Mancano\.claude\skills\` e `C:\Users\Mancano\.gemini\config\skills\` (paridade de hash verificada com 0 divergências).

**Metadados de Execução**:
- **Data/Hora**: 2026-07-27 15:30 (Horário Local)
- **Agente**: Antigravity / Gemini 3.6 Flash (High) / Antigravity IDE
- **Mensagem do Commit**: "fix(skills): padroniza autor em 101 skills, atualiza catalogo do README e alinha governanca"
- **Arquivos afetados**: `.claude/skills/`, `README.md`, `NEWS.md`

## 2026-07-27 14:53 — Importação do Pacote Superpowers & Plugins Oficiais da Anthropic

* **Importação & Atribuição de Autoria**: Incorporadas as 14 skills do pacote oficial **`superpowers`** (Anthropic v5.1.0) e plugins oficiais de desenvolvimento (`frontend-design`, `build-mcp-server`, `claude-md-improver`) no repositório [`skills`](file:///c:/Users/Mancano/Documents/MancanoSync/skills).
* **Atribuição Explícita**: Cada arquivo `SKILL.md` foi atualizado no YAML frontmatter com `autor: "Anthropic (claude-plugins-official / superpowers)"`.
* **Catálogo Atualizado**: O [`README.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/README.md) foi atualizado com a seção dedicada a Superpotências & Workflows de Agentes.
* **Espelhamento Global**: As skills foram replicadas também nas pastas de configuração global `C:\Users\Mancano\.claude\skills\` e `C:\Users\Mancano\.gemini\config\skills\`.

**Metadados de Execução**:
- **Data/Hora**: 2026-07-27 14:53 (Horário Local)
- **Agente**: Antigravity / Gemini 3.6 Flash (High) / Antigravity IDE
- **Mensagem do Commit**: "feat(skills): importa pacote superpowers e plugins oficiais da Anthropic com atribuicao de autoria"
- **Arquivos afetados**: `.claude/skills/`, `README.md`, `NEWS.md`

## 2026-07-27 14:32 — Importação da Suíte Completa de Skills de Manoel Galdino e Matt Pocock

* **Importação & Atribuição de Autoria**: Incorporadas 86 skills no repositório `skills`, divididas entre as suítes acadêmicas e de ciência política de Manoel Galdino (`mgaldino/agents-workflow`), as suítes de engenharia e produtividade de Matt Pocock (`mattpocock/skills`) e as skills autorais de Tales Mançano.
* **Atribuição Explícita**: Cada arquivo `SKILL.md` foi atualizado com o campo `autor` no YAML frontmatter especificando o criador original.
* **Catálogo Reestruturado**: O [`README.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/README.md) foi reestruturado em 5 categorias temáticas com tabelas detalhadas e indicação clara de autoria.

**Metadados de Execução**:
- **Data/Hora**: 2026-07-27 14:32 (Horário Local)
- **Agente**: Antigravity / Gemini 3.6 Flash (High) / Antigravity IDE
- **Mensagem do Commit**: "feat(skills): importa suite completa de skills de Manoel Galdino e Matt Pocock com atribuicao de autoria"
- **Arquivos afetados**: `.claude/skills/`, `README.md`, `NEWS.md`

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
