---
name: data-collection
description: "Coleta estruturada de dados online: descoberta de fontes, download via API/bulk/scraping, gestão de credenciais, documentação rastreável e reproduzível. Use quando o usuário precisar baixar dados, montar pipeline de coleta, achar bases de dados sobre um tema, configurar acesso a APIs governamentais ou acadêmicas, ou organizar dados brutos de forma auditável — mesmo que não diga explicitamente 'coleta de dados'."
argument-hint: "[tema, fonte ou URL dos dados]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Agent", "WebSearch", "WebFetch", "AskUserQuestion"]
---

# Coleta Estruturada de Dados

Você conduz o processo completo de descoberta, download, validação e documentação de dados para pesquisa acadêmica. O objetivo é que qualquer pessoa consiga reproduzir a coleta meses ou anos depois, apenas seguindo os scripts e a documentação gerada.

## Princípios

- **Raw é sagrado**: dados baixados nunca são modificados. Transformações geram novos arquivos em `processed/`.
- **Script-first**: todo download deve ser reproduzível via script. Nunca oriente o usuário a "clicar e baixar manualmente" se existir alternativa programática.
- **Documentar na hora**: a documentação é escrita junto com o script, não depois. Se você baixou, documente imediatamente em SOURCES.yaml e DATA_DICTIONARY.md.
- **CSV como formato padrão**: dados processados sempre em CSV (UTF-8, vírgula como separador). Dados brutos mantêm formato original.
- **Python por padrão**: use Python exceto quando um pacote R pronto resolva melhor (ex: `geobr`, `basedosdados`). Nesse caso, escreva script R.

## Fluxo de trabalho

### 1. Entender a necessidade

Antes de buscar qualquer dado, esclareça:
- Qual a pergunta de pesquisa ou variável necessária?
- Qual a unidade de análise (país, município, indivíduo, firma)?
- Qual o período temporal?
- Qual a cobertura geográfica?

Se o usuário não especificou, pergunte. Dados errados na granularidade certa custam menos que dados certos na granularidade errada.

### 2. Descobrir fontes

Pesquise sistematicamente, nesta ordem de preferência:

**Fontes primárias (preferir sempre)**:
- APIs oficiais de órgãos governamentais
- Portais de dados abertos (dados.gov.br, data.gov, data.europa.eu)
- Bases de organismos internacionais (World Bank, IMF, OECD, UN)

**Repositórios acadêmicos**:
- Harvard Dataverse, ICPSR, Zenodo, figshare
- Repositórios de replicação vinculados a papers específicos
- Base dos Dados (basedosdados.org) — hub brasileiro com dados tratados

**Bases especializadas em Ciência Política/RI**:
- V-Dem, Polity V, Freedom House
- Correlates of War, UCDP/PRIO
- CEPII (comércio internacional), Penn World Table
- QoG (Quality of Government), WVS (World Values Survey)

**Web scraping** (último recurso):
- Só quando não há API, download bulk, ou repositório
- Verificar robots.txt e termos de uso antes
- Implementar rate limiting e retry com backoff

Para cada fonte encontrada, registre: nome, URL, tipo de acesso (API/download/scraping), se precisa credencial, e licença de uso.

Apresente as opções ao usuário com prós/contras antes de prosseguir com o download.

### 3. Configurar o projeto

Crie a estrutura de diretórios no local indicado pelo usuário (ou na pasta `data/` do projeto atual):

```
data/
├── raw/                    # Dados brutos (nunca modificar)
├── processed/              # CSVs limpos
├── scripts/
│   ├── download_<fonte>.py # Um script por fonte
│   ├── process_<fonte>.py  # Limpeza/transformação
│   └── requirements.txt    # Dependências Python
├── docs/
│   ├── SOURCES.yaml        # Manifesto de fontes
│   ├── DATA_DICTIONARY.md  # Dicionário de variáveis
│   └── COLLECTION_LOG.md   # Relatório de completude e gaps
├── .env.example            # Template de credenciais
├── .gitignore              # Exclui .env e arquivos grandes
├── checksums.sha256        # Integridade dos arquivos
└── README.md               # Instruções de reprodução
```

### 4. Gestão de credenciais

Quando uma fonte exigir autenticação:

