Feature: Opaque VS Code / ZZZZion shell rebuild with VS Code High Contrast-style palette

Approach:
Keep `nvim-tree.lua` for the pinned sidebar, but push `snacks.nvim` further so
it owns the fast transient UI layer: picker, input, notifier history, LazyGit,
statuscolumn, big-file fallback, git browser links, and LSP reference jumping.
The palette shifts from softer One Dark tones to a VS Code High Contrast
Dark-style look: fluorescent green structural borders, orange
search/current-line accents, and brighter purple / green / yellow syntax. The
main editor and tree backgrounds stay transparent so Ghostty's translucency
shows through behind the shell, but the text colors are pushed brighter to keep
code legible.

Why:
The earlier Snacks integration worked, but only partially. Search and LazyGit
used Snacks, while other high-value modules were left off and the docs had
already drifted away from the real config. This pass keeps the stable layout
and closes the integration gaps without replacing the editor shell again.

Alternatives considered:
- Keep the transparent editor look and only retune colors.
- Replace `nvim-tree.lua` again.

Edge cases:
- Closing the last file must still leave one blank editor beside the tree.
- Closing an inactive tab while the tree is focused must not stretch the
  sidebar or replace the tree buffer.
- Mouse clicks on buffer tabs must target the editor surface, not whichever
  pane happens to be focused.
- File-tree clicks must open and expand nodes reliably with a single click.
- LazyGit must receive mouse events inside the terminal float instead of
  falling back to keyboard-only behavior.
- `checkhealth snacks` must not create stray files through global autosave.
- Notification history must open reliably even with no existing picker state.
- Clean file buffers must refresh from disk when external tools like Codex edit
  them.
- Scratch and picker buffers must stay out of the tabline.
- Python, Node, Rust, and Go workspace detection must keep working after the UI
  rebuild.
- Markdown must still avoid the Neovim 0.12 Treesitter crash path.

Decision:
Use `onedark.nvim` as the base theme, then apply explicit highlight overrides in
`config.ui` so the explorer, editor, tabs, and pickers all share the same
shell. `mini.statusline` was removed; `lualine.nvim` now provides a bubble
statusline with RGBY mode accents. `snacks.nvim` covers picker, input, notifier
history, LazyGit, statuscolumn, bigfile, words, and gitbrowse. The high-value
entry points are wired directly: notification history, command history, git
status, git log, grep word, and browser links for the current git file. Mouse
support is enabled globally in Neovim, tree clicks are explicitly
mapped through `nvim-tree` `on_attach`, Bufferline routes mouse tab selection
through `config.workspace.focus_buffer(bufnr)` so the tree cannot be hijacked,
and LazyGit reads a repo-managed config with `gui.mouseEvents: true`. The
highlight layer now targets the reference screenshot more directly:
transparent editor and sidebar backgrounds over the Ghostty window,
fluorescent green borders, orange active accents, and VS Code-like purple
keywords. The repo-managed Ghostty profile now adds explicit black-and-green
palette overrides, green cursor and selection styling, and shell-integration
title and cursor features so the terminal chrome feels like the same shell as
Neovim. The translucent background remains, but the Ghostty profile now uses a
higher opacity, lower blur radius, and opaque cell backgrounds so text stays
crisp instead of washing out. Neovim keeps the editor surface transparent, but
uses brighter foreground colors while floats and overlays remain opaque for
search, diagnostics, and prompts.
`checkhealth` buffers are now excluded from autosave so running Snacks health
does not drop an `Untitled` file into the repo. External file reload is now
part of the editor contract through `autoread` plus guarded `checktime`
refreshes for real unmodified file buffers, so Codex edits on disk show up when
focus returns. Verification now includes the existing smoke test, a 131-case
E2E flow suite, and startup timing.
