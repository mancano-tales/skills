---
autor: "Manoel Galdino (mgaldino/agents-workflow)"
name: deploy
description: "Render RMarkdown + deploy para GitHub Pages"
argument-hint: "[arquivo .Rmd ou diretório do projeto]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

# Deploy: Render RMarkdown + GitHub Pages

Compile um documento ou site RMarkdown e faça deploy para GitHub Pages.

## Processo

### 1. Identificar tipo de projeto
- **Documento único**: Um `.Rmd` que gera HTML
- **Site rmarkdown**: Projeto com `_site.yml`
- **Bookdown**: Projeto com `_bookdown.yml`
- **Distill/blog**: Projeto com `_site.yml` usando `distill`

### 2. Render

Para documento único:
```bash
Rscript -e "rmarkdown::render('[arquivo].Rmd', output_format = 'html_document', output_dir = 'docs')"
```

Para site completo:
```bash
Rscript -e "rmarkdown::render_site()"
```

Para bookdown:
```bash
Rscript -e "bookdown::render_book('index.Rmd', output_dir = 'docs')"
```

### 3. Preparar para GitHub Pages
- Verifique se o output está em `docs/` (padrão do GitHub Pages)
- Crie `.nojekyll` na raiz de `docs/` se não existir:
  ```bash
  touch docs/.nojekyll
  ```
- Verifique se `docs/index.html` existe

### 4. Commit e Push
Antes de executar, **confirme com o usuário**:
```bash
git add docs/
git commit -m "Update rendered site"
git push origin main
```

### 5. Verificar deploy
- Confirme que GitHub Pages está configurado para servir de `docs/` no branch `main`
- URL esperada: `https://[username].github.io/[repo-name]/`

## Troubleshooting

- Se `docs/` não existe, crie com `mkdir -p docs`
- Se GitHub Pages não está habilitado, instrua o usuário a habilitar em Settings > Pages
- Para sites com paths relativos quebrados, verifique `base_url` no `_site.yml`
- Se imagens não aparecem, verifique se estão em `docs/` e com caminhos relativos

