# Dizzy

> Stream anything, anywhere. Movies, TV shows, music, manga, comics, audiobooks, live sports, anime, Asian dramas — all in one app.

Made by **[Sirius6907](https://github.com/Sirius6907)**

[![Build Status](https://github.com/Sirius6907/Dizzy/actions/workflows/build.yml/badge.svg)](https://github.com/Sirius6907/Dizzy/actions/workflows/build.yml)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/github/v/release/Sirius6907/Dizzy)](https://github.com/Sirius6907/Dizzy/releases/latest)

---

## Features

### 🎬 Movies & TV Shows
- Browse & stream movies/TV shows with full TMDB metadata
- Built-in libtorrent engine (torrent streaming — no VLC needed)
- Stremio addon ecosystem support
- Real-Debrid & TorBox debrid integration
- Subtitles via SubtitleCat / MySubs
- Auto-resume, watch history, continue watching
- Jellyfin server integration

### 🎵 Music
- Stream music via Deezer catalog + YouTube audio backend
- Synced lyrics, full player queue (shuffle, repeat, crossfade)
- Playlists, liked songs, albums
- Offline download to device storage

### 📖 Manga, Comics & Books
- Multi-source manga reader (page / continuous scroll)
- Comics from ReadComicsOnline
- Epub book reader
- Chapter progress tracking

### 🎧 Audiobooks & Paper2Audio
- Stream from LibriVox and other sources
- Chapter navigation + speed control
- Convert PDFs/papers to audio (Paper2Audio)

### 📺 Anime
- AllAnime + Miruro streaming
- Arabic-dubbed anime
- Asian drama streaming (KissKH)
- Anime search & episode tracking

### 🏆 Live Sports & IPTV
- Live match streams from multiple sources
- Xtream Codes API + M3U playlist IPTV
- Live TV & VOD

### ⚙️ More
- Prowlarr / Jackett torrent indexer integration
- Nuvio extension engine (custom scrapers)
- Trakt & SIMKL scrobbling
- Auto-update on launch (no need to manually check releases)
- Magnet link player

---

## Download

**[→ Latest Release](https://github.com/Sirius6907/Dizzy/releases/latest)**

| Platform | File |
|----------|------|
| 🪟 Windows | `Dizzy-Windows-Setup.exe` (Installer) |
| 🐧 Linux | `Dizzy-Linux-x86_64.AppImage` |
| 🍎 macOS Apple Silicon | `Dizzy-macOS-arm64.dmg` |
| 🍎 macOS Intel | `Dizzy-macOS-intel.dmg` |
| 📱 iOS (sideload) | `Dizzy-iOS.ipa` |
| 🤖 Android | APK (manual build / see CI) |
| 🌐 Web | [sirius-dizzy.pages.dev](https://sirius-dizzy.pages.dev) |

---

## Building

You need Flutter stable and platform build tools.

```bash
# Get dependencies
flutter pub get

# Build for your platform
flutter build windows
flutter build linux
flutter build macos
flutter build apk
flutter build ios --no-codesign
flutter build web
```

---

## CI/CD

Every push to `main` and every `v*` tag triggers GitHub Actions:

- **Windows** — Inno Setup installer
- **Linux** — AppImage (x86_64)
- **macOS** — DMG (Apple Silicon + Intel)
- **iOS** — Sideloadable IPA
- **Web** — Auto-deployed to **Cloudflare Pages** on every `main` push or tag

Secrets required (`Settings → Secrets`):
```
TRAKT_CLIENT_ID / TRAKT_CLIENT_SECRET
SIMKL_CLIENT_ID / SIMKL_CLIENT_SECRET
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
```

---

## License

[GPL-2.0](LICENSE) — Based on [PlayTorrioV2](https://github.com/AimesSoft/PlayTorrioV2), rebranded and maintained separately.
