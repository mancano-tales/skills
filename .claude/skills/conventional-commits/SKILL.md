---
name: conventional-commits
description: Padroniza mensagens de commit segundo Conventional Commits 1.0.0, alinha os tipos a Semantic Versioning 2.0.0 e mantém o changelog no padrão Keep a Changelog 1.1.0. Inclui hook commit-msg para validação mecânica. Ative ao escrever mensagens de commit, ao montar ou revisar entradas de NEWS.md/CHANGELOG.md, ao configurar travas de governança de histórico Git, ou quando o usuário pedir padronização de commits.
---

# Conventional Commits: Governança de Histórico Git

Esta skill cobre três padrões que só funcionam juntos: **Conventional Commits 1.0.0**
(forma da mensagem), **Semantic Versioning 2.0.0** (o que a mensagem implica para a
versão) e **Keep a Changelog 1.1.0** (como a mensagem vira registro público).

---

## 1. Sintaxe da mensagem

```
<tipo>(<escopo opcional>): <descrição no imperativo>

<corpo opcional>

<rodapé opcional>
```

Regras que a validação mecânica cobra:

- **Tipo** em minúsculas, da lista fechada da seção 2.
- **Escopo** opcional, entre parênteses, minúsculo, sem espaços — a área tocada
  (`website`, `govrn`, `hooks`, `news`).
- **Dois-pontos e um espaço** separando o cabeçalho da descrição.
- **Descrição no imperativo presente**: "adiciona", não "adicionado" nem "adicionando".
- **Sem ponto final** e, por convenção deste ecossistema, **sem emojis**.
- **Primeira linha ≤ 72 caracteres.** O corpo vai depois de uma linha em branco.

```
feat(website): adiciona versao em ingles da pagina do seminario
fix(hooks): corrige deteccao de contexto no validador de governanca
docs(news): retifica o padrao de rastreabilidade do changelog
```

---

## 2. Tipos e o que cada um implica em SemVer

| Tipo | Uso | Efeito em SemVer |
| :--- | :--- | :--- |
| `feat` | Nova funcionalidade ou arquivo estrutural | **MINOR** |
| `fix` | Correção de defeito, erro de compilação, link quebrado | **PATCH** |
| `docs` | Só documentação | nenhum |
| `style` | Formatação, layout, espaçamento — sem mudar comportamento | nenhum |
| `refactor` | Reorganização sem alterar comportamento observável | nenhum |
| `perf` | Ganho de desempenho | **PATCH** |
| `test` | Testes e scripts de validação | nenhum |
| `build` | Sistema de build ou dependências | nenhum |
| `ci` | Configuração de integração contínua | nenhum |
| `chore` | Manutenção rotineira, `.gitignore` | nenhum |
| `revert` | Reversão de commit anterior | contextual |

**Breaking change** eleva para **MAJOR** e se marca de duas formas — use as duas:

```
feat(hooks)!: exige GOV_DIR explicito na configuracao

BREAKING CHANGE: repositorios que dependiam da deteccao automatica de
9-vers/ precisam declarar GOV_DIR no AGENTS.md.
```

---

## 3. Changelog no padrão Keep a Changelog 1.1.0

Categorias fixas, nesta ordem: `Added` · `Changed` · `Deprecated` · `Removed` ·
`Fixed` · `Security`. Repositórios de governança podem acrescentar
`Security & Governance` como agrupamento local.

Uma entrada descreve **a consequência para quem lê**, não o diff:

```markdown
## [2026-07-30]

### Added
- **2026-07-30 18:05** — Versão em inglês do site (`website/en.qmd`): página
  paralela com seletor PT | EN. Optou-se por duas páginas em vez de alternador
  JavaScript porque o sumário lateral do Quarto duplicaria os `id`.
```

Registre o **porquê** quando houve escolha entre alternativas. O `git log` já guarda o
que mudou; o changelog existe para guardar o que o `git log` não consegue guardar.

---

## 4. Não escreva o hash do commit no arquivo versionado

Uma armadilha recorrente é exigir que cada entrada do changelog carregue o hash do
commit que a introduziu:

```markdown
- **`[a1b2c3d]` 2026-07-30 15:45** — Adicionada trava de validação.
```

**Isso é insatisfazível em um único commit.** O hash é o SHA do conteúdo do commit;
escrever o hash dentro de um arquivo que o commit versiona altera o conteúdo e, portanto,
o hash. É um problema de ponto fixo. `git commit --amend` não resolve — produz um hash
novo, igualmente não registrado.

