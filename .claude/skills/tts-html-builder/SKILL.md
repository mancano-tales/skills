---
name: tts-html-builder
description: Converte resumos, artigos e documentos em páginas HTML ou arquivos Quarto (.qmd) limpos e elegantes otimizados para leitor de voz (TTS - Text to Speech), contendo player interativo nativo (Web Speech API) com botões de ouvir/pausar, avançar/voltar parágrafo, velocidade ajustável (0.5x a 3.0x), seleção de vozes e grifo visual sincronizado em tempo real. Ative quando o usuário solicitar HTML ou Quarto (.qmd) para sintetizador de voz ou leitura audível.
---

# TTS HTML & Quarto Builder: Guia de Criação de Documentos Audíveis

Esta skill orienta a transformação de qualquer texto, artigo ou resumo acadêmico em páginas **HTML estáticas** ou documentos **Quarto (`.qmd`)** limpos, responsivos e perfeitamente otimizados para leitura por sintetizadores de voz (**TTS - Text to Speech**).

---

## 1. Regras de Limpeza de Texto para Sintetizadores de Voz

Ao preparar um texto para TTS, aplique rigorosamente as seguintes transformações no conteúdo:

1. **Remoção de Citações Repetitivas no Corpo:** 
   - Remova citações entre parênteses como `(Treiman 1970)` ou `[1]` do meio das frases. Preserve referências apenas no rodapé (`<footer>` ou fim do documento).
2. **Conversão de Fórmulas e Notações Matemáticas:**
   - Converta notações LaTeX ou esquemas com setas (`A -> B -> C`) em frases narrativas fluidas em português (ex: *"A industrialização impulsiona a transformação da estrutura..."*).
3. **Remoção de Metadados e Marcadores Internos:**
   - Remova marcadores como `[Extracting: ...]`, delimitadores de código ou formatações Markdown que seriam lidas literalmente por um sintetizador.
4. **Estruturação Semântica Limpa:**
   - Utilize elementos HTML5 ou Markdown limpos (`<h1>`, `<h2>`, `<h3>`, `<p>`, `<ul>`, `<li>` / `#`, `##`, `-`).

---

## 2. Suporte Duplo: Arquivos HTML Estáticos vs. Quarto (`.qmd`)

O agente deve gerar o formato ideal dependendo do contexto da solicitação:

### Modo A: Documentos Quarto (`.qmd`) — Recomendado para Sites/Quarto Projects
Em projetos Quarto, estruture o arquivo com YAML frontmatter, blocos nativos de Callout (`::: {.callout-note}`) e embute o player e o script usando ````{=html}`:

```markdown
---
title: "Título do Artigo"
subtitle: "Subtítulo explicativo"
author: "Autor"
date: "2026-07-25"
format:
  html:
    toc: true
---

```{=html}
<div class="tts-player" role="region" aria-label="Controles de Áudio">
    <div class="player-container">
        <div class="player-controls">
            <button class="tts-btn tts-btn-secondary" onclick="prevParagraph()">⏮ Voltar</button>
            <button id="btnPlay" class="tts-btn" onclick="togglePlayPause()"><span id="playIcon">▶</span> <span id="playText">Ouvir Texto</span></button>
            <button class="tts-btn tts-btn-secondary" onclick="nextParagraph()">Avançar ⏭</button>
            <button id="btnStop" class="tts-btn tts-btn-secondary" onclick="stopSpeech()">⏹ Parar</button>
        </div>
        <div class="tts-settings">
            <label for="speedSelect">Velocidade:
                <select id="speedSelect" class="tts-select" onchange="changeRate()">
                    <option value="0.5">0.5x</option>
                    <option value="0.75">0.75x</option>
                    <option value="0.85">0.85x</option>
                    <option value="1" selected>1.0x (Normal)</option>
                    <option value="1.15">1.15x</option>
                    <option value="1.25">1.25x</option>
                    <option value="1.35">1.35x</option>
                    <option value="1.5">1.5x</option>
                    <option value="1.75">1.75x</option>
                    <option value="2.0">2.0x</option>
                    <option value="2.5">2.5x</option>
                    <option value="3.0">3.0x</option>
                </select>
            </label>
            <label for="voiceSelect">Voz:
                <select id="voiceSelect" class="tts-select" onchange="changeVoice()">
                    <option value="">Padrão do Sistema</option>
                </select>
            </label>
        </div>
    </div>
</div>
```

<div id="speakableContent">

## Conteúdo do Artigo em Markdown...

</div>

```{=html}
<script>
// Código de controle TTS estrito
</script>
```
```

### Modo B: Arquivos HTML Estáticos Autônomos (`.html`)
Gere o arquivo HTML completo com CSS embutido, player sticky e script.

---

## 3. Código JavaScript Padrão (Sincronização Estrita sem Descompasso)

Para garantir que o grifo visual **nunca fique à frente ou atrás da voz**, o script deve seguir a implementação com evento `onstart` e proteções contra race conditions:

```javascript
let synth = window.speechSynthesis;
let activeUtterance = null;
let isSpeaking = false;
let isPaused = false;
let paragraphs = [];
let currentParagraphIndex = 0;
let voices = [];

