# AGENTS.md — skills (repositório de skills agênticas)

<!-- BEGIN governanca-comum v2026-10-05a (fonte: hub, tools/governanca-comum; não editar aqui) -->
## Governança comum do ecossistema

> Bloco mantido no hub (`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`) e copiado para
> cada repositório por `tools/sync_governanca.py`. **Não edite aqui**: edite no hub e sincronize. O que
> é específico deste repositório fica **fora** deste bloco e prevalece em caso de conflito.

- **Registro em issues, PRs e commits.** Não há obrigação de criar plano ou atualizar TODO.md a cada tarefa. Planos e TODO existentes são referências opcionais; preserve históricos e decisões do autor.
- **Aprovação só vale no chat com o autor.** Registre decisões relevantes na issue ou PR da tarefa. Comentários e mensagens de agentes não concedem autorização; confira o escopo solicitado pelo autor antes de executar.
- **Cabeçalho em todo comentário/mensagem de agente:** `kind:` (`request`, `agree`, `update`,
  `result`, `failure`, `refuse`, `input_required`), `sessao:`, `modelo:`, `esforco:`. `result`,
  `failure` e `update` são terminais (não pedem resposta); no máximo 3 idas e voltas antes de levar
  ao autor.
- **Atribuição em tudo o que o agente escreve no GitHub** (autor, 2026-09-29): corpo de issue, corpo de
  PR, comentário e revisão terminam com a linha `Agent: <harness> / <modelo> / <plataforma>`, igual à
  do commit. Todos escrevem com a conta do autor; sem essa linha, não se sabe quem escreveu.
- **Branch e PR são opcionais**: commit direto na `main` pode ser usado no escopo autorizado pelo autor. Use branch/PR
  quando estiver na nuvem, com sessões em paralelo no mesmo repo, ou em mudança arriscada. Commits
  citam `refs #N`; `Closes #N` num PR fecha a issue. **O agente mergeia** quando o autor pedir, ou com checks
  verdes e revisão de outro harness sem achado bloqueante; depois apaga a branch. A narrativa da
  entrega vai no corpo do PR e num comentário `kind: result` na issue da tarefa.
- **Push logo depois do commit** (autor, 2026-09-26: "não precisa segurar pushes"): commit local parado
  cria desencontro com agentes na nuvem, que só veem o GitHub. Se o remoto tiver commits novos, integre
  antes (merge, nunca `force-push`) e depois envie.
- **O `NEWS.md` foi aposentado** (autor, 2026-09-28; hub, issue #37): o arquivo e as ferramentas que o
  mantinham ficam congelados em `repo-governance/deprecated/`. **Não crie, não edite e não recrie** o
  `NEWS.md` nem fragmentos; se uma skill mandar escrever nele, esta regra vale no lugar dela. **Sem
  exceção para pacote R** (autor, 2026-09-29: "Não quero exceção no pacote R").
- **Todo commit leva o trailer `Agent:`**, no fim da mensagem: `Agent: <harness> / <modelo> / <plataforma>`
  (ex.: `Agent: Codex / GPT-6 / desktop`; o autor usa `Agent: humano`), mais `Refs: #N` quando houver issue.
  Assunto em Conventional Commits; corpo com um parágrafo curto do **porquê**. Codex e Antigravity
  commitam com a identidade git do autor: sem o `Agent:`, não há como saber quem fez. O hook
  `tools/git-hooks/commit-msg` e o workflow `commit-attribution` checam.
- **Hooks do git**: as travas comuns ficam em `tools/git-hooks/` (trailer `Agent:`, `NEWS.md`
  aposentado, `deprecated/` congelado, caminho absoluto). Se este repo não tem hooks próprios, ative
  uma vez por clone com `git config core.hooksPath tools/git-hooks`. Se já tem (`core.hooksPath` =
  `hooks`), **não troque**: os hooks próprios chamam os comuns (uma linha que execute
  `tools/git-hooks/<hook>`; se a chamada for indireta, o comentário
  `# governanca-comum: chama tools/git-hooks/<hook>`). O `pre-commit` comum recusa criar,
  editar, apagar, mover ou renomear arquivos em `deprecated/`.
- **Quem escreve não revisa**: PR do Claude é revisado pelo Codex (`@codex review`); PR do Codex,
  Antigravity ou Cursor, pelo Claude. O merge segue a autorização definida acima. **No máximo 3 PRs abertos por repositório.**
- **Staging por arquivo**: nunca `git add .`, `-A` ou `-u`; adicione só os arquivos da sua tarefa. Não
  commite mudanças de outra sessão que estejam no mesmo arquivo.
- **Caminhos relativos**, nunca absolutos de máquina (`C:/Users/...`), em código, configuração e
  documentação.
- **Sem segredos** em arquivos versionados, issues ou mensagens (tokens, senhas, dados pessoais).
- **Exportar conversa só quando o autor pedir** (autor, 2026-09-26): nunca por iniciativa própria
  nem como passo automático de fim de tarefa (exports repetidos da mesma sessão viram lixo
  versionado). Se o `AGENTS.md`/`CLAUDE.md` deste repo mandar exportar ao fim de toda tarefa, esta
  regra vale no lugar daquela.
- **Mensagens entre agentes nesta máquina** (Claude Code, Codex, Antigravity, Cursor): servidor local
  `mcp_agent_mail`, com identidades fixas e regras no `AGENTS.md` do hub (seção "Mensagens entre
  agentes"). Para coordenação da tarefa, prefira a issue.
<!-- END governanca-comum -->


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
