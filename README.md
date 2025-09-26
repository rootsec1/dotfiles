# 🚀 dotfiles

> ✨ My personal development environment configuration files for macOS, featuring a modern **Neovim IDE setup** with AI-assisted coding, fuzzy finding, custom UI, and VS Code-like shortcuts.

## 📸 Screenshots

### 🌳 LazyGit integration

<img width="1792" height="1120" alt="Screenshot 2025-09-25 at 11 46 54 PM" src="https://github.com/user-attachments/assets/0ec366c7-43af-4d87-8494-63926d785d7f" />

### 🌳 File Tree and Editor with autocomplete

<img width="1792" height="1120" alt="Screenshot 2025-09-25 at 11 45 11 PM" src="https://github.com/user-attachments/assets/9323e620-dfb2-4712-909b-b11eea51b0cf" />

### 🌳 Fuzzy finding (live grep) across codebase

<img width="1792" height="1120" alt="Screenshot 2025-09-25 at 11 48 01 PM" src="https://github.com/user-attachments/assets/82d4ddf0-47e7-4a1e-b39b-8f8be40890af" />

---

## 🌟 Features

### 🎨 Neovim Configuration

An IDE-like workflow built on **lazy.nvim** plugin manager with:

* 🎭 **Modern UI**: Cyberdream theme (dark + transparent)
* 📁 **File Management**: Neo-tree explorer with git + diagnostics integration
* 🔍 **Fuzzy Finding**: Telescope with FZF-native + UI select
* 🧠 **AI Assistant**: CodeCompanion (OpenAI adapter) for inline and chat-based coding help
* 🌈 **Syntax Highlighting**: Treesitter for Lua, JavaScript/TypeScript, Python
* 💻 **LSP Integration**: lua_ls, ts_ls, pyright via Mason & nvim-lspconfig
* ⚡ **Completion**: nvim-cmp with LSP sources
* 📊 **Statusline**: Lualine with branch/diff/diagnostics
* 📑 **Tabs**: Bufferline with styled tabs and inline diagnostics
* 🧩 **Git Integration**: LazyGit + gitsigns
* 🔧 **Auto-formatting**: Format on save using LSP
* ✍️ **Commenting**: Comment.nvim with `gcc`/`gc` style mappings
* 🐼 **LSP Signature Help**: Inline function hints with borders + emoji hints
* 🪟 **Enhanced Cmdline**: fine-cmdline with styled popup prompt
* 🚨 **Diagnostics**: Trouble.nvim for quick error/usages navigation

---

## 📋 Prerequisites

### 🍎 macOS Dependencies

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install neovim                    # 🚀 Neovim editor
brew install ripgrep                   # 🔍 For telescope live grep
brew install lazygit                   # 🔧 Git TUI integration
brew install font-fira-code-nerd-font  # 📝 Nerd Font for icons
```

### 💻 Terminal Setup

* **Terminal**: Warp 🌊 (recommended) or iTerm2
* **Font**: FiraCode Nerd Font 🔤

---

## 🛠️ Installation

1. 📥 Clone the repository:

```bash
git clone https://github.com/rootsec1/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. 🔄 Backup existing Neovim configuration:

```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
```

3. 🔗 Create symbolic link:

```bash
ln -sf ~/.dotfiles/nvim ~/.config/nvim
```

4. 🎉 Start Neovim and let plugins install automatically:

```bash
nvim
```

---

## 📁 Configuration Structure

```
nvim/
├── init.lua           # 🏠 Main config (settings, plugin setup, keymaps)
├── lua/
│   └── plugins.lua    # 🧩 Plugin definitions
└── lazy-lock.json     # 🔒 Plugin lockfile
```

---

## ⌨️ Key Bindings

### 📂 File & Search

* `Ctrl + P` → Find files (open in new tab)
* `Ctrl + F` → Search in current file
* `Space + F` → Live grep across project
* `Ctrl + B` → Toggle file explorer

### 📑 Tabs

* `Shift + Tab` → Next tab
* `Ctrl + W` → Close tab
* `Space + Q` → Quit all

### 💡 Editing & Navigation

* `Ctrl + S` → Save
* `Ctrl + A` → Select all
* `Ctrl + Z` → Undo
* `Ctrl + Y` → Redo
* `Ctrl + D` → Duplicate line
* `Ctrl + H` → Find & replace
* `Ctrl + G` → Go to definition
* `Ctrl + U` → Show usages (Trouble)
* `Ctrl + I` → Hover info

### 🔧 Git

* `Space + G` → Open LazyGit

### 🧠 LSP & AI

* `Space + E` → Show error details
* `Ctrl + K` → Format file
* `Ctrl + L` / `Leader + L` → CodeCompanion inline & chat AI

### 📋 Clipboard

* `Ctrl + C/X/V` → Copy/Cut/Paste (system clipboard)
* Works in normal, visual, and insert modes

### 📝 Commenting

* `gcc` → Toggle line comment
* `gc` → Toggle visual selection comment

### 🐲 Command Line

* `:` → Launch fine-cmdline popup

---

## 💻 Language Support

* 🌙 **Lua** → lua_ls
* 📜 **TypeScript/JavaScript** → ts_ls
* 🐍 **Python** → pyright (virtualenv-aware)

Install more via `:Mason`.

---

## 🎨 Customization

* **Theme**: Cyberdream dark + transparent (`init.lua`)
* **Tabs & Statusline**: bufferline + lualine themed
* **Keymaps**: Easily modifiable in `init.lua`

---

## 🔧 Troubleshooting

* **Icons not showing** → Use FiraCode Nerd Font
* **Clipboard issues** → Run `:checkhealth`
* **LSP not working** → Check `:Mason`, `:LspInfo`
* **Python env not detected** → Add `pyrightconfig.json` to project root

---

⚡ With this setup, Neovim behaves like a **VS Code on steroids** — terminal-native, lightweight, but with AI-assisted coding and fully customizable workflows.
