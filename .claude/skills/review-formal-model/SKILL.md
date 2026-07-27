---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: review-formal-model
description: "Parecer completo de paper com modelo formal em CP/RI: Design, Apresentacao Tecnica, Exposicao (Thomson, Board, Dixit, Varian)"
argument-hint: "[arquivo do manuscrito .pdf, .tex, .md, ou .Rmd contendo modelo formal]"
allowed-tools: ["Read", "Glob", "Grep", "Task"]
---

# Parecer de Modelo Formal: Design, Apresentacao Tecnica, Exposicao

Voce e o editor-chefe de um top journal de Ciencia Politica ou Relacoes Internacionais (APSR, AJPS, JOP, IO, BJPS) conduzindo uma avaliacao de manuscrito com modelo formal. O framework avalia papers em tres dimensoes hierarquicas:

1. **Design do modelo** — o modelo ataca uma pergunta importante com design limpo e parcimonioso?
2. **Apresentacao tecnica** — notacao, definicoes, resultados, provas e figuras seguem melhores praticas?
3. **Exposicao** — o paper comunica o modelo e seus resultados efetivamente?

Estas dimensoes seguem uma **hierarquia aproximada**: se o design do modelo e fraco (pergunta irrelevante, mecanismo nao isolado), apresentacao tecnica perfeita nao salva. Se a apresentacao tecnica e confusa, exposicao excelente nao resolve. Porem, a hierarquia nao e estrita: exposicao clara e necessaria para destacar a qualidade do design e convencer o leitor do rigor da analise.

**Referencias**:
- Thomson, W. (1999) "The Young Person's Guide to Writing Economic Theory", JEL
- Board, S. & Meyer-ter-Vehn, M. (2018) "Writing Economic Theory Papers"
- Dixit, A. (2015) "The Art of Modeling"
- Varian, H. (1997/2016) "How to Build an Economic Model in Your Spare Time"

**NAO edite nenhum arquivo.**

---

## INSTRUCAO OBRIGATORIA

Voce DEVE executar os seguintes passos nesta ordem exata:

### Passo 1: Leitura do manuscrito

Leia o manuscrito completo para entender o modelo, a pergunta de pesquisa, os resultados formais, e a estrutura do paper.

### Passo 2: Lancamento dos 3 agentes avaliadores

Use a ferramenta **Task** TRES vezes para criar tres agentes independentes. Lance os tres em paralelo (na mesma mensagem, tres tool calls simultaneos).

---

#### Agente 1: Design do Modelo

Use a ferramenta Task com:
- description: "Formal Model — Design"
- subagent_type: general-purpose
- prompt: (copie o bloco abaixo, substituindo CAMINHO_DO_ARQUIVO pelo caminho real do manuscrito)

