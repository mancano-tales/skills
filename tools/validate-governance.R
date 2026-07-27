#!/usr/bin/env Rscript
# ==============================================================================
# validate-governance.R — QA de Governança para Planos e Logs de IA
# ==============================================================================

CWD <- getwd()
PATH_GOV_DIR <- if (dir.exists(file.path(CWD, "0-meta"))) "0-meta" else "9-vers"
PATH_PLAN_DIR <- file.path(CWD, PATH_GOV_DIR, "plan")
PATH_PLAN_INDEX <- file.path(PATH_PLAN_DIR, "README.md")
PATH_REVIEWS_INDEX <- file.path(CWD, PATH_GOV_DIR, "llm-reviews", "README.md")

cat_info <- function(...) cat("ℹ ", paste0(...), "\n")
cat_success <- function(...) cat("✅ ", paste0(...), "\n")
cat_warn <- function(...) cat("⚠ ", paste0(...), "\n")
cat_error <- function(...) cat("❌ ", paste0(...), "\n")

# Self-healing de links
if (file.exists("CLAUDE.md") && file.exists("AGENTS.md")) {
  c_claude <- readLines("CLAUDE.md", warn = FALSE, encoding = "UTF-8")
  c_agents <- readLines("AGENTS.md", warn = FALSE, encoding = "UTF-8")
  if (!identical(c_claude, c_agents)) {
    cat_warn("Divergência entre CLAUDE.md e AGENTS.md. Ressincronizando...")
    file.copy("CLAUDE.md", "AGENTS.md", overwrite = TRUE)
  }
}

if (file.exists(PATH_PLAN_INDEX) && file.exists(PATH_REVIEWS_INDEX)) {
  cat_success("Estrutura de governança e índices validados em ", PATH_GOV_DIR, "/")
  quit(status = 0)
} else {
  cat_error("Falha ao localizar índices de governança em ", PATH_GOV_DIR, "/")
  quit(status = 1)
}