1. **Pergunte ao usuário** qual credencial é necessária (API key, token, usuário/senha)
2. **Crie `.env.example`** com os nomes das variáveis e instruções de como obter:
   ```
   # World Bank API (obter em: https://data.worldbank.org/api)
   WORLDBANK_API_KEY=sua_chave_aqui

   # Harvard Dataverse (obter em: https://dataverse.harvard.edu/dataverseuser.xhtml?selectTab=apiTokenTab)
   DATAVERSE_API_TOKEN=seu_token_aqui
   ```
3. **Peça ao usuário** para fornecer os valores. Armazene em `.env` (nunca no código).
4. **Verifique que `.gitignore`** contém `.env`
5. Nos scripts, carregue com `python-dotenv`:
   ```python
   from dotenv import load_dotenv
   import os
   load_dotenv()
   api_key = os.getenv("WORLDBANK_API_KEY")
   ```

Nunca escreva credenciais diretamente em scripts ou logs.

### 5. Escrever scripts de download

Cada script de download deve seguir este padrão:

```python
#!/usr/bin/env python3
"""Download de [descrição] da fonte [nome].

Fonte: [URL da documentação da API/portal]
Acesso: [API | bulk download | scraping]
Credenciais: [sim/não — variável em .env]
Última execução: [data]
"""

import logging
from pathlib import Path
from datetime import datetime

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")
logger = logging.getLogger(__name__)

RAW_DIR = Path(__file__).parent.parent / "raw"
RAW_DIR.mkdir(parents=True, exist_ok=True)


def download():
    """Função principal de download."""
    logger.info("Iniciando download de [fonte]...")

    # ... lógica de download ...

    output_path = RAW_DIR / f"fonte_nome_{datetime.now():%Y%m%d}.csv"
    # ... salvar arquivo ...

    logger.info(f"Salvo em {output_path}")
    return output_path


if __name__ == "__main__":
    download()
```

**Padrões obrigatórios nos scripts:**
- Logging com timestamps (não print)
- Paths relativos via `pathlib` (portabilidade)
- Retry com backoff exponencial para requisições HTTP
- Salvar com data no nome do arquivo (versionamento implícito)
- Docstring com metadados da fonte no topo do arquivo

**Para APIs paginadas:**
- Implementar paginação completa com barra de progresso (`tqdm`)
- Salvar checkpoints intermediários para retomar em caso de falha

**Para web scraping:**
- Usar `requests` + `BeautifulSoup` para HTML simples
- Usar `playwright` para páginas com JavaScript
- Respeitar `robots.txt` e rate limits
- Incluir User-Agent identificável

### 6. Documentar fontes (SOURCES.yaml)

Cada fonte de dados ganha uma entrada no manifesto:

```yaml
sources:
  - id: worldbank_wdi
    name: "World Development Indicators"
    provider: "World Bank"
    url: "https://databank.worldbank.org/source/world-development-indicators"
    api_docs: "https://datahelpdesk.worldbank.org/knowledgebase/articles/889392"
    access_method: api  # api | bulk_download | scraping | manual
    requires_credentials: false
    license: "CC BY-4.0"
    variables_used:
      - "NY.GDP.PCAP.CD"  # GDP per capita
      - "SP.POP.TOTL"     # Population
    temporal_coverage: "1960-2023"
    geographic_coverage: "global"
    unit_of_analysis: "country-year"
    download_script: "scripts/download_worldbank.py"
    date_accessed: "2026-03-13"
    notes: ""
```

Campos obrigatórios: `id`, `name`, `provider`, `url`, `access_method`, `license`, `download_script`, `date_accessed`.

### 7. Documentar variáveis (DATA_DICTIONARY.md)

Para cada CSV processado, documente:

```markdown
## painel_paises.csv

| Variável | Tipo | Descrição | Fonte (id) | Unidade | Valores válidos |
|----------|------|-----------|------------|---------|-----------------|
| country_code | str | Código ISO 3166-1 alpha-3 | - | - | 3 letras |
| year | int | Ano de referência | - | - | 1960-2023 |
| gdp_pc | float | PIB per capita | worldbank_wdi | USD correntes | > 0 |
| population | int | População total | worldbank_wdi | pessoas | > 0 |
```

A coluna "Fonte (id)" vincula ao `id` em SOURCES.yaml — isso cria a cadeia de rastreabilidade.

### 8. Validar, gerar checksums e relatório de coleta

