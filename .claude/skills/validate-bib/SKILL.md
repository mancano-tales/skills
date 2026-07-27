---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: validate-bib
description: "Validar referências cruzadas de citações"
argument-hint: "[arquivo .Rmd/.tex e arquivo .bib]"
allowed-tools: ["Read", "Glob", "Grep"]
---

# Validar Bibliografia

Valide a consistência entre citações no texto e entradas no arquivo .bib.

## Processo

### 1. Identificar arquivos
- Localize o arquivo principal (.Rmd, .tex, .qmd, ou .md)
- Localize o arquivo .bib referenciado no YAML header ou \bibliography{}
- Se houver múltiplos .bib, considere todos

### 2. Extrair citações do texto

Procure por padrões de citação:
- **RMarkdown/Quarto**: `@chave`, `[@chave]`, `[@chave1; @chave2]`, `-@chave`
- **LaTeX**: `\cite{chave}`, `\citep{chave}`, `\citet{chave}`, `\citeauthor{chave}`, `\citeyear{chave}`, `\autocite{chave}`, `\textcite{chave}`

### 3. Extrair entradas do .bib

Liste todas as chaves definidas no .bib (campos @article, @book, @incollection, @inproceedings, @techreport, @unpublished, @misc, etc.)

### 4. Cruzar referências

Identifique:
- **Citações órfãs**: Citadas no texto mas ausentes do .bib
- **Entradas fantasma**: No .bib mas nunca citadas no texto
- **Chaves suspeitas**: Possíveis typos (ex: `smith2020` vs `Smith2020`, ou `smith2020a` vs `smith2020`)

### 5. Validar qualidade do .bib

Para cada entrada, verifique:
- Campos obrigatórios estão presentes (author, title, year, journal/publisher)?
- Ano é plausível?
- Há duplicatas (mesma obra com chaves diferentes)?
- Nomes de autores estão consistentes?
- Títulos estão com capitalização preservada (entre `{}`)?
- DOI está presente quando possível?
- Páginas estão no formato correto?

## Formato do output

```markdown
# Validação Bibliográfica

## Resumo
- Total de citações no texto: N
- Total de entradas no .bib: M
- Citações órfãs: X
- Entradas não citadas: Y
- Entradas com problemas: Z

## Citações órfãs (no texto, ausentes do .bib) 🔴
| Chave | Arquivo | Linha |
|-------|---------|-------|
| @smith2020 | paper.Rmd | 45 |

## Entradas não citadas (no .bib, ausentes do texto) 🟡
| Chave | Referência |
|-------|-----------|
| jones2019 | Jones, A. (2019). Title... |

## Possíveis duplicatas 🟡
| Chave 1 | Chave 2 | Provável duplicata de |
|---------|---------|----------------------|

## Problemas de qualidade no .bib 🟡
| Chave | Problema | Sugestão |
|-------|----------|----------|
| smith2020 | Faltando journal | Adicionar journal = {...} |

## Entradas OK ✅
[N entradas sem problemas]
```