Quem tenta cumprir a regra acaba com um commit de correção depois de cada commit real
(`docs(news): backfill do hash`), o que dobra o histórico e ainda deixa o hash do próprio
commit de correção sem registro.

**O hash já está no Git.** Copiá-lo à mão para um arquivo rastreado é desnormalização, e
como todo dado desnormalizado só pode divergir. As saídas corretas:

1. **Derivar em vez de armazenar.** O changelog-fonte não tem hash; um script gera, sob
   demanda ou no CI, uma versão anotada a partir de `git log`.
2. **Referenciar o que já existe.** Numa release, `git log <tag>..HEAD` reconstrói a
   correspondência sem nenhum dado duplicado.
3. **Ancorar em pull request.** Onde o fluxo é por PR, o número do PR é estável, é
   conhecido antes do merge e não muda com rebase — ao contrário do hash.

---

## 5. Validação mecânica

O hook em [`scripts/commit-msg`](./scripts/commit-msg) rejeita mensagens fora do padrão.
Instale-o no repositório-alvo:

```bash
cp scripts/commit-msg hooks/commit-msg
chmod +x hooks/commit-msg
git config core.hooksPath hooks
```

O hook separa deliberadamente o que **bloqueia** do que apenas **avisa**:

| Verificação | Ação | Por quê |
| :--- | :--- | :--- |
| Cabeçalho fora de `<tipo>(<escopo>): <descrição>` | bloqueia | objetivo |
| Tipo fora da lista fechada | bloqueia | objetivo |
| Cabeçalho > 72 caracteres | bloqueia | objetivo |
| Ponto final no cabeçalho | bloqueia | objetivo |
| `BREAKING CHANGE:` no rodapé sem `!` no cabeçalho | bloqueia | objetivo |
| Descrição em gerúndio ou particípio | **avisa** | heurística falível |
| `Merge`, `Revert`, `fixup!`, `squash!` | ignora | o Git gera sozinho |

A checagem de imperativo é heurística de sufixo e não distingue verbo de substantivo:
`estado`, `comando`, `pedido` e `conteúdo` casam com os mesmos padrões. Bloquear com base
nisso rejeitaria mensagens corretas — e **falso bloqueio é a principal causa de recurso a
`--no-verify`**, o que custa mais governança do que a regra compra. Bloqueio fica
reservado ao que é objetivamente verificável.

**Limites que você deve comunicar ao usuário, não esconder:**

- `core.hooksPath` é configuração **local**. Um clone novo não herda hook nenhum — quem
  clonar precisa rodar o setup, ou não haverá validação alguma.
- `git commit --no-verify` desliga todos os hooks. Nenhum hook client-side resiste a isso.
- Um hook versionado **não se protege**: um commit que substitua o próprio hook por
  `exit 0` passa pela validação e desarma as seguintes.

Onde a garantia precisa ser real, o mesmo validador tem de rodar no CI, em máquina que o
autor do commit não controla, e ser exigido como *status check* na proteção de branch.
O hook local é ergonomia — retorno rápido para quem age de boa-fé. Ele não é controle.

---

## 6. Antipadrões

| Errado | Certo | Motivo |
| :--- | :--- | :--- |
| `update files` | `refactor(govrn): reorganiza indice de planos` | Sem tipo nem escopo |
| `feat: Adicionado o site` | `feat(website): adiciona pagina do seminario` | Particípio em vez de imperativo |
| `fix: corrige bug.` | `fix(hooks): corrige deteccao de contexto` | Ponto final; "bug" não diz o quê |
| `feat: muda API e corrige typo e ajusta CSS` | três commits | Um commit, uma intenção |
| `chore: mudancas` | descreva a mudança | `chore` não é gaveta de despejo |

---

## 7. Checklist antes de commitar

- [ ] Tipo pertence à lista fechada e reflete a intenção real da mudança.
- [ ] Descrição no imperativo, ≤ 72 caracteres, sem ponto final.
- [ ] Breaking change marcado com `!` **e** rodapé `BREAKING CHANGE:`.
- [ ] Changelog atualizado na categoria certa, dizendo a consequência e o porquê.
- [ ] Nenhum hash escrito à mão no changelog (seção 4).
- [ ] Staging cirúrgico: `git add <arquivo>`, nunca `git add .` nem `git add -A`.
- [ ] Um commit, uma intenção.