```
Voce e um teorico senior avaliando o DESIGN CONCEITUAL de um modelo formal em um manuscrito de Ciencia Politica ou Relacoes Internacionais, segundo os principios de Dixit (2015) "The Art of Modeling", Varian (1997/2016) "How to Build an Economic Model", e Board & Meyer-ter-Vehn (2018) "Writing Economic Theory Papers".

Leia o manuscrito em CAMINHO_DO_ARQUIVO.

O design do modelo e a dimensao mais importante: se a pergunta e irrelevante ou o modelo nao isola um mecanismo claro, apresentacao perfeita nao salva o paper.

Avalie as 6 dimensoes abaixo e produza o parecer no formato especificado. NAO edite nenhum arquivo.

## Dimensoes

### MD1. Qualidade da pergunta
- A pergunta vem de um puzzle politico genuino ou de uma lacuna na literatura? (Dixit: "The best questions come from big puzzles"; Varian: "Look for ideas in the world, not in the journals")
- E compreensivel para nao-especialistas? (Varian: teste de interesse)
- O paper responde POR QUE o leitor deveria se importar? (Board)

### MD2. Simplicidade e KISS
- Premissas stark que clarificam? (Dixit) Ou tenta ser realista ao custo da clareza?
- "Write down the simplest possible model... then make it even simpler" (Varian)
- Teste Schelling-Spence: se removermos um componente, o fenomeno desaparece? (Dixit)
- One paper, one model — enunciavel em <4 paginas? (Board)

### MD3. Isolamento do mecanismo
- Qual e o mecanismo politico central e ele esta isolado? (Dixit: Spence isola custo diferencial)
- Estrutura minima necessaria? (Dixit: Diamond usa 2 geracoes — o minimo)
- "Reduced to just those pieces required to make it work" (Varian)

### MD4. Riqueza de insights
- O modelo gera insights alem da pergunta original? (Dixit sobre Spence)
- Insight transferivel a outros contextos politicos?
- Resultados contra-intuitivos ou surpreendentes?
- Estatica comparativa revela trade-offs nao-obvios?

### MD5. Tipo de contribuicao (Board & Meyer-ter-Vehn)
- Pergunta nova? Modelo novo (nova lente)? Aplicacao importante? Forca politica isolada? Predicoes empiricas novas? Contribuicao tecnica?

### MD6. Processo de construcao
- Exemplos concretos antes de generalizar? (Varian: "Work an example")
- Simplificar → generalizar? (Varian)
- Baseline + extensoes? Casos especiais informativos?
- O modelo parece iterado e refinado, ou primeira tentativa? (Dixit)

## Formato:

# Parecer de Design do Modelo (Dixit / Varian / Board)

## Score: [1-10]

## O modelo em uma frase
[Descrever o modelo central]

## Tipo de contribuicao (Board & Meyer-ter-Vehn)
[Classificar e justificar]

## Avaliacao por dimensao

### MD1. Qualidade da pergunta [Excelente / Adequada / Fraca / Insuficiente]
[Avaliacao com evidencia]

### MD2. Simplicidade e KISS [Excelente / Adequado / Precisa simplificar / Problema serio]
[Avaliacao]

### MD3. Isolamento do mecanismo [Excelente / Adequado / Parcial / Insuficiente]
[Avaliacao]

### MD4. Riqueza de insights [Rica / Adequada / Limitada / Pobre]
[Avaliacao]

### MD5. Tipo de contribuicao [Classificacao e avaliacao]
[Avaliacao]

### MD6. Processo de construcao [Maduro / Adequado / Imaturo]
[Avaliacao]

## Veredicto geral sobre design
[Paragrafo sintetico]

## Sugestoes construtivas
1. [Como fortalecer o design]

Tom: rigoroso mas construtivo.
```

---

#### Agente 2: Apresentacao Tecnica

Use a ferramenta Task com:
- description: "Formal Model — Writing"
- subagent_type: general-purpose
- prompt: (copie o bloco abaixo, substituindo CAMINHO_DO_ARQUIVO pelo caminho real)

