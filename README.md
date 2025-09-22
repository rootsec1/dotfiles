# 🚀 rootsec1's dotfiles

> ✨ My personal development environment configuration files for macOS, featuring a modern Neovim setup with custom hotkeys.

## 📸 Screenshots

### 🌳 LazyGit integration
<img width="1792" height="1120" alt="Screenshot 2025-09-21 at 10 06 24 PM" src="https://github.com/user-attachments/assets/a5d6ad9a-a925-4131-9d7c-d9522181a68a" />

### 🌳 File Tree and Editor
<img width="1792" height="1120" alt="Screenshot 2025-09-21 at 10 02 38 PM" src="https://github.com/user-attachments/assets/e0de8769-8859-4eb4-8e59-709ee7aa9deb" />


## 🌟 Features

### 🎨 Neovim Configuration
A fully-featured IDE-like setup with:

- 🎭 **Modern UI**: Catppuccin Mocha theme with transparent background
- 📁 **File Management**: Neo-tree file explorer with git integration  
- 🔍 **Fuzzy Finding**: Telescope for files and text search with FZF integration
- 💻 **Language Support**: LSP integration for Lua, TypeScript/JavaScript, and Python
- 🧠 **Auto-completion**: Intelligent code completion with nvim-cmp
- 🌈 **Syntax Highlighting**: Treesitter-powered highlighting
- 🔧 **Git Integration**: LazyGit integration and git status indicators
- ⚡ **Auto-formatting**: Format-on-save with language-specific formatters
- 🎯 **VS Code-like Shortcuts**: Familiar keybindings for easy transition

### ✨ Key Features

- 📋 **Tab Management**: Bufferline with VS Code-style tabs
- 💾 **Auto-save**: Saves on focus loss and buffer switch
- 📱 **Smart Clipboard**: System clipboard integration
- 📏 **Indent Guides**: Visual indentation lines
- 🔗 **Auto-pairs**: Automatic bracket and quote completion
- 🎨 **File Icons**: Nerd font icons throughout the interface

## 📋 Prerequisites

### 🍎 macOS Dependencies
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install neovim                    # 🚀 The editor itself
brew install ripgrep                   # 🔍 For telescope live grep
brew install lazygit                   # 🔧 Git TUI integration
brew install font-fira-code-nerd-font  # 📝 For icons
```

### 💻 Terminal Setup
- **Terminal**: Warp 🌊 (recommended) or iTerm2
- **Font**: FiraCode Nerd Font 🔤 (for proper icon display)

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

## 📁 Configuration Structure

```
nvim/
├── init.lua           # 🏠 Main configuration file
├── lua/
│   └── plugins.lua    # 🧩 Plugin definitions
└── lazy-lock.json     # 🔒 Plugin version lockfile
```

## ⌨️ Key Bindings

### 📂 File Operations
- `Ctrl + P` - 🔍 Find files (opens in new tab)
- `Ctrl + F` - 🔎 Search in current file
- `Space + F` - 🌍 Search in all files (live grep)
- `Ctrl + B` - 🌳 Toggle file explorer

### 📑 Tab Management
- `Shift + Tab` - ➡️ Next tab
- `Ctrl + W` - ❌ Close current tab
- `Space + Q` - 🚪 Quit all

### 💡 VS Code-like Shortcuts
- `Ctrl + S` - 💾 Save file
- `Ctrl + A` - 📝 Select all
- `Ctrl + Z` - ↩️ Undo
- `Ctrl + Y` - ↪️ Redo
- `Ctrl + D` - 📋 Duplicate line
- `Ctrl + C/X/V` - 📋📝📎 Copy/Cut/Paste (system clipboard)
- `Ctrl + K` - ✨ Format file

### 🔧 Git Integration
- `Space + G` - 🚀 Open LazyGit

### 🧠 LSP Features
- `Space + E` - ❌ Show error details
- Auto-completion with `Tab` and `Enter` ✨
- Format-on-save enabled 🎯

## 💻 Language Support

### 🛠️ Included Language Servers
- 🌙 **Lua**: lua_ls (with Neovim-specific configuration)
- 📜 **TypeScript/JavaScript**: ts_ls (works for both .js and .ts files)
- 🐍 **Python**: Pyright (with virtual environment support)

### 🐍 Python Virtual Environment Setup
For Python projects, create a `pyrightconfig.json` in your project root:
```json
{
    "venvPath": ".",
    "venv": "env"
}
```

### ➕ Adding More Languages
Use `:Mason` to install additional language servers, formatters, and linters through the built-in interface. 🎛️

## 🎨 Customization

### 🌈 Theme
The configuration uses Catppuccin Mocha with transparent background. To modify:
- Edit the `catppuccin.setup()` block in `init.lua`
- Available flavors: `latte` ☕, `frappe` 🥤, `macchiato` 🍵, `mocha` 🍫

### ⌨️ Keybindings
All keybindings are defined in the "Keymaps" section of `init.lua` and can be easily modified.

### 🧩 Adding Plugins
Add new plugins to `lua/plugins.lua` following the existing pattern.

## 🔧 Troubleshooting

### 🎨 Icons Not Showing
- Ensure you're using FiraCode Nerd Font in your terminal
- Check terminal font settings: should be "FiraCode Nerd Font", not just "Fira Code"

### 📋 Clipboard Issues
- The configuration uses explicit system clipboard registers (`"+`)
- If issues persist, check `:checkhealth` for clipboard support

### 🐍 Python Virtual Environment Not Detected
- Create `pyrightconfig.json` in your project root
- Ensure your virtual environment is named `env` or update the config accordingly

### 💻 LSP Not Working
- Run `:Mason` to ensure language servers are installed
- Check `:LspInfo` for server status
- Use `:checkhealth` to diagnose issues
