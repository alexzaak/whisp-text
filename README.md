# WhispText

WhispText is a native macOS agent application that brings beautifully integrated, completely local **Voice-to-Cursor** transcription to your Mac. 

Instead of dealing with third-party web apps or copy-pasting text, WhispText allows you to dictate anywhere on your computer. When triggered via a global hotkey, it captures your voice, transcribes it locally using the power of Apple Silicon, and instantly types the finalized sentence directly into your active input field (Chrome, Word, Slack, etc.).

## 🚀 Features

- **Blazing Fast Local AI:** Uses Apple's CoreML and `WhisperKit` internally to run OpenAI's Whisper models on-device 100% locally. Zero cloud APIs, zero subscriptions, complete privacy.
- **Dynamic Multilingual Models:** Instantly swap between `Tiny`, `Base`, and `Small` model tiers directly from the Menu Bar. The app natively downloads and configures the requested `.mlpackage` from Hugging Face on the fly.
- **Native Language Targets:** Skip slow "Auto-Detect" processing by explicitly targeting your spoken language (like German or English) via the UI Settings to maximize transcription speed and structural accuracy.
- **Push-to-Talk Architecture:** Hold down `Fn + Shift` to record, and release the keys to immediately drop the text.
- **Native Text Injection:** Automatically simulates `Cmd + V` via the macOS Accessibility APIs to "type" your transcription into whatever application currently holds cursor focus. 
- **Floating HUD Overlay:** When enabled, an elegant glass macOS HUD pops up above your dock to show you the transcription streaming in real-time as you speak, so you aren't talking into the void. This can be toggled natively in the menu bar.
- **Background Prewarming:** Automatically compiles its neural graph silently when launched, completely eliminating the standard 1-2 minute CoreML "warm-up" delay on your first dictation.
- **Hallucination Scrubbing:** Automatically filters out common Whisper artifacts like `[BLANK_AUDIO]`, `[Silence]`, and `(INAUDIBLE)` natively.
- **Invisible Footprint:** Runs entirely as an `LSUIElement`, meaning absolutely no annoying Dock icon—just a quiet, interactive Menu Bar extra.

---

## 📥 Installation

### Method 1: Homebrew (Recommended)
You can easily install WhispText dynamically compiled directly from source using the official Homebrew Tap algorithm:
```bash
brew tap alexzaak/whisp-text
brew install --build-from-source whisptext
```
*Homebrew will automatically download dependencies, compile the MacOS application natively for your Silicon architecture, and provide instructions on linking it to your `/Applications` directory.*

---

### Method 2: Manual Build (For Developers)
WhispText uses Swift Package Manager to natively handle its ML dependencies. To build the macOS App Bundle from the raw source code yourself:

1. Clone or download the repository to your Mac.
   ```bash
   git clone https://github.com/alexzaak/whisp-text.git
   ```
2. Open your terminal in the root directory and ensure the script is executable:
   ```bash
   chmod +x build.sh
   ```
3. Run the automated build script. This will compile the Swift packages and assemble the native `.app` bundle:
   ```bash
   ./build.sh
   ```
4. Once built successfully, launch it via terminal:
   ```bash
   open build/WhispText.app
   ```

*Note: You will be prompted to grant **Microphone** and **Accessibility** permissions the first time you run the app and attempt to dictate. Follow the on-screen macOS System Settings prompts!*

---

## 🔒 Fixing The "Permissions Loop" (Security Reset)

Because WhispText is built locally using a standalone shell script rather than an official Xcode Developer Identity, macOS assigns an "ad-hoc" signature to the binary. 

**The Bug:**
If you make a change to the source code and run `./build.sh` again, the binary signature changes. The macOS TCC (Transparency, Consent, and Control) security subsystem immediately drops the app's Accessibility permissions to protect your computer, but visually leaves the toggle switch "On" in System Settings. This creates a loop where the app endlessly begs for permission despite the switch being flipped.

**The Fix:**
To wipe the security database and fix the loop, close the app and forcefully reset its permissions list via the terminal:

```bash
killall WhispText
tccutil reset Accessibility com.zaak.codes.WhispText
open build/WhispText.app
```
*After running this, macOS will correctly see the app as new and allow you to toggle the Accessibility switch back on for real.*