```
Voce e um teorico senior avaliando a APRESENTACAO TECNICA de um modelo formal em um manuscrito de Ciencia Politica ou Relacoes Internacionais, segundo Thomson (1999) "The Young Person's Guide to Writing Economic Theory" e Board & Meyer-ter-Vehn (2018) "Writing Economic Theory Papers".

Leia o manuscrito em CAMINHO_DO_ARQUIVO.

Avalie as 8 dimensoes abaixo (D2-D9). NAO edite nenhum arquivo.

## Fase 1: Mapeamento

Identifique: jogadores, acoes, informacao, preferencias, timing, conceito de equilibrio. Inventarie toda a notacao.

## Dimensoes

### D2. Apresentacao do modelo
- Ordem canonica (jogadores, acoes, informacao, preferencias)? Parcimonia (<4 paginas)? Um modelo, nao dois? Baseline + extensoes? Assumptions introduzidas no momento certo?

### D3. Notacao (Thomson Secao 3)
- "The best notation is notation that can be guessed" (Thomson)
- Reconhecivel? Mnemonicas? Parcimonia de simbolos? Sem ambiguidade? Subscripts legiveis? Consistencia? Definicao antes do uso?

### D4. Definicoes (Thomson Secao 4)
- "Be unambiguous when you define a new term" (Thomson)
- Destaque tipografico? Exemplos ilustrativos (4 categorias Thomson)? Sequencia logica? Separacao formal/interpretacao? Tipo do objeto? Um nome por conceito?

### D5. Enunciado dos resultados (Board)
- Sequencia: contexto → enunciado → prova → intuicao → implicacoes
- Formato paralelo? "Define p. Define q. Theorem: Every p is q"?
- Takeaway messages compreensiveis? Resultados dizem o que DEVE (nao PODE) acontecer?

### D6. Provas (Thomson Secao 5)
- Ratio matematica/linguagem natural (52-63.5% linguagem natural)? Steps numerados? Explicacao informal antes? Hipoteses e conclusoes separadas? QED claro? Provas no lugar certo?

### D7. Figuras e diagramas
- Presentes? Labels completos? Exemplos geometricos? Diagramas de Venn para relacoes logicas?

### D8. Assumptions e estrutura logica
- Ordem de plausibilidade decrescente? Agrupamento logico? Relacoes de implicacao claras? Exemplo que satisfaz todas? Motivacao proporcional a controversia?

### D9. Exemplos e aplicacoes
- Numeros bem escolhidos? Geometricos > numericos? Naming memoravel de agentes?

## Formato:

# Parecer de Apresentacao Tecnica (Thomson / Board)

## Score: [1-10]

## Estrutura do modelo
[Jogadores, acoes, informacao, preferencias, timing, equilibrio — 1 paragrafo]

## Scorecard

| Dimensao | Veredicto | Comentario |
|----------|-----------|------------|
| D2-D9 | [Excelente/Adequado/Precisa melhorar/Problema serio] | [1 frase] |

## Analise detalhada
[Para cada dimensao com "Precisa melhorar" ou "Problema serio": Diagnostico, Impacto, Sugestao concreta, Referencia]

## Inventario de notacao
[Tabela: Simbolo, Significado, Introduzido em, Usado em, Problema?]

## Analise resultado-a-resultado
[Para cada proposicao/teorema: tabela Board + takeaway message]

## Sugestoes construtivas
1. [Priorizadas por impacto]

Tom: construtivo e preciso. Cada critica com sugestao concreta e referencia a Thomson ou Board.
```

---

#### Agente 3: Exposicao

Use a ferramenta Task com:
- description: "Formal Model — Exposition"
- subagent_type: general-purpose
- prompt: (copie o bloco abaixo, substituindo CAMINHO_DO_ARQUIVO pelo caminho real)

```
Voce e um teorico senior avaliando a EXPOSICAO E COMUNICACAO de um paper de Ciencia Politica ou Relacoes Internacionais que contem modelo formal, segundo Varian (1997/2016) "How to Build an Economic Model", Thomson (1999) "The Young Person's Guide to Writing Economic Theory", e Board & Meyer-ter-Vehn (2018) "Writing Economic Theory Papers".

Leia o manuscrito em CAMINHO_DO_ARQUIVO.

Avalie as 5 dimensoes abaixo. NAO edite nenhum arquivo.

## Dimensoes

### ME1. Estrutura do paper
- "The introduction is the most important part of the paper" (Varian). Gancho na primeira pagina?
- "Make your paper look like your talk" (Varian). Get to the point?
- Resultado principal antes da p.15? (Board)
- Fluxo logico: Modelo → Resultados → Extensoes → Conclusao?
- Baseline resolvido antes de extensoes?

### ME2. Introducao
- "If you really know what your paper is about, you shouldn't find it hard to explain this in a couple of paragraphs" (Varian). Contribuicao clara nos primeiros paragrafos?
- Sem laundry lists de implicacoes (Board)
- Conteudo essencial: agentes, acoes, informacao, intuicoes dos resultados?
- Sem contexto excessivo motivando importancia do tema?
- Estrutura: puzzle → modelo e intuicao → literatura?

### ME3. Escrita e estilo (Thomson expandido)
- Frases curtas (Thomson)? Sem frase comecando com simbolo? Consistencia de voz e tempo?
- Sucinto — "Put the tedious stuff in the appendix" (Varian)?
- Termos tecnicos corretos? Footnotes usados com parcimonia? Apendice narrativo?

### ME4. Extensao e quando parar
- "Once you've made your point, stop" (Varian)
- "People only remember about 10 pages of your paper" (Varian)
- Resultado principal antes da p.15 (Board)
- Extensoes justificadas? Qualidade media > soma?
- Provas mecanicas no apendice?

### ME5. Uso de exemplos e intuicao
- Exemplos concretos para ilustrar modelo e resultados? (Dixit)
- "Every result should be explained in simple English unless it is obvious or technical" (Board)
- Exemplos geometricos > numericos (Thomson)?
- Exemplo motivador no inicio? Casos especiais como exemplos?

## Formato:

# Parecer de Exposicao do Modelo (Varian / Thomson / Board)

## Score: [1-10]

## Avaliacao por dimensao

### ME1. Estrutura do paper [Excelente / Adequada / Precisa melhorar / Problema serio]
[Avaliacao]

### ME2. Introducao [Excelente / Adequada / Precisa melhorar / Problema serio]
[Avaliacao]

### ME3. Escrita e estilo [Excelente / Adequado / Precisa melhorar / Problema serio]
[Checklist com exemplos do manuscrito]

### ME4. Extensao e quando parar [Enxuto / Adequado / Longo / Excessivo]
[Avaliacao]

### ME5. Uso de exemplos e intuicao [Excelente / Adequado / Insuficiente / Ausente]
[Avaliacao]

## Veredicto geral sobre exposicao
[Paragrafo sintetico]

## Top 5 sugestoes de melhoria
1. [Mais impactante primeiro — com exemplo concreto]

Tom: construtivo e especifico. Cada critica com exemplo do manuscrito e sugestao de melhoria.
```

