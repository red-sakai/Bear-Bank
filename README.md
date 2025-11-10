# Bear Bank – Bubu & Dudu Budget Tracker

A playful, offline-first budget tracking app themed around Bubu & Dudu. Track income and expenses, set monthly budgets per category, view reports, enjoy scattered couple photos in the background, browse memes, and listen to your own music while you manage your money.

## ✨ Features

- Local, offline storage using Hive (no code generation required)
- Transactions: income and expenses with categories and notes
- Budgets: per-category monthly limits with progress bars
- Dashboard: monthly income, expenses, and net summary
- Reports: pie chart spending breakdown by category
- Instructions tab: friendly guide text
- Memes gallery: reads images from `assets/images/memes`
- Scattered couple pics background: unobtrusive decorative photos using your own images
- Reactive overlays: fun income/expense animations with sounds
- Optional mini music player overlay: spinning disc + prev/play/next controls
- Cross‑platform Flutter app (Android, iOS, Windows, macOS, Web)

## 📁 Project structure

```
lib/
	app_shell.dart              # MultiProvider + MaterialApp theme/routes
	main.dart                   # Splash bootstrapping
	models/                     # CategoryType, BankTransaction, Budget + adapters
	screens/                    # Dashboard, Transactions, Budgets, Reports, etc.
	state/                      # Providers (TransactionProvider, BudgetProvider)
	widgets/                    # Reusable UI (budget bars, scattered background, music overlay)
	services/                   # MusicPlayerController
assets/
	gifs/                       # Splash and overlays
	audio/                      # SFX and music
		music_player/            # Your MP3s for the in‑app player
	images/
		couple-pics/             # Your personal photos (JPG/PNG/WEBP; HEIC not supported)
		memes/                   # Memes shown in the Memes tab
```

## 🧰 Tech

- Flutter + Material 3
- Provider for state management
- Hive + hive_flutter for local persistence (manual adapters)
- intl for currency formatting
- fl_chart for reports
- audioplayers for audio (splash, overlays, music player)

## 🚀 Setup

Prerequisites:
- Flutter installed and on PATH
- A recent Flutter stable that supports Dart `^3.9.2` (matches `pubspec.yaml`)

Install dependencies:

```powershell
flutter pub get
```

Run (Windows example):

```powershell
flutter run -d windows
```

Build (Android example):

```powershell
flutter build apk
```

## 📸 Adding your media

- Couple photos background: put JPG/PNG/WEBP files in `assets/images/couple-pics/`.
	- Note: HEIC is not supported by Flutter’s Image widget; convert to JPG/PNG.
	- The background places multiple images per screen without overlapping and uses every image once before repeating.

- Memes tab: put images in `assets/images/memes/`.

- Audio:
	- SFX (overlays/splash) live under `assets/audio/`.
	- Optional music player looks for MP3s in `assets/audio/music_player/`.
	- After adding files, make sure the paths are listed in `pubspec.yaml` (already configured) and run `flutter pub get`.

## 🎵 Mini music player overlay

- A spinning disc appears at the bottom‑left. Tap the disc to show/hide the control pill.
- Controls: Previous · Play/Pause · Next
- Playlist sources (in order):
	1) Filesystem folder on Windows: `C:\Github Projects\bear_bank\assets\audio\music_player`
	2) Bundled assets under `assets/audio/music_player/` (fallback)
- The title of the current track is shown as a tooltip on the play button.
- To change the filesystem path, edit `_musicDir` in `lib/services/music_player_controller.dart`.

## 🧭 Using the app

- Dashboard: see month label, income, expenses, and net, plus budget utilization
- Transactions: add income/expense with category, note, date
- Budgets: create monthly category limits; see progress bars
- Reports: pie chart of monthly spending by category
- Instructions: friendly guide text in a dedicated tab
- Memes: grid gallery with tap‑to‑zoom viewer

## 🛠️ Development notes

- Providers are attached at the top level in `AppShell` to ensure context is available across routes.
- Hive boxes and adapters are initialized during app startup (see `Splash`/`AppShell`).
- Manual Hive adapters are used for the models to avoid build_runner.
- Launcher icons are configured via `flutter_launcher_icons` (see `pubspec.yaml`).

Generate launcher icons (optional):

```powershell
flutter pub run flutter_launcher_icons:main
```

## ❓ Troubleshooting

- Photos not appearing in the background: ensure images are JPG/PNG/WEBP (not HEIC), placed in `assets/images/couple-pics/`, then hot restart.
- Memes not showing: verify files exist in `assets/images/memes/` and run `flutter pub get`.
- No sound on overlays/music: check volume, confirm MP3 files exist in `assets/audio/music_player/` (for music), and that the files aren’t DRM‑protected.
- On Windows you may see a plugin threading warning from `audioplayers`; it’s generally non‑fatal. Music and SFX should still work.

## ✅ Roadmap / ideas

- Settings page: toggle background density/opacity, enable/disable overlays and music player
- Show song title and progress inline in the control pill
- Shuffle/repeat and queue controls
- Basic unit tests for models and budgeting logic

---

Made with Flutter and a lot of 🐻🖤
