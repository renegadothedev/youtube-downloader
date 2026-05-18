# 🎬 Auto YouTube Downloader

![Banner](https://img.shields.io/badge/YouTube-Downloader-ff0000?style=for-the-badge&logo=youtube&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

An advanced and polished Bash script for downloading YouTube videos and audio with an intuitive interface, robust error handling, and optimized code.

## ✨ Key Features

| Feature | Description | Status |
|---------|-------------|--------|
| 🎥 **Video Download** | Supports qualities from 144p to 4K | ✅ |
| 🎵 **Audio Extraction** | MP3, M4A, WAV, AAC, FLAC, OGG | ✅ |
| 🚀 **Intuitive Interface** | Colorful interactive menus | ✅ |
| 📦 **Batch Download** | Multiple URL processing | ✅ |
| 🔧 **Auto-installation** | Automatically installs dependencies | ✅ |
| 🔄 **Auto-update** | Keeps youtube-dl up to date | ✅ |
| 📊 **History** | Full download record | ✅ |
| 💾 **Settings** | Customizable preferences | ✅ |
| 🔔 **Notifications** | System alerts | ✅ |

## 🛠️ Requirements

- **Platform**: Linux or macOS
- **Bash**: Version 4.0 or higher
- **Connection**: Internet access for downloads
- **Permissions**: sudo for package installation

## 📦 Quick Install

```bash
# Download and run directly
curl -sSL https://raw.githubusercontent.com/seuusuario/yt-downloader/main/yt-downloader.sh | bash

# Or manually
wget -O yt-downloader.sh https://raw.githubusercontent.com/seuusuario/yt-downloader/main/yt-downloader.sh
chmod +x yt-downloader.sh
./yt-downloader.sh
```

## 🚀 Usage

### 🖥️ Interactive Mode (Recommended)

```bash
./yt-downloader.sh
```

Use the interactive menu with colorful, easy-to-navigate options.

### ⚡ Direct Mode

```bash
# Download high-quality video
./yt-downloader.sh --url "https://youtube.com/watch?v=..." --quality hd --format mp4

# Extract audio as MP3
./yt-downloader.sh --url "https://youtube.com/watch?v=..." --type audio --format mp3

# Show full help
./yt-downloader.sh --help
```

### 🎯 Quality Options

| Quality | Resolution | Description |
|---------|------------|-------------|
| `max` | Maximum | Best available quality |
| `uhd` | 4K | 2160p (Ultra HD) |
| `qhd` | 1440p | Quad HD |
| `hd` | 1080p | Full HD |
| `720p` | 720p | HD Ready |
| `480p` | 480p | SD |
| `360p` | 360p | Low quality |
| `240p` | 240p | Very low quality |
| `144p` | 144p | Minimum quality |
| `audio` | Audio only | Audio-only download |

### 🎵 Supported Formats

**Video:** `mp4`, `mkv`, `webm`, `flv`  
**Audio:** `mp3`, `m4a`, `wav`, `aac`, `flac`, `ogg`

## ⚙️ Configuration

Set your preferences in the settings menu:

```bash
# Configuration file path
~/.yt_downloader_config

# Default download directory
~/YT_Downloads/
├── 📁 videos/          # Downloaded videos
├── 📁 audio/           # Audio files
├── 📁 logs/            # Operation logs
└── 📄 download_history.txt  # Full history
```

## 🔧 Customization

Edit the variables in the script to customize behavior:

```bash
# Download directory
DOWNLOAD_DIR="$HOME/YouTube_Downloads"

# Retry count
MAX_RETRIES=3

# Operation timeout
TIMEOUT=60

# Preferred formats
DEFAULT_QUALITY="hd"
DEFAULT_FORMAT="mp4"
```

## 📊 Usage Examples

### Example 1: Simple Download
```bash
./yt-downloader.sh --url "https://youtu.be/dQw4w9WgXcQ" --quality hd
```

### Example 2: Full Playlist
```bash
# Create a file with URLs
echo "https://youtu.be/video1
https://youtu.be/video2
https://youtu.be/video3" > playlist.txt

# Process in batch
./yt-downloader.sh --batch playlist.txt --quality 720p
```

### Example 3: Audio Extraction
```bash
./yt-downloader.sh --url "https://youtu.be/audio_video" --type audio --format mp3 --quality audio
```

## 🐛 Troubleshooting

### ❌ Error: "Missing dependencies"
**Fix:** The script attempts automatic installation. Run manually:
```bash
sudo apt update && sudo apt install youtube-dl ffmpeg python3 python3-pip
```

### ❌ Error: "Download failed"
**Fix:** Check your connection and try a lower quality:
```bash
./yt-downloader.sh --url "URL" --quality 480p
```

### ❌ Error: "Format not available"
**Fix:** List available formats:
```bash
youtube-dl -F "URL"
```

### 📋 Detailed Logs
Check logs for diagnostics:
```bash
tail -f ~/yt_downloader.log
cat ~/YT_Downloads/logs/download_*.log
```

## 🔄 Update

The script updates automatically. For manual update:

```bash
./yt-downloader.sh --update

# Or manually
wget -O yt-downloader.sh https://raw.githubusercontent.com/renegado/yt-downloader/main/yt-downloader.sh
```

## 📝 Legal Notice

⚠️ **Legal notice:** Use this script only for content you are authorized to access. Respect copyright and YouTube's terms of service.

- ✅ Personal and educational use
- ❌ Distribution of copyrighted content
- ❌ Terms of service violations

## 🤝 Contributing

Contributions are welcome! Follow these steps:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🆘 Support

If you need help:

1. Check the troubleshooting section above
2. Review the logs at `~/yt_downloader.log`
3. Open an issue on GitHub with:
   - Detailed problem description
   - Commands run
   - Relevant log output
   - System information

## 📄 License

Distributed under the MIT license. See `LICENSE` for details.

## 👨‍💻 Author

**Renegado** - [@Renegado](https://github.com/renegadothedev)

## 🙌 Thanks

- The `Eu ;3` team for the amazing work
- Open source community
- Contributors and testers

---

**⭐ If this project was helpful, give it a star on GitHub!**

![Footer](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg?style=for-the-badge)
![Open Source](https://img.shields.io/badge/Open%20Source-❤-red.svg?style=for-the-badge)
