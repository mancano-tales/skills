---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: compile-rmd
description: "Compilar RMarkdown (PDF/HTML via rmarkdown::render)"
argument-hint: "[arquivo .Rmd e formato: pdf|html]"
allowed-tools: ["Read", "Bash", "Glob", "Grep"]
---

# Compilar RMarkdown

Compile um documento RMarkdown para PDF ou HTML.

## Processo

1. **Identificar o arquivo**: Localize o arquivo .Rmd especificado. Se nenhum for dado, procure o .Rmd mais recente no diretório atual.

2. **Verificar dependências**: Antes de compilar, verifique:
   - O YAML header está bem formado (title, author, date, output)
   - Pacotes usados nos chunks estão instalados
   - Dados referenciados existem nos caminhos indicados
   - Arquivo .bib existe se bibliography está no YAML

3. **Compilar**: Execute o comando de render apropriado:

   Para PDF:
   ```bash
   Rscript -e "rmarkdown::render('[arquivo].Rmd', output_format = 'pdf_document')"
   ```

   Para HTML:
   ```bash
   Rscript -e "rmarkdown::render('[arquivo].Rmd', output_format = 'html_document')"
   ```

   Para Bookdown:
   ```bash
   Rscript -e "bookdown::render_book('index.Rmd')"
   ```

4. **Diagnosticar erros**: Se a compilação falhar:
   - Leia o log de erro completo
   - Identifique o chunk problemático
   - Verifique se é erro de LaTeX (para PDF) ou de código R
   - Sugira correção específica
   - Para erros de LaTeX, verifique se `tinytex` está instalado: `tinytex::is_tinytex()`

5. **Confirmar sucesso**: Reporte o caminho do arquivo gerado e tamanho.

## Opções comuns de YAML

```yaml
output:
  pdf_document:
    latex_engine: xelatex  # melhor suporte a Unicode/português
    keep_tex: true
    citation_package: biblatex
  html_document:
    theme: cosmo
    toc: true
    toc_float: true
    code_folding: hide
```

## Dicas

- Use `xelatex` como engine para documentos em português (suporte a acentos)
- Para tabelas grandes, use `kableExtra` com `latex_options = c("hold_position", "scale_down")`
- Se houver erro de memória, aumente com `options(java.parameters = "-Xmx4g")` antes de render

