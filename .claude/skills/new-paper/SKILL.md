---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: new-paper
description: "Scaffolding completo de paper empírico (pastas, templates, CLAUDE.md)"
argument-hint: "Nome do Projeto"
allowed-tools: ["Bash", "Write", "Read", "Glob"]
---

# Scaffold de Paper Empírico

Cria a estrutura completa de diretórios e arquivos-template para um novo paper empírico.

## Invocação

```
/new-paper Nome do Projeto
```

## Processo

### 1. Derivar o slug

Converta o nome do projeto para slug: lowercase, espaços → hífens, remover acentos e caracteres especiais.

- "Trade and Democracy" → `trade-and-democracy`
- "Included Variable Bias" → `included-variable-bias`

### 2. Definir o diretório-base

```
/Users/manoelgaldino/Documents/DCP/Papers/[slug]/
```

**IMPORTANTE**: Antes de criar, verifique se o diretório já existe. Se existir, PARE e informe o usuário.

### 3. Criar a árvore de diretórios

Crie todos os diretórios de uma vez:

```bash
mkdir -p /Users/manoelgaldino/Documents/DCP/Papers/[slug]/{paper,talks,code/functions,data/{raw,processed,metadata},output/{figures,tables,models},quality_reports/plans,replication,references_pdfs,explorations,notes}
```

### 4. Criar arquivos com conteúdo

Crie cada arquivo abaixo usando a ferramenta Write. Use os templates EXATAMENTE como especificados.

---

#### 4.1 CLAUDE.md

Caminho: `[slug]/CLAUDE.md`

```markdown
# [Nome do Projeto] — Contexto para Claude Code

## O que é este projeto

[Descrever brevemente o paper: pergunta de pesquisa, método, dados.]

## Estrutura do repositório

\```
[slug]/
├── CLAUDE.md
├── [slug].Rproj
├── references.bib
│
├── paper/
│   ├── paper.Rmd
│   ├── preamble.tex
│   └── appendix.Rmd
│
├── talks/
│
├── code/
│   ├── 99_run_all.R
│   └── functions/
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── metadata/
│
├── output/
│   ├── figures/
│   ├── tables/
│   └── models/
│
├── quality_reports/
│   └── plans/
│
├── replication/
├── references_pdfs/
├── explorations/
├── notes/
│
└── .gitignore
\```

## Workflow obrigatório

1. **Plano em disco** antes de implementar qualquer análise (quality_reports/plans/)
2. **Review de código** via skill `review-r` antes de rodar scripts
3. **NÃO rodar** scripts sem aprovação do usuário
4. **NÃO commitar** sem instrução explícita

## Convenções de código

- **Linguagem**: R
- **Dados**: `data.table` para manipulação
- **Regressões**: `fixest` para modelos com efeitos fixos
- **Tabelas**: `modelsummary` para output formatado
- **Figuras**: `ggplot2`, salvas em `output/figures/` como PNG 150 dpi
- **Resultados intermediários**: CSV via `data.table::fwrite()`
- **Master script**: `code/99_run_all.R` orquestra a pipeline com `source()` calls
- **Nomenclatura de scripts**: `01_clean.R`, `02_merge.R`, `03_analysis.R`, etc.
- **Sessão**: `sessionInfo()` no final de cada script de análise

## Subagentes e permissões

- **Subagentes em background NÃO conseguem pedir permissão ao usuário.** Se uma skill ou tool exige permissão, o prompt não aparece e a permissão é negada silenciosamente.
- **Sempre que um subagente tiver permissão negada, avisar o usuário imediatamente.**
- **Skills (review-r, review-paper, etc.) devem ser rodadas em foreground.**
```