Após cada download, valide os dados e gere um relatório de coleta (`docs/COLLECTION_LOG.md`). O pesquisador precisa saber não só *o que* foi coletado, mas *o que ficou faltando* — gaps silenciosos são a maior ameaça à reprodutibilidade.

**Validação:**
1. Verificar que os arquivos não estão vazios
2. Conferir dimensões esperadas (linhas, colunas)
3. Gerar checksums:
   ```bash
   cd data && sha256sum raw/* > checksums.sha256
   ```

**Relatório de coleta** (`docs/COLLECTION_LOG.md`):

Gere automaticamente um relatório que documente a completude da coleta. Para painéis (country-year, municipality-year), isso significa cruzar as unidades esperadas com as efetivamente obtidas.

```markdown
# Relatório de Coleta

Data: 2026-03-13
Fonte: World Bank WDI

## Cobertura esperada vs. obtida

- Países solicitados: 20 (América Latina)
- Países obtidos: 20 ✓
- Período solicitado: 2000-2023 (24 anos)
- Observações esperadas: 480 (20 × 24)
- Observações obtidas: 467

## Gaps identificados

| País | Variável | Anos faltantes | Motivo provável |
|------|----------|---------------|-----------------|
| VEN | gdp_pc | 2015-2023 | World Bank não publica PIB da Venezuela desde 2014 |
| CUB | gdp_pc | 2022-2023 | Dados ainda não disponíveis |

## Cobertura completa

Os seguintes 18 países têm dados completos para todas as variáveis em todos os anos:
ARG, BOL, BRA, CHL, COL, CRI, DOM, ECU, GTM, HND, HTI, MEX, NIC, PAN, PER, PRY, SLV, URY

## Qualidade dos dados

- Missing values total: 13 de 960 células (1.4%)
- Valores atípicos identificados: nenhum
- Encoding: UTF-8, separador vírgula ✓
```

O relatório serve como registro permanente de que o pesquisador estava ciente dos gaps no momento da coleta — não como surpresa na análise. Para múltiplas fontes, inclua uma seção por fonte.

Adicione o COLLECTION_LOG.md à estrutura de diretórios em `docs/`.

### 9. Gerar README.md

O README do diretório `data/` deve conter:

```markdown
# Dados — [Nome do Projeto]

## Como reproduzir a coleta

1. Instalar dependências: `pip install -r scripts/requirements.txt`
2. Configurar credenciais: copie `.env.example` para `.env` e preencha
3. Executar scripts na ordem:
   - `python scripts/download_worldbank.py`
   - `python scripts/download_vdem.py`
   - `python scripts/process_merge.py`
4. Verificar integridade: `sha256sum -c checksums.sha256`

## Fontes

Ver detalhes completos em `docs/SOURCES.yaml`.

| Fonte | Acesso | Credencial? | Script |
|-------|--------|-------------|--------|
| World Bank WDI | API | Não | download_worldbank.py |
| V-Dem v14 | Bulk download | Não | download_vdem.py |

## Última coleta

Data: YYYY-MM-DD
Autor: [nome]
```

### 10. Pacotes Python comuns

Inclua no `requirements.txt` conforme necessário:

```
requests           # HTTP
python-dotenv      # Credenciais
pandas             # Manipulação
tqdm               # Progresso
beautifulsoup4     # Scraping HTML
lxml               # Parser rápido
wbdata             # World Bank API
pydataverse        # Harvard Dataverse API
imfpy              # IMF API
```

Para R, quando necessário: `basedosdados`, `geobr`, `sidrar`, `rbcb`, `WDI`.

## Checklist de qualidade

Antes de declarar a coleta completa, verifique:

- [ ] Todos os scripts executam sem erro do zero
- [ ] SOURCES.yaml tem entrada para cada fonte usada
- [ ] DATA_DICTIONARY.md cobre todas as variáveis dos CSVs processados
- [ ] `.env.example` documenta todas as credenciais necessárias
- [ ] `.gitignore` exclui `.env` e arquivos grandes em `raw/`
- [ ] `checksums.sha256` está atualizado
- [ ] `COLLECTION_LOG.md` documenta gaps, problemas e completude da coleta
- [ ] README.md tem instruções completas de reprodução
- [ ] Licenças de uso permitem o uso pretendido