window.addEventListener('DOMContentLoaded', () => {
    populateVoiceList();
    if (speechSynthesis.onvoiceschanged !== undefined) {
        speechSynthesis.onvoiceschanged = populateVoiceList;
    }
    
    const container = document.getElementById('speakableContent');
    paragraphs = Array.from(container.querySelectorAll('h1, h2, h3, p, li, .causal-box, .callout'));
});

function populateVoiceList() {
    voices = synth.getVoices().filter(v => v.lang.startsWith('pt'));
    const voiceSelect = document.getElementById('voiceSelect');
    voiceSelect.innerHTML = '<option value="">Padrão do Sistema (PT)</option>';
    
    if (voices.length === 0) voices = synth.getVoices();

    voices.forEach((voice, index) => {
        const option = document.createElement('option');
        option.textContent = `${voice.name} (${voice.lang})`;
        option.value = index;
        if (voice.lang.includes('pt-BR') || voice.lang.includes('pt')) {
            option.selected = true;
        }
        voiceSelect.appendChild(option);
    });
}

function togglePlayPause() {
    if (!synth) return;
    if (isSpeaking && !isPaused) {
        synth.pause();
        isPaused = true;
        updateButtonState('pause');
    } else if (isPaused) {
        synth.resume();
        isPaused = false;
        updateButtonState('play');
    } else {
        startSpeechFrom(currentParagraphIndex);
    }
}

function prevParagraph() {
    startSpeechFrom(Math.max(0, currentParagraphIndex - 1));
}

function nextParagraph() {
    startSpeechFrom(Math.min(paragraphs.length - 1, currentParagraphIndex + 1));
}

function startSpeechFrom(index) {
    stopSpeech(false);
    if (index >= paragraphs.length) {
        currentParagraphIndex = 0;
        updateButtonState('stop');
        return;
    }
    currentParagraphIndex = index;
    speakParagraph(currentParagraphIndex);
}

function speakParagraph(index) {
    if (index >= paragraphs.length) {
        stopSpeech();
        return;
    }

    const currentEl = paragraphs[index];
    const textToSpeak = currentEl.innerText || currentEl.textContent;
    
    const utterance = new SpeechSynthesisUtterance(textToSpeak);
    activeUtterance = utterance; // Previne Garbage Collection prematura no Chrome
    
    utterance.lang = 'pt-BR';
    const selectedVoiceIndex = document.getElementById('voiceSelect').value;
    if (selectedVoiceIndex !== "" && voices[selectedVoiceIndex]) {
        utterance.voice = voices[selectedVoiceIndex];
    }

    const speed = parseFloat(document.getElementById('speedSelect').value);
    utterance.rate = speed;

    // Sincronização estrita: o destaque SÓ ocorre quando o áudio REALMENTE inicia
    utterance.onstart = () => {
        if (currentParagraphIndex === index) {
            removeHighlights();
            currentEl.classList.add('speaking-highlight');
            currentEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    };

    utterance.onend = () => {
        // Proteção contra eventos cancelados/desalinhados
        if (!isSpeaking || isPaused || currentParagraphIndex !== index) return;

        currentParagraphIndex++;
        if (currentParagraphIndex < paragraphs.length) {
            speakParagraph(currentParagraphIndex);
        } else {
            stopSpeech();
        }
    };

    utterance.onerror = (e) => {
        if (isSpeaking && currentParagraphIndex === index) {
            currentParagraphIndex++;
            if (currentParagraphIndex < paragraphs.length) speakParagraph(currentParagraphIndex);
            else stopSpeech();
        }
    };

    isSpeaking = true;
    isPaused = false;
    updateButtonState('play');
    synth.speak(utterance);
}

function stopSpeech(resetIndex = true) {
    isSpeaking = false;
    isPaused = false;
    if (synth) synth.cancel();
    activeUtterance = null;
    removeHighlights();
    if (resetIndex) currentParagraphIndex = 0;
    updateButtonState('stop');
}

function removeHighlights() {
    paragraphs.forEach(el => el.classList.remove('speaking-highlight'));
}

function updateButtonState(state) {
    const btnPlay = document.getElementById('btnPlay');
    const playIcon = document.getElementById('playIcon');
    const playText = document.getElementById('playText');

    if (state === 'play') {
        playIcon.textContent = '⏸';
        playText.textContent = 'Pausar';
        btnPlay.style.backgroundColor = '#e11d48';
    } else if (state === 'pause') {
        playIcon.textContent = '▶';
        playText.textContent = 'Continuar';
        btnPlay.style.backgroundColor = '#2563eb';
    } else {
        playIcon.textContent = '▶';
        playText.textContent = 'Ouvir';
        btnPlay.style.backgroundColor = '#2563eb';
    }
}

function changeRate() {
    if (isSpeaking && !isPaused) startSpeechFrom(currentParagraphIndex);
}

function changeVoice() {
    if (isSpeaking && !isPaused) startSpeechFrom(currentParagraphIndex);
}
```
