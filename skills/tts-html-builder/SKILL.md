---
name: tts-html-builder
description: Converte resumos, artigos e documentos em páginas HTML limpas e elegantes otimizadas para leitor de voz (TTS - Text to Speech), contendo player interativo nativo (Web Speech API) com botões de ouvir/pausar, avançar/voltar parágrafo, velocidade ajustável (0.5x a 3.0x), seleção de vozes e grifo visual sincronizado em tempo real. Ative quando o usuário solicitar HTML para sintetizador de voz ou leitura audível.
---

# TTS HTML Builder: Guia de Criação de Documentos Audíveis

Esta skill orienta a transformação de qualquer texto, artigo ou resumo acadêmico em um documento HTML limpo, responsivo e perfeitamente otimizado para leitura por sintetizadores de voz (**TTS - Text to Speech**).

## 1. Regras de Limpeza de Texto para Sintetizadores de Voz

Ao preparar um texto para TTS, aplique rigorosamente as seguintes transformações no conteúdo:

1. **Remoção de Citações Repetitivas no Corpo:** 
   - Remova citações entre parênteses como `(Treiman 1970)` ou `[1]` do meio das frases. Preserve referências apenas no rodapé (`<footer>`).
2. **Conversão de Fórmulas e Notações Matemáticas:**
   - Converta notações LaTeX ou esquemas com setas (`A -> B -> C`) em frases narrativas fluidas em português (ex: *"A industrialização impulsiona a transformação da estrutura..."*).
3. **Remoção de Metadados e Marcadores Internos:**
   - Remova marcadores como `[Extracting: ...]`, delimitadores de código ou formatações Markdown que seriam lidas literalmente por um sintetizador.
4. **Estruturação Semântica Limpa:**
   - Utilize elementos HTML5 semânticos (`<h1>`, `<h2>`, `<h3>`, `<p>`, `<ul>`, `<li>`). Evite colocar símbolos soltos de travessão ou asteriscos no início das linhas.

---

## 2. Estrutura do Player de Voz Nativo (Web Speech API)

Todo documento gerado deve incluir o player interativo sticky no topo com os seguintes recursos:

### Recursos do Player:
- **Controles de Leitura:** Botões para `⏮ Voltar`, `▶ Ouvir / ⏸ Pausar`, `Avançar ⏭` e `⏹ Parar`.
- **Faixa Extensa de Velocidade:** Opções no `<select>` variando de `0.5x` a `3.0x`.
- **Seleção de Vozes Nativas:** Lista dinâmica populada via `window.speechSynthesis.getVoices()` filtrando vozes em português (`pt-BR`).
- **Alternador de Tema:** Botão para comutar entre Dark Mode (padrão) e Light Mode.

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
    paragraphs = Array.from(container.querySelectorAll('h1, h2, h3, p, li, .causal-box'));
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
        btnPlay.style.backgroundColor = 'var(--accent)';
    } else {
        playIcon.textContent = '▶';
        playText.textContent = 'Ouvir';
        btnPlay.style.backgroundColor = 'var(--accent)';
    }
}

function changeRate() {
    if (isSpeaking && !isPaused) startSpeechFrom(currentParagraphIndex);
}

function changeVoice() {
    if (isSpeaking && !isPaused) startSpeechFrom(currentParagraphIndex);
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    if (currentTheme === 'light') {
        document.documentElement.removeAttribute('data-theme');
    } else {
        document.documentElement.setAttribute('data-theme', 'light');
    }
}
```

---

## 4. Requisitos de Estilo CSS

- Usar `--highlight: rgba(56, 189, 248, 0.25);` com borda lateral de destaque (`border-left: 4px solid var(--accent);`).
- Garantir transição suave (`transition: background-color 0.2s ease`).
- Manter o player fixo (`position: sticky; top: 0; z-index: 100`).
