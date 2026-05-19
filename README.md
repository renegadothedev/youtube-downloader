# 🎬 Auto YouTube Downloader

![Banner](https://img.shields.io/badge/YouTube-Downloader-ff0000?style=for-the-badge&logo=youtube&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Auto YouTube Downloader is a Bash-based tool for downloading YouTube videos and audio with an interactive menu, quality selection, download history logging, and `yt-dlp` support.

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🎥 Video download | Download video with selectable quality and output format |
| 🎵 Audio extraction | Extract audio and convert to MP3, M4A, WAV, FLAC |
| 🚀 Interactive menu | Choose options in a simple terminal UI |
| 🔄 yt-dlp update | Update `yt-dlp` from the menu |
| 📊 Download history | Save completed downloads to a history log |
| ⚙️ Config file | Persistent default quality, format, and history settings |

## 🛠️ Requirements

- **Platform**: Linux or macOS
- **Bash**: Version 4.0 or higher
- **Dependencies**: `yt-dlp`, `ffmpeg`, `curl`, `python3`
- **Internet**: Required for downloads
- **Permissions**: `sudo` may be required to install dependencies

## 📦 Quick Install

```bash
wget -O yt-downloader.sh https://raw.githubusercontent.com/renegadothedev/youtube-downloader/main/yt-downloader.sh
chmod +x yt-downloader.sh
./yt-downloader.sh
```

Or with `curl`:

```bash
curl -L -o yt-downloader.sh https://raw.githubusercontent.com/renegadothedev/youtube-downloader/main/yt-downloader.sh
chmod +x yt-downloader.sh
./yt-downloader.sh
```

## 🚀 Usage

Start the script:

```bash
./yt-downloader.sh
```

Then choose one of the menu options:

1. Download Video
2. Download Audio
3. Update yt-dlp
4. View Download History
5. Exit

## 🎯 Quality and Format Options

### Video qualities supported by the script

- `max` — Best available quality
- `4k` — Up to 2160p
- `2k` — Up to 1440p
- `1080p` — Up to 1080p
- `720p` — Up to 720p

### Video formats

- `mp4`
- `mkv`
- `webm`

### Audio formats

- `mp3`
- `m4a`
- `flac`
- `wav`

## ⚙️ Configuration

The script stores persistent settings in:

```bash
~/.yt_downloader_config
```

Example config content:

```bash
DEFAULT_QUALITY="1080p"
DEFAULT_FORMAT="mp4"
SAVE_HISTORY=true
AUTO_UPDATE=true
```

The configuration file controls:

- default quality and format values
- whether download history is saved

## 📁 Output Structure

The tool stores downloads and logs under the default directory:

```text
$HOME/Downloads/YT_Downloads/
├── videos/          # downloaded video files
├── audio/           # extracted audio files
├── logs/            # yt-dlp and script logs
└── history.log      # download history
```

## 🐛 Troubleshooting

### Missing dependencies
Install missing dependencies manually:

```bash
sudo apt update && sudo apt install yt-dlp ffmpeg curl python3
```

On Arch Linux:

```bash
sudo pacman -S yt-dlp ffmpeg curl python
```

On macOS:

```bash
brew install yt-dlp ffmpeg curl python
```

### Download failed
Check your Internet connection and try a lower quality.

### Format not available
List available formats with:

```bash
yt-dlp -F "URL"
```

### View logs

```bash
tail -f "$HOME/Downloads/YT_Downloads/logs/yt_downloader.log"
cat "$HOME/Downloads/YT_Downloads/history.log"
```

## 🔄 Updating yt-dlp

Choose option 3 in the interactive menu to update `yt-dlp`.

To update manually:

```bash
yt-dlp -U
```

## 💡 Notes

- The script currently runs in interactive mode and does not support direct CLI arguments.
- It uses `yt-dlp` instead of `youtube-dl`.
- The `AUTO_UPDATE` setting is currently stored in the config file but not used for automatic self-updates.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🆘 Support

If you need help:

- Check the troubleshooting section above
- Review the logs at `$HOME/Downloads/YT_Downloads/logs/yt_downloader.log`
- Open an issue on GitHub with a detailed description, commands run, log output, and system information

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.

## 👨‍💻 Author

**Renegado** - [@renegado](https://github.com/renegadothedev)

---

**⭐ If this project was helpful, give it a star on GitHub!**

![Footer](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg?style=for-the-badge)
![Open Source](https://img.shields.io/badge/Open%20Source-❤-red.svg?style=for-the-badge)

## HOW TO USE (detailed)

Full multilingual usage instructions are available in the `HOWTOUSE.md` file. See that file for step-by-step install, run, examples and troubleshooting in Português, Español, English and Русский.

Quick start:

```bash
chmod +x yt-downloader.sh
./yt-downloader.sh
```

PowerShell (cross-platform):

```powershell
pwsh ./yt-downloader.ps1
```

