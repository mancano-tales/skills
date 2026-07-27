---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: math-guide
description: "Gerar guia matemático em PDF para provas de artigos com modelos formais"
argument-hint: "[arquivo do paper com provas formais]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

# Math Guide — Guia Matemático para Provas Formais

Gera um RMarkdown compilado em PDF que serve como guia autocontido de matemática para as provas de um paper com modelo formal. Não é livro-texto — é um documento focado que explica exatamente o que o leitor precisa saber para acompanhar cada demonstração.

## Público-alvo

Pesquisador com background em:
- Cálculo de uma variável (derivada, integral, TVI)
- Análise real básica (continuidade, convergência)
- Álgebra linear básica (autovalores)
- Game theory de graduação (Nash, intuição de ponto fixo)

Ajustar o nível se o usuário especificar outro background.

## Processo

### Fase 1: Extração

1. **Ler o paper completo** — incluir apêndices.
2. **Catalogar todos os resultados formais**: proposições, lemas, corolários, teoremas, provas (inclusive proof sketches e provas em apêndice).
3. **Para cada prova, identificar as ferramentas matemáticas**: quais teoremas, definições e técnicas são usados. Exemplos típicos:
   - Teoremas de ponto fixo (Brouwer, Banach/contração, Tarski, Kakutani, Schauder)
   - Teorema do Valor Intermediário, Teorema do Valor Médio
   - Análise de sinal via derivada
   - Teoria da ordem: lattices, mapas isotones, jogos supermodulares
   - Estática comparativa monótona (Milgrom & Roberts 1990, Topkis)
   - Distribuições log-côncavas e suas propriedades
   - Raio espectral, Perron-Frobenius, Gershgorin
   - Convergência dominada de Lebesgue
   - Topologia: compacidade, convexidade, espaços métricos completos
   - Correspondências (upper/lower hemicontinuity), Teorema do Máximo de Berge
   - Programação dinâmica, princípio da otimalidade de Bellman
   - Outros conforme o paper exigir

### Fase 2: Estruturação

Organizar o guia nas seguintes seções:

1. **Introdução** — objetivo, pré-requisitos assumidos, notação do paper
2. **Mapa: Prova → Pré-requisito** — tabela-resumo ligando cada resultado formal à ferramenta matemática e à seção do guia
3. **Seções temáticas** (uma por tópico matemático necessário), cada uma contendo:
   - Enunciado formal do teorema/definição (em ambiente `\begin{theorem}`)
   - Intuição em linguagem acessível
   - Prova ou sketch da prova quando instrutivo
   - Exemplo concreto (numérico quando possível)
   - Conexão explícita com a prova do paper ("Na Proposição X, esse teorema é usado para...")
   - Referências de livros-texto com capítulo/teorema específico
4. **Exercícios por seção** — 5 a 7 exercícios em escadinha de dificuldade:
   - Exercícios 1-2: verificação direta / cálculo simples
   - Exercícios 3-4: aplicação do conceito ao operador/modelo do paper
   - Exercícios 5-6: prova curta ou generalização
   - Exercício 7 (se houver): conexão entre temas ou contra-exemplo
   - Cada bloco termina com "Soluções na Seção X"
5. **Referências de livros-texto** — tabela por tópico com referência principal e alternativa (com capítulo/teorema)
6. **Soluções dos exercícios** — soluções completas e detalhadas, organizadas por seção

### Fase 3: Geração do RMarkdown

Criar arquivo `.Rmd` com:

**YAML header:**
```yaml
---
title: "Guia Matemático para as Provas do Paper"
subtitle: "[título do paper]"
author: "Documento auxiliar"
date: "`r Sys.Date()`"
output:
  pdf_document:
    latex_engine: xelatex
    toc: true
    toc_depth: 3
    number_sections: true
header-includes:
  - \usepackage{amsmath,amssymb,amsthm}
  - \usepackage{booktabs}
  - \usepackage{hyperref}
  - \newtheorem{theorem}{Teorema}[section]
  - \newtheorem{definition}[theorem]{Definição}
  - \newtheorem{proposition}[theorem]{Proposição}
  - \newtheorem{corollary}[theorem]{Corolário}
  - \newtheorem{lemma}[theorem]{Lema}
  - \newtheorem{example}[theorem]{Exemplo}
  - \newtheorem{remark}[theorem]{Observação}
  - \newcommand{\R}{\mathbb{R}}
  - \newcommand{\N}{\mathbb{N}}
  - \setlength{\parskip}{0.5em}
---
```

**Figuras R:** Incluir gráficos ilustrativos quando ajudarem (e.g., análise de sinal, ponto fixo visual, convergência). Usar `fig.cap` para legendas.

**Cuidados com LaTeX:**
- Em ambientes `\begin{theorem}[...]`, se o texto entre colchetes contém `[` ou `]`, envolver com `{...}`: `\begin{theorem}[{texto com $[0,1]$}]`
- Não usar `\usepackage{mathtools}` (causa problemas com TinyTeX desatualizado)
- Não usar `\usepackage{tikz}` salvo se necessário e testado

### Fase 4: Compilação

1. Salvar o `.Rmd` no mesmo diretório do paper (ou onde o usuário indicar)
2. Compilar com `rmarkdown::render()` via Bash
3. Se houver erro LaTeX:
   - Identificar o pacote/comando problemático
   - Substituir por alternativa compatível
   - Recompilar
4. Reportar número de páginas do PDF final

## Regras

- **Língua**: português brasileiro para o texto, notação matemática em inglês conforme convenção
- **Tamanho alvo**: 15-25 páginas (sem exercícios ~12-18, com exercícios ~20-30)
- **Autocontido**: o leitor não precisa abrir outro livro para entender o guia. As referências são para quem quiser ir mais fundo
- **Conectado ao paper**: toda definição/teorema deve ter uma subseção "Conexão com o paper" dizendo onde é usado
- **Exercícios graduados**: sempre do mais fácil ao mais difícil, com saltos pequenos. O exercício mais fácil deve ser acessível a alguém que acabou de ler a seção. O mais difícil deve exigir combinar ideias
- **Soluções completas**: não apenas "a resposta é X", mas o raciocínio passo a passo
- **Sem over-engineering**: não explicar tópicos que não aparecem nas provas do paper

## Formato de saída

```
[diretório]/math_guide_proofs.Rmd  (fonte)
[diretório]/math_guide_proofs.pdf  (compilado)
```

## Checklist final

- [ ] PDF compila sem erros
- [ ] Todas as proposições/lemas/corolários do paper estão mapeados na tabela
- [ ] Cada teorema tem: enunciado formal, intuição, exemplo, conexão com o paper
- [ ] Referências de livros-texto com capítulos específicos
- [ ] 5-7 exercícios por tema, em escadinha de dificuldade
- [ ] Soluções completas no final