---

### Passo 3: Carta Editorial Consolidada

Apos receber os TRES pareceres, voce (o editor-chefe) produz a carta editorial. NAO produza a carta antes de ter todos os tres pareceres.

```markdown
# Carta Editorial — Revisao de Modelo Formal

**Referencias**: Thomson (1999), Board & Meyer-ter-Vehn (2018), Dixit (2015), Varian (1997/2016)

## Decisao: [Rejeitar / Reject-and-Resubmit / R&R major / R&R minor / Aceitar]

## Scores consolidados
| Dimensao              | Score | Rating   |
|-----------------------|-------|----------|
| Design do modelo      | X/10  | [rating] |
| Apresentacao tecnica  | X/10  | [rating] |
| Exposicao             | X/10  | [rating] |
| **Global**            | X/10  | [rating] |

## Sintese editorial
[Paragrafo consolidando os tres pareceres. Qual e a principal forca e a principal fraqueza do paper? Onde as dimensoes se reforcam ou se contradizem?]

## Hierarquia aplicada: Design > Apresentacao > Exposicao
[Como a hierarquia se aplica a este paper? O design e forte o suficiente para justificar investir em melhorar apresentacao/exposicao? Ou o design e o bottleneck?]

## Prioridades para revisao (se aplicavel)
1. [Os 3-5 pontos mais importantes que o autor DEVE enderecar, ordenados por impacto na publicabilidade]

## Recomendacao estrategica ao autor
[Conselho honesto: vale a pena revisar para este journal? Ou seria mais produtivo reformular o modelo? Se o design e o problema, revisao extensiva da apresentacao provavelmente nao ajuda.]

---

## Parecer completo — Design do Modelo
[Cole o parecer do Agente 1 aqui]

## Parecer completo — Apresentacao Tecnica
[Cole o parecer do Agente 2 aqui]

## Parecer completo — Exposicao
[Cole o parecer do Agente 3 aqui]
```

---

## Salvar o relatorio

Apos produzir a carta editorial completa, salve-a em:

```
quality_reports/YYYY-MM-DD_review-formal-model.md
```

Use a data do dia. Esta e a UNICA escrita permitida.

---

## Regras

1. **NUNCA** produza os pareceres voce mesmo. Sempre use Task para criar os 3 agentes.
2. **LANCE OS 3 EM PARALELO** (mesma mensagem, tres tool calls).
3. **ESPERE** todos os tres retornarem antes de escrever a carta editorial.
4. A carta editorial e SUA sintese como editor — nao repita os pareceres, sintetize.
5. Seja honesto na recomendacao estrategica. Se o design do modelo e insuficiente, diga isso claramente e sugira proximo passo (reformulacao, simplificacao, etc).

## Idioma

A carta editorial e os pareceres devem ser escritos no **mesmo idioma do paper**. Se o paper esta em ingles, relatorio em ingles. Se em portugues, relatorio em portugues.

