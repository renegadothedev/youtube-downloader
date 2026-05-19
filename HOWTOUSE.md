# HOW TO USE

Este documento fornece instruções claras e práticas para usar os scripts deste repositório. Contém seções organizadas com comandos práticos, exemplos e solução de problemas em Português, Español, English e Русский.

Índice
- Requisitos
- Instalação rápida
- Execução (Linux/macOS)
- Execução (Windows / PowerShell)
- Configuração
- Exemplos rápidos
- Solução de problemas

---
---

## Português

- Requisitos mínimos: `yt-dlp`, `ffmpeg`, `curl`, `python3` (ou `python`).
- Scripts incluídos:
	- `yt-downloader.sh` — versão Bash (Linux/macOS).
	- `yt-downloader.ps1` — versão PowerShell (Windows / PowerShell Core).

### Instalação rápida

Linux (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### Executar

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Windows (PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

### Configuração

- Bash: edite `~/.yt_downloader_config` (variáveis `DEFAULT_QUALITY`, `DEFAULT_FORMAT`, `SAVE_HISTORY`, `AUTO_UPDATE`).
- PowerShell: edite `~/.yt_downloader_config.json` (JSON com as mesmas chaves).

### Exemplos rápidos

- Baixar vídeo em 1080p MP4 (interativo): escolha `Download Video` → `1080p` → `mp4`.
- Extrair áudio em MP3 (interativo): escolha `Download Audio` → `mp3`.

Você também pode usar `yt-dlp` diretamente para testes:

```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" -o '~/Downloads/YT_Downloads/videos/%(title)s.%(ext)s' URL
yt-dlp -x --audio-format mp3 -o '~/Downloads/YT_Downloads/audio/%(title)s.%(ext)s' URL
```

### Solução de problemas (rápido)

- Se faltar dependência: instale conforme seção acima.
- Verifique formatos disponíveis: `yt-dlp -F "URL"`.
- Logs e histórico:
	- Logs: `~/Downloads/YT_Downloads/logs/yt_downloader.log`
	- Histórico: `~/Downloads/YT_Downloads/history.log`

---
- Diretórios úteis:
	- Downloads: `~/Downloads/YT_Downloads`
	- Logs: `~/Downloads/YT_Downloads/logs/yt_downloader.log`
	- Histórico: `~/Downloads/YT_Downloads/history.log`

---

## Español

- Requisitos: `yt-dlp`, `ffmpeg`, `curl`, `python3` (o `python`).

### Instalación rápida

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### Ejecutar

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Windows (PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

### Configuración

- Bash: edite `~/.yt_downloader_config`.
- PowerShell: edite `~/.yt_downloader_config.json`.

### Ejemplos rápidos

```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" -o '~/Downloads/YT_Downloads/videos/%(title)s.%(ext)s' URL
yt-dlp -x --audio-format mp3 -o '~/Downloads/YT_Downloads/audio/%(title)s.%(ext)s' URL
```

### Solución de problemas rápida

- Formatos disponibles: `yt-dlp -F "URL"`.
- Logs: `~/Downloads/YT_Downloads/logs/yt_downloader.log`.
- Historial: `~/Downloads/YT_Downloads/history.log`.

---
---

## English

- Minimum requirements: `yt-dlp`, `ffmpeg`, `curl`, `python3` (or `python`).

### Quick install

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### Run

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Windows (PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

### Configuration

- Bash: edit `~/.yt_downloader_config`.
- PowerShell: edit `~/.yt_downloader_config.json`.

### Quick examples

```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" -o '~/Downloads/YT_Downloads/videos/%(title)s.%(ext)s' URL
yt-dlp -x --audio-format mp3 -o '~/Downloads/YT_Downloads/audio/%(title)s.%(ext)s' URL
```

### Quick troubleshooting

- List available formats: `yt-dlp -F "URL"`.
- Logs: `~/Downloads/YT_Downloads/logs/yt_downloader.log`.
- History: `~/Downloads/YT_Downloads/history.log`.

---
---


## Русский

- Требования: `yt-dlp`, `ffmpeg`, `curl`, `python3` (или `python`).

### Быстрая установка

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg curl python3
```

macOS (Homebrew):

```bash
brew install yt-dlp ffmpeg curl python
```

Windows (Chocolatey):

```powershell
choco install yt-dlp ffmpeg curl python
```

### Запуск

Linux/macOS:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Windows (PowerShell Core):

```powershell
pwsh ./yt-downloader.ps1
```

### Конфигурация

- Bash: отредактируйте `~/.yt_downloader_config`.
- PowerShell: отредактируйте `~/.yt_downloader_config.json`.

### Примеры

```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" -o '~/Downloads/YT_Downloads/videos/%(title)s.%(ext)s' URL
yt-dlp -x --audio-format mp3 -o '~/Downloads/YT_Downloads/audio/%(title)s.%(ext)s' URL
```

### Быстрое решение проблем

- Просмотреть доступные форматы: `yt-dlp -F "URL"`.
- Логи: `~/Downloads/YT_Downloads/logs/yt_downloader.log`.
- История: `~/Downloads/YT_Downloads/history.log`.

---

Se quiser, posso adicionar seções extras: exemplos avançados de flags `yt-dlp`, integração com agendadores (cron/Task Scheduler) ou traduções mais formais para cada idioma.


---

Se tiver dúvidas ou quiser traduções mais detalhadas (por exemplo, exemplos de flags do `yt-dlp`), diga qual idioma prefere que eu expanda.

