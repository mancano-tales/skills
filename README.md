# 🚀 Skills Repository

Repositório central de **Skills customizadas** e de governança para assistentes de IA (Antigravity, Claude Code, OpenAI, Gemini).

---

## 🛠️ Skills Disponíveis

### 🎨 Skills Autorais Customizadas

| Skill | Descrição |
| :--- | :--- |
| [**`tts-html-builder`**](./.claude/skills/tts-html-builder/SKILL.md) | Converte resumos, artigos e documentos em páginas HTML ou arquivos Quarto (.qmd) limpos otimizados para leitor de voz (TTS), contendo player interativo nativo (Web Speech API) com botões de ouvir/pausar, avançar/voltar parágrafo, velocidade (0.5x-3.0x), seleção de voz e destaque visual sincronizado sem descompasso. |

### 🔄 Skills Compartilhadas de Governança e Automação

| Skill | Função |
| :--- | :--- |
| [**`close-task`**](./.claude/skills/close-task/SKILL.md) | Conclui tarefas com exportação de logs, atualizações de `NEWS.md` e `TODO.md`. |
| [**`code-review`**](./.claude/skills/code-review/SKILL.md) | Revisão paralela de código em eixos de especificação e padrões. |
| [**`edit-article`**](./.claude/skills/edit-article/SKILL.md) | Edição e aprimoramento de artigos e prosa acadêmica. |
| [**`export-conversation`**](./.claude/skills/export-conversation/SKILL.md) | Exporta conversas de IA para Markdown formatado. |
| [**`git-cleanup`**](./.claude/skills/git-cleanup/SKILL.md) | Organiza pendências do git com staging cirúrgico e commits temáticos. |
| [**`grill-me`**](./.claude/skills/grill-me/SKILL.md) | Entrevista estruturada para desafiar e afiar decisões de design/arquitetura. |
| [**`grill-with-docs`**](./.claude/skills/grill-with-docs/SKILL.md) | Entrevista com geração automatizada de ADRs e glossários. |
| [**`grilling`**](./.claude/skills/grilling/SKILL.md) | Entrevista técnica intensa sobre planos e ideias. |
| [**`pdf-text-extractor`**](./.claude/skills/pdf-text-extractor/SKILL.md) | Extrai texto e markdown de PDFs locais para economia de tokens. |
| [**`request-audit`**](./.claude/skills/request-audit/SKILL.md) | Gera um prompt de auditoria (Red-Teaming) com evidências mecânicas. |
| [**`sync-skills`**](./.claude/skills/sync-skills/SKILL.md) | SOP para sincronizar skills com o repositório-mãe. |

---

## 🤖 Interoperabilidade Multiagente

Este repositório foi construído para funcionar nativamente com qualquer assistente de IA:

- **Claude Code**: Lê `.claude/skills/` e [`CLAUDE.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/CLAUDE.md).
- **Google Antigravity & Gemini**: Leem `.agents/skills/` (Junction NTFS apontando para `.claude/skills/`) e [`AGENTS.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/AGENTS.md).
- **OpenAI / Codex / Custom Agents**: Leem [`AGENTS.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/AGENTS.md) (hard link para `CLAUDE.md`).
- **GitHub Copilot**: Lê [`.github/copilot-instructions.md`](file:///c:/Users/Mancano/Documents/MancanoSync/skills/.github/copilot-instructions.md) (hard link para `CLAUDE.md`).

---

## 🔄 Sincronização & Automação (Git Hooks)

### 📊 Como Verificar Sincronização
Para verificar o status das skills no terminal (Windows, Mac ou Linux):
```bash
# No Windows (PowerShell):
.\tools\sync-skills.ps1

# No Mac / Linux (Bash):
./tools/sync-skills.sh
```

### ⚡ Atualização & Commit Automatizado
Para atualizar e commitar automaticamente no padrão **Conventional Commits**:
```bash
# Atualizar todas as skills e commitar com mensagem padronizada:
.\tools\sync-skills.ps1 -Apply all -Commit
```

### 🪝 Git Hooks em Segundo Plano
O repositório inclui Git Hooks ativos (`post-merge` e `post-checkout` em `hooks/`) que rodam o verificador em segundo plano sempre que você fizer um `git pull` ou trocar de branch, avisando se houver skills desatualizadas.

---

## 📌 Licença
MIT - Sinta-se livre para usar, modificar e compartilhar.
