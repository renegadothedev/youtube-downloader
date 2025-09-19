# 🎬 Auto YouTube Downloader

![Banner](https://img.shields.io/badge/YouTube-Downloader-ff0000?style=for-the-badge&logo=youtube&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Um script bash avançado e elegante para download de vídeos e áudios do YouTube com interface intuitiva, tratamento robusto de erros e mais de 2000 linhas de código otimizado.

## ✨ Características Principais

| Funcionalidade | Descrição | Status |
|----------------|-----------|--------|
| 🎥 **Download de Vídeos** | Suporte a qualidades de 144p até 4K | ✅ |
| 🎵 **Extração de Áudio** | MP3, M4A, WAV, AAC, FLAC, OGG | ✅ |
| 🚀 **Interface Intuitiva** | Menus interativos coloridos | ✅ |
| 📦 **Download em Lote** | Processamento múltiplo de URLs | ✅ |
| 🔧 **Auto-instalação** | Instala dependências automaticamente | ✅ |
| 🔄 **Auto-atualização** | Mantém youtube-dl atualizado | ✅ |
| 📊 **Histórico** | Registro completo de downloads | ✅ |
| 💾 **Configurações** | Preferências personalizáveis | ✅ |
| 🔔 **Notificações** | Alertas do sistema | ✅ |

## 🛠️ Pré-requisitos

- **Sistema**: Linux ou macOS
- **Bash**: Versão 4.0 ou superior
- **Conexão**: Internet para downloads
- **Permissões**: Sudo para instalação de pacotes

## 📦 Instalação Rápida

```bash
# Download e execução direta
curl -sSL https://raw.githubusercontent.com/seuusuario/yt-downloader/main/yt-downloader.sh | bash

# Ou manualmente
wget -O yt-downloader.sh https://raw.githubusercontent.com/seuusuario/yt-downloader/main/yt-downloader.sh
chmod +x yt-downloader.sh
./yt-downloader.sh
```

## 🚀 Como Usar

### 🖥️ Modo Interativo (Recomendado)

```bash
./yt-downloader.sh
```

Navegue pelo menu interativo com opções coloridas e intuitivas.

### ⚡ Modo Direto

```bash
# Download de vídeo em alta qualidade
./yt-downloader.sh --url "https://youtube.com/watch?v=..." --quality hd --format mp4

# Extrair áudio em MP3
./yt-downloader.sh --url "https://youtube.com/watch?v=..." --type audio --format mp3

# Ver ajuda completa
./yt-downloader.sh --help
```

### 🎯 Opções de Qualidade

| Qualidade | Resolução | Descrição |
|-----------|-----------|-----------|
| `max` | Máxima | Melhor qualidade disponível |
| `uhd` | 4K | 2160p (Ultra HD) |
| `qhd` | 1440p | Quad HD |
| `hd` | 1080p | Full HD |
| `720p` | 720p | HD Ready |
| `480p` | 480p | SD |
| `360p` | 360p | Baixa qualidade |
| `240p` | 240p | Qualidade muito baixa |
| `144p` | 144p | Qualidade mínima |
| `audio` | Áudio | Apenas áudio |

### 🎵 Formatos Suportados

**Vídeo:** `mp4`, `mkv`, `webm`, `flv`  
**Áudio:** `mp3`, `m4a`, `wav`, `aac`, `flac`, `ogg`

## ⚙️ Configurações

Configure suas preferências no menu de configurações:

```bash
# Estrutura do arquivo de configuração
~/.yt_downloader_config

# Diretório padrão de downloads
~/YT_Downloads/
├── 📁 videos/          # Vídeos baixados
├── 📁 audio/           # Arquivos de áudio
├── 📁 logs/            # Logs de operações
└── 📄 download_history.txt  # Histórico completo
```

## 🔧 Personalização

Edite as variáveis no script para personalizar o comportamento:

```bash
# Diretório de downloads
DOWNLOAD_DIR="$HOME/YouTube_Downloads"

# Número de tentativas
MAX_RETRIES=3

# Timeout de operações
TIMEOUT=60

# Formatos preferidos
DEFAULT_QUALITY="hd"
DEFAULT_FORMAT="mp4"
```

## 📊 Exemplos de Uso

### Exemplo 1: Download Simples
```bash
./yt-downloader.sh --url "https://youtu.be/dQw4w9WgXcQ" --quality hd
```

### Exemplo 2: Playlist Completa
```bash
# Criar arquivo com URLs
echo "https://youtu.be/video1
https://youtu.be/video2
https://youtu.be/video3" > playlist.txt

# Processar em lote
./yt-downloader.sh --batch playlist.txt --quality 720p
```

### Exemplo 3: Extração de Áudio
```bash
./yt-downloader.sh --url "https://youtu.be/audio_video" --type audio --format mp3 --quality audio
```

## 🐛 Solução de Problemas

### ❌ Erro: "Dependências missing"
**Solução:** O script tenta instalar automaticamente. Execute manualmente:
```bash
sudo apt update && sudo apt install youtube-dl ffmpeg python3 python3-pip
```

### ❌ Erro: "Download falhou"
**Solução:** Verifique a conexão e tente qualidade inferior:
```bash
./yt-downloader.sh --url "URL" --quality 480p
```

### ❌ Erro: "Formato não disponível"
**Solução:** Liste formatos disponíveis:
```bash
youtube-dl -F "URL"
```

### 📋 Logs Detalhados
Consulte os logs para diagnóstico:
```bash
tail -f ~/yt_downloader.log
cat ~/YT_Downloads/logs/download_*.log
```

## 🔄 Atualização

O script se atualiza automaticamente. Para atualização manual:

```bash
./yt-downloader.sh --update

# Ou manualmente
wget -O yt-downloader.sh https://raw.githubusercontent.com/renegado/yt-downloader/main/yt-downloader.sh
```

## 📝 Notas Legais

⚠️ **Aviso Legal:** Use este script apenas para conteúdo que você tem direito de acessar. Respeite os direitos autorais e os termos de serviço do YouTube.

- ✅ Uso pessoal e educacional
- ❌ Distribuição de conteúdo protegido
- ❌ Violação de termos de serviço

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga estos pasos:

1. Fork do projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 🆘 Suporte

Se precisar de ajuda:

1. Consulte a seção de troubleshooting acima
2. Verifique os logs em `~/yt_downloader.log`
3. Abra uma issue no GitHub com:
   - Descrição detalhada do problema
   - Comandos executados
   - Saída relevante dos logs
   - Informações do sistema

## 📄 Licença

Distribuído sob licença MIT. Veja `LICENSE` para mais informações.

## 👨‍💻 Autor

**Seu Nome** - [@Renegado]([https://github.com/seuusuario](https://github.com/renegadothedev))

## 🙌 Agradecimentos

- Equipe do `youtube-dl` pelo incrível trabalho
- Comunidade de código aberto
- Contribuidores e testadores

---

**⭐ Se este projeto foi útil, deixe uma estrela no GitHub!**

![Footer](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg?style=for-the-badge)
![Open Source](https://img.shields.io/badge/Open%20Source-❤-red.svg?style=for-the-badge)