**IMPORTANTE**: No CLAUDE.md gerado, os blocos de código (```) devem ser renderizados corretamente — não escape os backticks.

---

#### 4.2 [slug].Rproj

Caminho: `[slug]/[slug].Rproj`

```
Version: 1.0

RestoreWorkspace: No
SaveWorkspace: No
AlwaysSaveHistory: Default

EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8

RnwWeave: knitr
LaTeX: XeLaTeX

AutoAppendNewline: Yes
StripTrailingWhitespace: Yes
```

---

#### 4.3 references.bib

Caminho: `[slug]/references.bib`

```bib
% Bibliography for [Nome do Projeto]
% Add references in BibTeX format below
```

---

#### 4.4 paper/paper.Rmd

Caminho: `[slug]/paper/paper.Rmd`

````markdown
---
title: "[Nome do Projeto]"
author: ""
date: "`r format(Sys.Date(), '%B %d, %Y')`"
output:
  pdf_document:
    latex_engine: xelatex
    keep_tex: false
    includes:
      in_header: preamble.tex
bibliography: ../references.bib
biblio-style: apalike
link-citations: true
abstract: |
  [Abstract placeholder.]
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = FALSE,
  message = FALSE,
  warning = FALSE,
  fig.path = "../output/figures/",
  fig.width = 6,
  fig.height = 4,
  dpi = 150
)

library(data.table)
library(fixest)
library(ggplot2)
library(modelsummary)
```

# Introduction

[Introduction placeholder.]

# Theory / Background

[Theory placeholder.]

# Data

[Data description placeholder.]

```{r load-data, eval=FALSE}
# dt <- fread("../data/processed/analysis_data.csv")
```

# Empirical Strategy

[Empirical strategy placeholder.]

# Results

[Results placeholder.]

```{r main-results, eval=FALSE}
# mod1 <- feols(y ~ treatment | unit + year, data = dt)
# modelsummary(list("Model 1" = mod1), output = "../output/tables/main_results.tex")
```

# Conclusion

[Conclusion placeholder.]

# References
````

---

#### 4.5 paper/preamble.tex

Caminho: `[slug]/paper/preamble.tex`

```latex
% Preamble for [Nome do Projeto]
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{booktabs}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{natbib}
\usepackage{setspace}
\usepackage{float}
\usepackage{caption}

% Hyperref settings
\hypersetup{
  colorlinks=true,
  linkcolor=blue,
  citecolor=blue,
  urlcolor=blue
}
```

---

#### 4.6 paper/appendix.Rmd

Caminho: `[slug]/paper/appendix.Rmd`

````markdown
---
title: "Appendix — [Nome do Projeto]"
author: ""
date: "`r format(Sys.Date(), '%B %d, %Y')`"
output:
  pdf_document:
    latex_engine: xelatex
    includes:
      in_header: preamble.tex
bibliography: ../references.bib
biblio-style: apalike
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = FALSE,
  message = FALSE,
  warning = FALSE,
  fig.path = "../output/figures/appendix_",
  dpi = 150
)
```

# Appendix A: Additional Tables

[Tables placeholder.]

# Appendix B: Additional Figures

[Figures placeholder.]

# Appendix C: Robustness Checks

[Robustness placeholder.]

# References
````

---

#### 4.7 code/99_run_all.R

Caminho: `[slug]/code/99_run_all.R`

```r
# ============================================================================
# Master script — [Nome do Projeto]
# ============================================================================
# Run all analysis scripts in order.
# Usage: source("code/99_run_all.R") from the project root.
# ============================================================================

cat("=== [Nome do Projeto] — Master Script ===\n")
cat("Start:", format(Sys.time()), "\n\n")

# --- Data preparation ---
# source("code/01_clean.R")
# source("code/02_merge.R")

# --- Analysis ---
# source("code/03_analysis.R")

# --- Tables and figures ---
# source("code/04_tables.R")
# source("code/05_figures.R")

cat("\n=== Done ===\n")
cat("End:", format(Sys.time()), "\n")
sessionInfo()
```

---

#### 4.8 .gitignore

Caminho: `[slug]/.gitignore`

```
# Data (raw data should not be committed)
data/raw/

# Large R objects
*.rds

# R cache and temp files
*_cache/
*_files/
.Rhistory
.RData
.Rproj.user/

# LaTeX intermediates
*.aux
*.log
*.out
*.synctex.gz
*.fls
*.fdb_latexmk
*.bbl
*.blg

# OS files
.DS_Store
Thumbs.db

# Output (regenerable)
output/figures/*.png
output/tables/*.tex
output/models/*.rds
```

---

### 5. Confirmar sucesso

Após criar todos os arquivos:

1. Liste a árvore completa com `find [slug] -type f | sort` e apresente ao usuário
2. Informe: "Scaffold criado em `/Users/manoelgaldino/Documents/DCP/Papers/[slug]/`"
3. Lembre o usuário:
   - Preencher a seção "O que é este projeto" no CLAUDE.md
   - Adicionar o author no paper.Rmd
   - Inicializar git se desejar (`git init`)

## O que esta skill NÃO faz

- Não inicializa git (decisão do usuário)
- Não cria arquivos dentro de `talks/` (só o diretório vazio)
- Não adiciona ao dashboard (a regra de dashboard-update cuida disso na primeira sessão substantiva)

