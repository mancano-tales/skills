---
autor: "Tales Mançano / Ecossistema"
name: close-task
description: Cerimônia completa de encerramento de tarefa. Executa todo o workflow de auditoria: marca planos como concluídos, faz o commit seguro (porquê no corpo, trailer Agent:), comenta kind: result na issue do plano e, só se o autor pedir, atualiza o inventário de logs e exporta a conversa. Só rodar uma vez no final definitivo da sessão.
---

# Cerimônia de Encerramento (Close Task)

Esta skill define o Procedimento Operacional Padrão (SOP) que todo agente deve seguir estritamente quando o usuário solicitar o encerramento ou finalização de uma tarefa. Esta skill é **idêntica em todo repositório que a usa** — qualquer particularidade deste projeto (caminho do script de exportação, pasta de autoria protegida) vem de `CLAUDE.md` § "Configuração de Skills", nunca hardcoded aqui.

**ATENÇÃO CRÍTICA**: Esta skill só deve ser executada **UMA ÚNICA VEZ**, no fim definitivo da conversa/sessão. Nunca a rode a cada mensagem, pois o script de exportação cria múltiplas cópias do histórico se invocado repetidamente.

> **Exportar a conversa é opcional** (autor, 2026-09-26): faça os passos 3 e 4 **só se o autor pediu a exportação nesta sessão**. Sem pedido, pule-os; exports automáticos a cada tarefa geram cópias repetidas da mesma conversa.

Siga OS PASSOS ABAIXO EXATAMENTE NESTA ORDEM:

## 1. Marcar o Plano como Concluído
- Localize o plano ativo (em `9-vers/plan/`) que originou a tarefa. Se houver mais de um, pergunte ao usuário qual deve ser finalizado.
- Use ferramentas de edição (e.g. replace_file_content) para mudar `status: "EM EXECUÇÃO"` (ou `"ATIVO"`) para `status: "CONCLUÍDO"`.
- Adicione a chave `concluido: "YYYY-MM-DD"` (**só a data**; a hora exata é a do commit) logo abaixo da chave `criado`, respeitando **exatamente** a indentação já usada por `criado` na mesma linha/nível — não invente indentação nova.
- Adicione no array `relacionados` o nome ou identificador do log de conversa que será gerado no passo 4 (se houver exportação).
- **Checkpoint obrigatório**: assim que terminar esta edição, rode `Rscript tools/validate-governance.R` (sem `--sync`) antes de prosseguir para o passo 2. O parser YAML deste repositório já teve bugs reais de indentação/aspas passarem despercebidos até o commit; rodar o validador aqui pega corrupção de YAML imediatamente, com o arquivo ainda fácil de corrigir, em vez de só no passo 5.

