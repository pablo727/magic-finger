# 🧙‍♂️ Magic Finger

A colorful, customizable system info CLI tool — a modern reimagination of the classic `finger` command.

![screenshot](assets/demo.png) <!-- Optional: replace with your actual screenshot path -->

---

## ✨ Features

- 🔍 Shows detailed user info:
  - Username, shell, home dir
  - Last login, login status
  - Uptime, home file count
- 🎨 Colorful output with emoji and ANSI styles
- ⚡ Blazing Fast using `ripgrep` (Rust-powered)
- 📋 Optional Markdown export with `glow`
- 🧠 Easily extensible with flags

---

## 🔧 Available Options

Flag               Description
--markdown         Show output as Markdown using `glow`
--copy             Copy output to clipboard (`xclip` / `pbcopy`)
--all              Loop through all users on the system

ℹ️ If no flag is provided, it runs for the current user only.

---

## 🛠 Requirements

- `bash` (tested on 5.2+)
- `ripgrep`
- `lastlog`
- `glow` (for Markdown preview)
- `xclip` or `pbcopy` (for --copy)

Install dependencies on Debian/Ubuntu:

```bash
sudo apt install ripgrep fzf
```

Install `glow` manually:

```bash
curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest \
| grep browser_download_url | grep amd64.deb | cut -d '"' -f 4 \
| wget -qi - && sudo dpkg -i glow*.deb
```

## 🧪 Example

```bash
./magic-finger.sh --markdown --copy
```

---

## 🚀 Contributing 

Want to add features? Fork the repo and send a PR! 

---

## 📜 License

MIT License — do what you want, just give credit 🙏

---

## 👣 Inspired By

- The original Unix finger
- ripgrep
- glow

