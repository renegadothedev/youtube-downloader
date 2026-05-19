# HOW TO USE

Este documento foi expandido para fornecer instruções completas, exemplos práticos e soluções de problemas detalhadas. A seguir você encontrará guias em Português, Español, English e Русский — cada seção contém: requisitos, instalação, execução, configuração, exemplos avançados (playlists, legendas, qualidade e formatos), logs, agendamento e troubleshooting.

Índice
- Requisitos
- Instalação rápida por sistema operacional
- Execução (modo interativo)
- Uso avançado com `yt-dlp` (flags úteis)
- Configuração e arquivos de persistência
- Logs, histórico e localização dos ficheiros
- Agendamento e execução sem interação
- Troubleshooting detalhado
- FAQ e boas práticas

---

## Português

### 1) Requisitos

- `yt-dlp` — motor de download (substitui `youtube-dl`).
- `ffmpeg` — para remuxing/conversão e extração de áudio.
- `curl` ou `wget` — para downloads auxiliares (opcional).
- `python3` ou `python` — exigido por algumas plataformas/instalações do `yt-dlp`.

Verifique com:

```bash
yt-dlp --version
ffmpeg -version
python3 --version
```

### 2) Instalação rápida

Linux (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew update
brew install yt-dlp ffmpeg curl python
```

Windows (PowerShell + Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

Observação: em Windows também é possível usar `scoop` ou instalar via executável do `yt-dlp`.

### 3) Execução (modo interativo)

Bash (Linux/macOS):

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

PowerShell (Windows / PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

Ao abrir, siga o menu interativo para escolher entre baixar vídeo, extrair áudio, atualizar `yt-dlp` ou ver histórico.

Passo-a-passo típico para baixar um vídeo:
1. Escolha `Download Video`.
2. Cole a URL quando solicitado.
3. Selecione a qualidade (ex.: `1080p`).
4. Selecione o formato (ex.: `mp4`).
5. Aguarde o `yt-dlp` baixar e (quando aplicável) mesclar áudio/vídeo.

### 4) Uso avançado com `yt-dlp` (flags recomendadas)

Esses exemplos são úteis quando quiser sair do modo interativo ou automatizar tarefas.

- Baixar vídeo + áudio no melhor formato e salvar com título legível:

```bash
yt-dlp -f "bestvideo+bestaudio/best" -o "$HOME/Downloads/YT_Downloads/videos/%(title)s.%(ext)s" URL
```

- Extrair apenas áudio em MP3 com qualidade máxima:

```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Downloads/YT_Downloads/audio/%(title)s.%(ext)s" URL
```

- Baixar playlist inteira (mantendo organização):

```bash
yt-dlp -o "$HOME/Downloads/YT_Downloads/playlist/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" URL_DA_PLAYLIST
```

- Baixar legendas (automáticas e embutir ou baixar separadas):

```bash
yt-dlp --write-auto-sub --sub-lang en --convert-subs srt -o "$HOME/Downloads/YT_Downloads/videos/%(title)s.%(ext)s" URL
# para embutir legendas (quando suportado):
yt-dlp --embed-subs --write-auto-sub --sub-lang en -o "$HOME/Downloads/YT_Downloads/videos/%(title)s.%(ext)s" URL
```

- Baixar apenas thumbnails e metadados:

```bash
yt-dlp --write-info-json --write-thumbnail -o "$HOME/Downloads/YT_Downloads/videos/%(title)s.%(ext)s" URL
```

- Limitar largura de banda e utilizar várias conexões (útil para downloads grandes):

```bash
yt-dlp --limit-rate 2M --concurrent-fragments 4 URL
```

### 5) Configuração e arquivos de persistência

- `~/.yt_downloader_config` (Bash) — arquivo de shell que define variáveis:

```bash
DEFAULT_QUALITY="1080p"
DEFAULT_FORMAT="mp4"
SAVE_HISTORY=true
AUTO_UPDATE=true
```

- `~/.yt_downloader_config.json` (PowerShell) — JSON equivalente:

```json
{
  "DEFAULT_QUALITY": "1080p",
  "DEFAULT_FORMAT": "mp4",
  "SAVE_HISTORY": true,
  "AUTO_UPDATE": true
}
```

Como o script usa essas configurações:
- `DEFAULT_QUALITY` e `DEFAULT_FORMAT` predefinem as escolhas no menu interativo.
- `SAVE_HISTORY` controla se a operação é registrada em `history.log`.
- `AUTO_UPDATE` atualmente apenas indica intenção; a atualização manual é feita pelo menu.

### 6) Logs, histórico e estrutura de pastas

Padrão:

```
$HOME/Downloads/YT_Downloads/
├── videos/
├── audio/
├── logs/
│   └── yt_downloader.log
└── history.log
```

- `yt_downloader.log` — arquivo de log do script (mensagens de execução e erros).
- `history.log` — entradas com timestamp para downloads bem sucedidos.

### 7) Agendamento e execução sem interação

Para executar downloads em batch (ex.: lista de URLs), crie um arquivo `urls.txt` com uma URL por linha e execute:

```bash
while read -r url; do
  yt-dlp -f "bestvideo+bestaudio/best" -o "$HOME/Downloads/YT_Downloads/videos/%(title)s.%(ext)s" "$url"
done < urls.txt
```

Agendamento no Linux com `cron` (ex.: rodar diariamente às 02:00):

```cron
0 2 * * * /usr/bin/pwsh -NoProfile -NonInteractive -Command "/path/to/yt-downloader.ps1"
```

No Windows, use o Task Scheduler apontando para `pwsh.exe` com argumento `-File "C:\path\to\yt-downloader.ps1"`.

### 8) Troubleshooting detalhado

- Erro: `command not found` para `yt-dlp` ou `ffmpeg` — instale as dependências e confirme o PATH.
- Erro: `HTTP Error 403` ou vídeo bloqueado — tente usar um extractor diferente (ex.: `--cookies` com cookies de sessão) ou proxy.
- Erro em mesclagem (`ffmpeg`) — verifique se `ffmpeg` está instalado e acessível.
- Downloads interrompidos frequentemente — verifique limites de rede e tente diminuir concorrência ou limitar taxa (`--limit-rate`).

Comandos úteis para diagnóstico:

```bash
yt-dlp -v URL      # modo verbose para investigação
yt-dlp -F URL      # lista formatos disponíveis
ffmpeg -version    # checar ffmpeg
```

### 9) FAQ e boas práticas

- Posso rodar em segundo plano? Sim — use `nohup`, `screen`, `tmux` ou o agendador do sistema.
- Posso baixar playlists inteiras? Sim — veja o exemplo de playlist acima.
- É legal usar isto? Verifique os termos de serviço do site e direitos autorais locais antes de baixar conteúdo.

---

## Español

### 1) Requisitos

- `yt-dlp` — motor de descarga.
- `ffmpeg` — para conversiones y mezcla.
- `curl` o `wget` — opcional.
- `python3` o `python`.

### 2) Instalación rápida

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew update
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### 3) Ejecutar (modo interactivo)

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Windows (PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

### 4) Uso avanzado con `yt-dlp` (flags útiles)

Ejemplos cortos:

```bash
yt-dlp -f "bestvideo+bestaudio/best" -o '~/Downloads/YT_Downloads/videos/%(title)s.%(ext)s' URL
yt-dlp -x --audio-format mp3 --audio-quality 0 -o '~/Downloads/YT_Downloads/audio/%(title)s.%(ext)s' URL
yt-dlp -o '~/Downloads/YT_Downloads/playlist/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s' URL_DE_LA_PLAYLIST
yt-dlp --write-auto-sub --sub-lang en --convert-subs srt URL
```

### 5) Configuración

- `~/.yt_downloader_config` (Bash) y `~/.yt_downloader_config.json` (PowerShell).

### 6) Logs y estructura

Los archivos se guardan en `~/Downloads/YT_Downloads` con subcarpetas `videos`, `audio`, `logs` y `history.log`.

### 7) Programación y ejecución en segundo plano

Use `cron` o Task Scheduler para automatizar.

### 8) Solución de problemas

Compruebe que `yt-dlp` y `ffmpeg` estén en el PATH y utilice `yt-dlp -v` para salida detallada.

---

## English

### 1) Requirements

- `yt-dlp` (download engine)
- `ffmpeg` (muxing/conversion)
- `curl` or `wget` (optional)
- `python3` or `python`

### 2) Quick install

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew update
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### 3) Run (interactive)

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

PowerShell:

```powershell
pwsh ./yt-downloader.ps1
```

### 4) Advanced usage with `yt-dlp` (useful flags)

Examples:

```bash
yt-dlp -f "bestvideo+bestaudio/best" -o "$HOME/Downloads/YT_Downloads/videos/%(title)s.%(ext)s" URL
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Downloads/YT_Downloads/audio/%(title)s.%(ext)s" URL
yt-dlp -o "$HOME/Downloads/YT_Downloads/playlist/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" PLAYLIST_URL
yt-dlp --write-auto-sub --sub-lang en --convert-subs srt URL
```

### 5) Configuration files

- Bash: `~/.yt_downloader_config`
- PowerShell: `~/.yt_downloader_config.json`

### 6) Logs and output layout

All downloads and logs are stored under `$HOME/Downloads/YT_Downloads` (videos, audio, logs, history.log).

### 7) Scheduling and headless runs

Use `cron` or Task Scheduler; run pwsh with `-File` for scripts.

### 8) Troubleshooting

Run `yt-dlp -v URL` for verbose debugging and `yt-dlp -F URL` to list available formats.

---

## Русский

### 1) Требования

- `yt-dlp` — движок скачивания.
- `ffmpeg` — для конвертации и слияния аудио/видео.
- `curl`/`wget` — опционально.
- `python3`/`python`.

### 2) Быстрая установка

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew update
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### 3) Запуск (интерактивный режим)

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Windows (PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

### 4) Расширенное использование `yt-dlp` (полезные флаги)

Примеры:

```bash
yt-dlp -f "bestvideo+bestaudio/best" -o '~/Downloads/YT_Downloads/videos/%(title)s.%(ext)s' URL
yt-dlp -x --audio-format mp3 --audio-quality 0 -o '~/Downloads/YT_Downloads/audio/%(title)s.%(ext)s' URL
yt-dlp --write-auto-sub --sub-lang en --convert-subs srt URL
```

### 5) Конфигурация

- Bash: `~/.yt_downloader_config`
- PowerShell: `~/.yt_downloader_config.json`

### 6) Логи и структура вывода

Файлы сохраняются в `~/Downloads/YT_Downloads` с подпапками `videos`, `audio`, `logs` и `history.log`.

### 7) Планирование и запуск в фоне

Используйте `cron` или Task Scheduler; указывайте `pwsh -File` для запуска PowerShell-скриптов.

### 8) Устранение неполадок

Для отладки используйте `yt-dlp -v URL` и `yt-dlp -F URL`.




