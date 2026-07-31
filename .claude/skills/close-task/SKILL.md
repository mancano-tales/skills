---
autor: "Tales Mançano / Ecossistema"
name: close-task
description: Cerimônia completa de encerramento de tarefa. Executa todo o workflow de auditoria: marca planos como concluídos, escreve no NEWS.md, atualiza o inventário de logs, exporta a conversa da sessão atual e faz o commit seguro. Só rodar uma vez no final definitivo da sessão.
---

# Cerimônia de Encerramento (Close Task)

Procedimento operacional padrão para encerrar uma sessão de trabalho em qualquer
repositório do ecossistema.

**Esta skill é idêntica em todo repositório que a usa.** Por isso ela não pode conter
o nome do diretório de governança, o formato do `NEWS.md` nem o caminho de nenhum
script: esses valores divergem entre os repositórios. Todos são **descobertos no
passo 0**, contra o repositório em que a skill está rodando.

**ATENÇÃO CRÍTICA**: execute esta skill **UMA ÚNICA VEZ**, no fim definitivo da
sessão. O exportador de conversa cria uma cópia nova a cada invocação.

---

## Passo 0 — Descobrir as convenções deste repositório

Antes de qualquer edição, resolva os cinco valores abaixo. **Não presuma nenhum
deles.** Anote o que encontrou: você vai declará-los no relatório final.

| Valor | Como resolver | Se não existir |
| :--- | :--- | :--- |
| `DIR_GOVERNANCA` | Chave `diretorio_governanca` na tabela § "Configuração de Skills" do `CLAUDE.md`/`AGENTS.md`. Sem a tabela, procure o diretório que contenha as subpastas `plan/` **e** `llm-reviews/` | Pergunte ao usuário; não invente |
| `GOV_DIR` (env) | Necessária **só se** `DIR_GOVERNANCA` estiver fora da lista padrão do exportador (`0-meta`, `9-vers`). Exportar sem ela grava o log na pasta errada, em silêncio | Não precisa exportar a variável |
| `SCRIPT_EXPORTACAO` | Chave `script_exportar_conversa`. Fallback: `export_conversa.R` em `tools/` | Ver passo 4, caso B |
| `VALIDADOR` | `validate-governance.R` em `tools/` | Pule as validações e declare isso |
| `FORMATO_NEWS` | **Leia o `NEWS.md` existente** e imite o que já está lá | Ver passo 2 |
| `DIR_AUTORIA_PROTEGIDA` | Chaves `diretorio_autoria_primaria` / `arquivo_gerenciado_externamente` | Nenhum arquivo é protegido |

Valores já observados no ecossistema, apenas para calibrar a busca — a lista é
ilustrativa e **não** deve ser tratada como exaustiva:

- `DIR_GOVERNANCA`: `0-meta/` (raiz `MancanoSync`, `skills`), `9-vers/` (repos de
  pesquisa, onde é o slot 9 de uma taxonomia numerada), `repo-govrn/` (`edupol`).
- `FORMATO_NEWS`: seções datadas com bloco de **Metadados de Execução** (raiz, skills)
  · **Keep a Changelog 1.1.0**, com categorias `Adicionado`/`Corrigido`/`Alterado` e uma
  linha por commit com hash e timestamp (`edupol`, ver `AGENTS.md` § 5).

---

## Passo 1 — Fechar o plano, se houver um

- Liste os planos em `<DIR_GOVERNANCA>/plan/` e leia o `status` de cada um.
- Feche **apenas o plano que originou esta tarefa**.
  - Havendo mais de um candidato, **pergunte ao usuário**.
  - Havendo planos abertos que **não** são desta tarefa (típico quando outra sessão
    trabalha em paralelo), **não toque neles** e diga isso no relatório final.
  - Se **nenhum** plano corresponde a esta tarefa — caso comum quando o trabalho foi
    incremental e não exigiu plano —, pule este passo e registre a ausência. Não crie
    um plano retroativo, e não feche o de outra pessoa só para ter o que fechar.
- Ao fechar, use o valor de conclusão **que o próprio repositório usa** (`CONCLUÍDO`,
  `🟢 Concluído`, `Concluído`…; confira o índice de planos) e preencha
  `concluido: "YYYY-MM-DD HH:MM"` respeitando a indentação e o estilo de aspas já
  usados pela chave `criado` no mesmo arquivo.
- Acrescente ao array `relacionados` o nome do log que será gerado no passo 4.
- **Checkpoint**: rode `<VALIDADOR>` agora. Erros de indentação YAML já passaram
  despercebidos até o commit neste ecossistema; pegar aqui é barato.

## Passo 2 — Registrar no NEWS.md

Escreva a entrada **no formato que o arquivo já usa** (`FORMATO_NEWS`, passo 0).
Impor um formato estranho ao repositório quebra a consistência do changelog e, onde
houver validação de formato, bloqueia o commit.

- **Seções datadas**: cabeçalho `## YYYY-MM-DD HH:MM — Título` e, ao final, o bloco
  **Metadados de Execução** (Data/Hora, Agente, Mensagem do Commit, Arquivos afetados)
  exigido pela § "Synchronized Commit Policy".
- **Keep a Changelog**: uma linha por alteração, na categoria correta, no padrão de
  entrada do repositório.

