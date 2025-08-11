# 🎬 YouTube Stream Tool

<div align="center">

![GitHub stars](https://img.shields.io/github/stars/Properryxx/youtube-stream-tool?style=for-the-badge&color=gold)
![GitHub forks](https://img.shields.io/github/forks/Properryxx/youtube-stream-tool?style=for-the-badge&color=blue)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg?style=for-the-badge)

**🚀 A powerful, interactive YouTube streaming tool with quality selection and fallback support**

*Stream YouTube videos directly in MPV with an elegant interface powered by fzf*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎯 **Core Functionality**
- 🔄 **Multiple client fallbacks** (web, android, ios, tv)
- 🎛️ **Interactive quality selection** with fzf
- 📺 **Direct MPV integration** with hardware acceleration
- 🔊 **Smart audio handling** for video-only formats
- ⚡ **Automatic fallback** when formats fail

</td>
<td width="50%">

### 🛠️ **Technical Features**
- 🔍 **Format verification** before playback
- 📋 **Detailed format information** (codec, fps, size)
- 🎚️ **Custom quality presets** (AUTO, BEST)
- 🔧 **Robust error handling**
- 💻 **Optimized for Linux**

</td>
</tr>
</table>

## 🖼️ Screenshots

### Interactive Quality Selection
```
ID   EXT      RESOLUTION   FPS      VCODEC   ACODEC       SIZE
AUTO best      auto         -        -        auto         (best available quality)
BEST best[height<=1080] 1080p-max    -        -        with-audio   (best up to 1080p with audio)
────────────────────────────────────────────────────────────────────────────────────────
251  webm     audio only   -        -        opus         ~3.2MiB
140  m4a      audio only   -        -        mp4a         ~5.1MiB
394  mp4      256x144      30fps    av01     video-only   ~1.2MiB
> 396  mp4      426x240      30fps    av01     video-only   ~2.1MiB
397  mp4      640x360      30fps    av01     video-only   ~3.8MiB
298  mp4      1280x720     60fps    h264     video-only   ~15.2MiB
```

## 📋 Requirements

Before using this tool, ensure you have the following dependencies installed:

| Dependency | Purpose | Installation |
|------------|---------|-------------|
| 🎥 **yt-dlp** | YouTube video extraction |  Python `pip install yt-dlp` Ubuntu/Debian 'sudo apt install yt-dlp' |
| 📺 **mpv** | Video player | `sudo apt install mpv` |
| 🔍 **fzf** | Interactive selection | `sudo apt install fzf` |
| 🎬 **ffmpeg** | Media processing | `sudo apt install ffmpeg` |

## 🚀 Installation

### Method 1: Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/Properryxx/youtube-stream-tool.git
cd youtube-stream-tool

# Make the script executable
chmod +x youtube-stream.sh

# Optional: Add to PATH for global access
sudo ln -s $(pwd)/youtube-stream.sh /usr/local/bin/youtube-stream
```

### Method 2: Manual Download

```bash
# Download the script directly
wget https://raw.githubusercontent.com/Properryxx/youtube-stream-tool/main/youtube-stream.sh

# Make it executable
chmod +x youtube-stream.sh
```

### Dependencies Installation (Ubuntu/Debian)

```bash
# Install all required dependencies
sudo apt update
sudo apt install mpv ffmpeg fzf python3-pip -y
pip3 install yt-dlp

# Verify installation
yt-dlp --version && mpv --version && fzf --version
```

## 💻 Usage

### Basic Usage

```bash
# Stream a YouTube video with quality selection
./youtube-stream.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# If installed globally
youtube-stream "https://www.youtube.com/watch?v=VIDEO_ID"
```

### Advanced Examples

```bash
# Example with a real YouTube URL
./youtube-stream.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# The script will present an interactive menu like this:
# ┌─ Select video quality ─────────────────────────────────┐
# │ > AUTO best (best available quality)                   │
# │   BEST best[height<=1080] (1080p-max with audio)      │
# │   ──────────────────────────────────────────────────   │
# │   251  webm  audio only                                │
# │   396  mp4   426x240    30fps  av01  video-only       │
# │   397  mp4   640x360    30fps  av01  video-only       │
# │   298  mp4   1280x720   60fps  h264  video-only       │
# └────────────────────────────────────────────────────────┘
```

### Quality Selection Options

| Option | Description | Best For |
|--------|-------------|----------|
| 🤖 **AUTO** | Best available quality (automatic) | Quick streaming |
| 🎯 **BEST** | Best up to 1080p with audio | Balanced quality/bandwidth |
| 📝 **Manual** | Choose specific format ID | Custom requirements |

## 🔧 Configuration

### MPV Settings
The script uses optimized MPV settings:
- Hardware acceleration disabled for compatibility
- GPU rendering with OpenGL
- Custom format specifications

### Client Fallbacks
Automatic fallback through multiple YouTube clients:
1. 🌐 **Web** - Primary client
2. 📱 **Android** - Mobile fallback
3. 🍎 **iOS** - Alternative mobile
4. 📺 **TV** - Smart TV client
5. 🎬 **Android Creator** - Creator studio client

## 🐛 Troubleshooting

<details>
<summary><strong>🚫 "Could not fetch video formats"</strong></summary>

**Solution:**
- Verify the YouTube URL is correct
- Check your internet connection
- Update yt-dlp: `pip3 install -U yt-dlp`
</details>

<details>
<summary><strong>⚠️ "YouTube blocked format"</strong></summary>

**Solution:**
- The script automatically tries fallback formats
- Use the AUTO or BEST options for better compatibility
- Some high-resolution formats may be restricted
</details>

<details>
<summary><strong>🔊 Audio issues with video-only formats</strong></summary>

**Solution:**
- The script automatically combines video-only with best audio
- If issues persist, choose formats that include audio
- Check MPV audio output configuration
</details>

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Bug Reports
- Use the [issue tracker](https://github.com/Properryxx/youtube-stream-tool/issues)
- Include script output and error messages
- Specify your Linux distribution and versions

### 💡 Feature Requests
- Check existing [feature requests](https://github.com/Properryxx/youtube-stream-tool/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)
- Describe your use case clearly
- Consider submitting a pull request!

### 🔧 Development

```bash
# Fork the repository and clone your fork
git clone https://github.com/Properryxx/youtube-stream-tool.git
cd youtube-stream-tool

# Create a feature branch
git checkout -b feature/amazing-feature

# Make your changes and test
./youtube-stream.sh "https://www.youtube.com/watch?v=test"

# Commit and push
git commit -m "Add amazing feature"
git push origin feature/amazing-feature
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- 🎥 **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** - Powerful YouTube downloader
- 📺 **[mpv](https://mpv.io/)** - Excellent media player
- 🔍 **[fzf](https://github.com/junegunn/fzf)** - Command-line fuzzy finder
- 🎬 **[ffmpeg](https://ffmpeg.org/)** - Media processing framework

## 📊 Stats

<div align="center">

![GitHub repo size](https://img.shields.io/github/repo-size/Properryxx/youtube-stream-tool?style=flat-square)
![GitHub code size](https://img.shields.io/github/languages/code-size/Properryxx/youtube-stream-tool?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/Properryxx/youtube-stream-tool?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/Properryxx/youtube-stream-tool?style=flat-square)

</div>

---

<div align="center">
<strong>⭐ If you found this tool helpful, please give it a star! ⭐</strong>

*Made with ❤️ for the Linux community*
</div>
# youtube-stream-sh