## 2. Registrar o que foi feito (commit + issue)
- O registro mora no git e no GitHub: registre no **corpo do commit** o porquê (um parágrafo curto), termine a mensagem com o trailer `Agent: <harness> / <modelo> / <plataforma>` (e `Refs: #N` se houver issue), e comente `kind: result` na issue do plano com o resumo. O `NEWS.md` foi aposentado (hub, issue #37): não crie, não edite e não recrie `NEWS.md` nem fragmentos.
- Redija agora o resumo da sessão (decisões, código alterado, bugs corrigidos): ele vira o corpo do commit do passo 6 e o comentário `kind: result` (com `sessao:`, `modelo:`, `esforco:`) na issue do plano, feito depois do push.

## 3. Atualizar o Inventário de Logs (só se o autor pediu a exportação)
- Abra o arquivo `9-vers/llm-reviews/README.md`.
- Adicione uma nova linha ao final (ou topo) da tabela `## Inventário` prevendo o arquivo do log que será exportado.
  - A convenção do nome gerado pelo script será: `YYYY-MM-DD_HHMM_<slug-descritivo-em-kebab-case>_conversa-<fonte>.md`.
  - Tipo: `Conversa`
  - Fonte: O seu nome (ex: `Antigravity` ou `Claude`)
  - Assunto: Um parágrafo detalhado das decisões tomadas nesta sessão de trabalho.

## 4. Exportar a Conversa (só se o autor pediu)
- Você deve exportar o registro desta sessão rodando o script utilitário existente (que suporta tanto Claude quanto Antigravity). O caminho do script é a chave **`script_exportar_conversa`** em `CLAUDE.md` § "Configuração de Skills" deste repositório (se a chave não estiver preenchida, tente `tools/export_conversa.R`).
- **Para Antigravity**: você tem o seu ID de conversa na variável de metadados do contexto (ex: `071f9430-...`).
- **Para Claude**: você pode inferir o UUID a partir do seu scratchpad.
- Execute no terminal (completando o caminho do script, o seu ID da sessão atual e um slug amigável e conciso de até 4 palavras):
  ```bash
  Rscript <script_exportar_conversa> <SEU-ID-DE-SESSAO> <um-slug-descritivo-em-kebab-case>
  ```
- O script vai gerar o arquivo Markdown na pasta `9-vers/llm-reviews/` e imprimir o caminho absoluto no terminal. Verifique se o nome do arquivo gerado coincide com o que você registrou no inventário no Passo 3. Se não, corrija o inventário.

## 5. Validação e Sincronização
- **NUNCA use `git add .` ou `git add -A`** — proibido pelo `CLAUDE.md` § "Strict Staging Policy". Faça `git status` e stage **explicitamente, arquivo por arquivo**, apenas: (a) o plano editado no passo 1; (c) `9-vers/llm-reviews/README.md` editado no passo 3; (d) o log de conversa exportado no passo 4 (c e d só se houve exportação); (e) qualquer arquivo de código/script/figura que você mesmo editou como parte desta tarefa (você já sabe quais são — enumere-os, não adivinhe pelo `git status`).
  ```bash
  git add <caminho1> <caminho2> ...
  ```
  **Consulte a chave `diretorio_autoria_primaria` em `CLAUDE.md` § "Configuração de Skills".** Se estiver preenchida e `git status` mostrar mudanças ali, NÃO as inclua no commit mesmo que tenham sido feitas por você — avise o usuário que ficaram fora do commit.
- Sincronize o índice de planos (só isso — ver nota abaixo):
  ```bash
  Rscript tools/validate-governance.R --sync
  ```
  **Nota de arquitetura**: `--sync` só reescreve `plan/README.md` a partir do YAML dos planos no disco e sai (`quit(status=0)` logo depois); ele **não roda as checagens T1-T6** (caminhos absolutos, tamanho de blob, styler, citações, marcadores de conflito). Essas checagens rodam automaticamente pelo hook `pre-commit` durante o `git commit` do passo 6, sem `--sync`. Não pule o passo 6 achando que já foi tudo validado aqui.

## 6. Commit (Tratamento de Concorrência)
- Faça o commit das alterações **só com os arquivos stageados no passo 5** (nunca `git commit -a`), formatando a mensagem:
  ```bash
  git commit -m "chore: <assunto-ou-slug-da-tarefa> refs #N" -m "<porquê, um parágrafo>" -m "Agent: <harness> / <modelo> / <plataforma>"
  ```
- O hook `pre-commit` roda `Rscript tools/validate-governance.R` (T1-T6) neste momento. Se ele bloquear o commit, corrija o problema apontado — não contorne com `--no-verify` sem autorização explícita do usuário nesta conversa.
- **Tratamento de Concorrência e Index.Lock**: como trabalhamos num ecossistema multiagente, o Git pode acusar que `.git/index.lock` já existe. Isso **não é um erro lógico ou sintático** — só significa que outro processo git está em andamento. Trate assim, com limite:
  1. Aguarde ~3-5 segundos e tente de novo.
  2. Repita no máximo **3 vezes** (~15 segundos no total).
  3. Se o lock ainda existir depois disso, **PARE e avise o usuário** — não conclua sozinho que o lock está órfão, e **nunca apague `.git/index.lock` por conta própria**. Um lock órfão (processo travado/morto) parece idêntico a um lock ativo do ponto de vista do agente; distinguir os dois exige checar processos em execução (`tasklist`/`ps`) e a idade do arquivo, e a decisão de remover é do usuário.

Ao finalizar todos os 6 passos com sucesso, comunique ao usuário que a tarefa foi encerrada e que o repositório está limpo, logado, e o commit da sessão foi realizado. Liste explicitamente qualquer arquivo que ficou de fora do commit (ex.: caminhos protegidos por `diretorio_autoria_primaria`) e por quê. Pode então aguardar o encerramento da conversa.