Em ambos: **timestamp com hora e minuto**, no fuso local, nunca só a data. Se a hora
exata não for recuperável, deixe só a data e explique por quê — não invente.

**Nunca reescreva entradas antigas.** Só append.

## Passo 3 — Atualizar o inventário de logs

Abra `<DIR_GOVERNANCA>/llm-reviews/README.md` e acrescente uma linha à tabela,
**usando as colunas que a tabela já tem** — elas variam entre repositórios. O nome do
arquivo segue a convenção do exportador:
`YYYY-MM-DD_HHMM_<slug-em-kebab-case>_conversa-<fonte>.md`.

Confira o nome real gerado no passo 4 e corrija a linha se divergir.

## Passo 4 — Exportar a conversa

**Caso A — `SCRIPT_EXPORTACAO` existe:**

```bash
# Exporte GOV_DIR se o diretório de governança deste repositório estiver fora da
# lista padrão do exportador — sem isso o log vai para uma pasta que não existe.
GOV_DIR=<DIR_GOVERNANCA> Rscript <SCRIPT_EXPORTACAO> <ID-DA-SESSAO> <slug-em-kebab-case>
```

O ID da sessão: no Antigravity, está nos metadados do contexto; no Claude Code, pode
ser inferido do caminho do scratchpad.

Duas verificações obrigatórias depois de rodar:

1. **Onde o arquivo foi gravado.** Mesmo com `GOV_DIR`, confira o caminho que o script
   imprimiu. Sem a variável, o exportador cai no primeiro nome da lista padrão e grava
   numa pasta que não existe — o log se perde em silêncio, já aconteceu (incidente de
   2026-07-26). Se o destino estiver errado, mova o arquivo para
   `<DIR_GOVERNANCA>/llm-reviews/`, remova a pasta espúria e **abra uma issue no
   repositório do exportador**.
2. **Se o log passa no validador.** O exportador grava o caminho absoluto do arquivo de
   origem no cabeçalho, e transcrições de sessão costumam conter caminhos locais nas
   chamadas de ferramenta. Repositórios que proíbem caminhos absolutos (`C:\Users\`,
   `/home/`, `/Users/`) vão bloquear o commit. Ocorrendo isso, sanitize o log
   substituindo a raiz do repositório e o diretório do usuário por marcadores, e
   registre a substituição em nota dentro do próprio arquivo.

**Caso B — não há exportador neste repositório:** não invoque o script de outro
repositório sem antes conferir para onde ele grava. Declare no relatório final que o
log não foi exportado e por quê.

## Passo 5 — Validar e preparar o commit

- **NUNCA use `git add .` ou `git add -A`.** Stage explícito, arquivo por arquivo:
  (a) o plano do passo 1, se houve; (b) o `NEWS.md`; (c) o inventário do passo 3;
  (d) o log exportado; (e) os arquivos que **você mesmo** editou nesta tarefa —
  enumere-os de memória, não deduza do `git status`, que pode conter trabalho de outra
  sessão em paralelo.
- Se `DIR_AUTORIA_PROTEGIDA` estiver definido e houver mudanças ali, **não** as inclua,
  ainda que sejam suas. Avise no relatório final.
- **Antes de rodar o validador com qualquer flag, confirme que ele aceita a flag.** Nem
  toda cópia de `validate-governance.R` no ecossistema implementa `--sync`; invocar uma
  flag inexistente faz o script rodar em modo padrão sem avisar. Verifique com
  `grep -c 'commandArgs' <VALIDADOR>` ou lendo o cabeçalho.
  - Aceitando `--sync`: `Rscript <VALIDADOR> --sync` reescreve o índice de planos a
    partir do YAML e **sai sem rodar as checagens**, que rodam no hook do passo 6.
  - Não aceitando: rode `Rscript <VALIDADOR>` sem flag.

## Passo 6 — Commit

- Commit apenas do que foi stageado (**nunca `git commit -a`**), com a mensagem no
  padrão do repositório. Vários exigem **Conventional Commits**, então
  `chore: <assunto>` costuma servir — confirme a convenção antes.
- O hook `pre-commit` roda o validador aqui. Bloqueando, **corrija a causa**. Não use
  `--no-verify` sem autorização explícita do usuário nesta conversa.
- **`.git/index.lock`**: em ecossistema multiagente isso significa que outro processo
  git está ativo, não que houve erro. Espere 3-5 s e tente de novo, no máximo 3 vezes.
  Persistindo, **pare e avise o usuário**. Nunca apague `index.lock` por conta própria:
  um lock órfão é indistinguível de um lock ativo sem inspecionar processos, e a decisão
  de removê-lo é do usuário.

---

## Relatório final

Comunique o encerramento e declare explicitamente:

1. Os valores resolvidos no passo 0 — `DIR_GOVERNANCA`, formato do `NEWS.md`, validador
   e flags disponíveis.
2. Qual plano foi fechado, ou que nenhum correspondia à tarefa, e quais planos abertos
   de terceiros ficaram intactos.
3. Arquivos deixados fora do commit e por quê.
4. Qualquer passo que **não** pôde ser cumprido, e o motivo. Um passo pulado e declarado
   é aceitável; um passo pulado em silêncio corrompe a auditoria.
