Inputs:
- `nvim/init.lua`
- Modular config under `nvim/lua/config`
- Plugin specs under `nvim/lua/plugins`
- External CLIs for search, formatting, and language servers

Processing steps:
1. Apply base editor options and bootstrap lazy.nvim.
2. Load a lean plugin set for explorer, picker, completion, LSP, formatting, git, tabs, and key hints.
3. Build a VS Code-like workspace layout through `config.workspace`: `nvim-tree.lua` stays pinned on the left at 34 columns, one editor surface stays on the right, and focus returns to the editor after startup and after closing files.
4. Use `snacks.nvim` for the transient workflow layer: picker, input, notifier history, LazyGit, statuscolumn, big-file handling, git browser links, and LSP reference jumping.
5. Render the main search flows in a centered opaque picker layout with a real border so the overlay stays visually separate from the editor.
6. Map direct terminal-safe VS Code-like shortcuts for search, sidebar toggle, save, comment, duplicate, diagnostics, tabs, and LSP actions.
7. Make `Tab` completion behave simply in insert mode: jump snippet placeholders first, otherwise accept the current completion or open and accept the best match.
8. Detect Python project roots and local virtual environments so Pyright resolves imports from `.venv` automatically.
9. Detect Node project roots from package and lock files, export local `node_modules/.bin` to the language-server process, and prefer the workspace TypeScript SDK when it exists.
10. Detect Rust and Go project roots from Cargo and Go module markers so their language servers attach at the right workspace boundary.
11. Apply a VS Code High Contrast Dark-style UI pass so the main editor shell and tree are transparent over Ghostty, while tabs, statusline, syntax, and float borders keep the black-and-fluorescent-green contrast.
12. Use `lualine.nvim` for a bubble statusline and `bufferline.nvim` for slanted top tabs.
13. Use `Snacks.lazygit()` for the main Git dashboard and `snacks` Git pickers for lightweight status and history views.
14. Apply matching Ghostty window settings for font, padding, subtle translucency, lower blur, opaque cell backgrounds, explicit black-and-green palette overrides, and shell-integration title and cursor features so the terminal shell feels like the same app surface as Neovim without washing out text.
15. Strip directory buffers and placeholder editor artifacts out of the window layout so closing files does not create fake tabs or stretch the sidebar.
16. Route tab-close actions through `config.workspace.close_buffer(bufnr)` so closing a tab does not depend on the currently focused window and cannot replace the tree pane by mistake.
17. Filter Bufferline down to real file buffers only, so the tabline mirrors open files instead of showing explorer or placeholder buffers.
18. Enable `snacks.bigfile` so oversized files skip the expensive editor features that would otherwise slow startup or scrolling.
19. Enable `snacks.words` in normal mode so LSP references can be jumped with `[[` and `]]` without opening a full picker every time.
20. Enable `snacks.gitbrowse` so the current git-tracked file can be opened in the browser directly from Neovim.
21. Add direct Snacks entry points for command history, notification history, git status, git log, grep word, and keymap search instead of limiting Snacks to only the main file/grep picker.
22. Enable mouse support globally with `mouse=a`, focus windows on click, and tune wheel scrolling so terminal trackpads and mouse wheels feel natural across splits and overlays.
23. Add explicit `nvim-tree` mouse mappings so single click opens or expands a node, double click also opens it, and middle click opens a file in a new tab.
24. Route Bufferline mouse tab selection through `config.workspace.focus_buffer(bufnr)` so clicking a tab always lands in an editor window and never replaces the pinned tree pane.
25. Keep LazyGit mouse-aware by managing `lazygit/config.yml` in the repo and enabling `gui.mouseEvents: true` in the real app config path.
26. Exclude `checkhealth` buffers from autosave so plugin health checks do not create stray files in the repo.
27. Enable `autoread` and refresh real unmodified file buffers with `checktime` on focus and idle events so external edits from Codex or other tools are reflected in open editors.
28. Add terminal-safe VS Code mappings plus Neovide `Cmd` mappings for save, search, explorer toggle, undo/redo, and close.
29. Show leader-key hints through `which-key.nvim` with the `modern` preset.
30. Auto-save after idle, on focus loss, and on buffer leave.
31. Format on save with `conform.nvim` and fall back to LSP formatting when needed.
32. Enable LSP servers only when their executables exist and avoid noisy Mason failures.
33. Override markdown ftplugin behavior so Neovim uses regex highlighting there instead of the crashing Treesitter path.
34. Keep `snacks.quickfile` disabled because it triggers the markdown Treesitter crash before the markdown workaround can run.
35. Keep a Neovide config file in `neovide/config.toml` for early GUI font and box-drawing settings.
36. Verify the flow with a small smoke test plus a larger generated E2E suite that covers 131 higher-level user flows.

Outputs:
- A simpler VS Code-like Neovim workflow that is terminal friendly.
- Faster startup with fewer overlapping plugins.
- Predictable save, search, formatting, diagnostics, git, and tab behavior.
- Direct search entry points for files, workspace text, current-file text, commands, diagnostics, buffers, recent files, and workspace symbols.
- Extra Snacks entry points for command history, notification history, git status, git log, keymap search, grep-word, and opening the current git file in the browser.
- A centered search experience and a fixed-width left explorer that make the UI feel closer to a focused app shell instead of a split plugin layout.
- A high-contrast shell with transparent editor and tree backgrounds, fluorescent green borders, orange accents, slanted tabs, a bubble statusline, and bordered opaque overlay pickers.
- A matching Ghostty profile with subtle translucent background, crisper text rendering, green cursor and selection styling, and a black-and-green ANSI palette behind the editor shell.
- A stable close-buffer flow: tree width stays fixed, the editor never collapses into a tree-only screen, and the tabline only reflects real open files.
- A stable inactive-tab close flow: if the explorer is focused, closing a tab still targets the tab itself instead of hijacking the tree window.
- Better mouse behavior across the shell: clicks focus the intended pane, file-tree clicks open nodes cleanly, and tab clicks never replace the sidebar.
- LazyGit mouse support inside the floating terminal window.
- Better Snacks coverage: big files degrade gracefully, references can be jumped quickly, and git browser links are available from inside the editor.
- Open files refresh when they change on disk, as long as the buffer has no unsaved edits.
- Python imports that resolve against a project-local virtual environment when `.venv` exists.
- Node language servers that follow the project’s local `node_modules` context instead of only the global environment.
- Rust and Go language servers that anchor to the project module root automatically.

Key assumptions:
- `node` and `npm` are available for Node-backed LSP servers.
- External formatters can be installed locally and discovered on `PATH`.
- Terminal shortcuts are the priority, not GUI-only key combinations.
- Rust and Go projects follow standard module layout, so `Cargo.toml`, `rust-project.json`, `go.work`, or `go.mod` exist when the project needs language-server context.

Edge cases / gotchas:
- Auto-save skips unnamed, readonly, and special buffers.
- If a formatter is missing, save still succeeds and LSP fallback may handle formatting.
- Some VS Code shortcuts cannot exist exactly in terminal Neovim and use leader-based fallbacks.
- `Tab` completion now forces a simple show-or-accept path, so it is intentionally biased toward speed and predictability over advanced snippet-heavy behavior.
- Node workspace context only adds local `node_modules/.bin` and TypeScript SDK hints when those paths really exist, so plain JavaScript folders without installed dependencies still open cleanly.
- Neovide has its own startup font path, so GUI font issues may need `neovide/config.toml` and not just `guifont` in Lua.
- The current visual direction is intentionally high-contrast and editor-first: black backgrounds, fluorescent green structure, orange highlights, VS Code-style purple keywords, and stronger editor/sidebar separation.
- Ghostty title and tab context follow Ghostty shell integration, so the terminal chrome stays aligned with the current working directory and active shell session.
- If text starts to look soft or faded, Ghostty opacity and blur matter more than the Neovim theme; keep opacity high and blur low so transparency does not reduce legibility.
- Markdown deliberately skips Treesitter highlighting because Neovim 0.12 starts it in the built-in ftplugin and can crash during redraw.
- `Ctrl-b` is handled by the workspace controller and `nvim-tree`; Snacks explorer is intentionally disabled in this setup.
- Search discoverability depends on `which-key` and the search palette because terminal Neovim cannot mirror every GUI key combination exactly.
- The E2E suite disables `snacks` frecency writes during the run so the flow tests are not polluted by SQLite churn from hundreds of temporary files.
- `<leader>g` is now dedicated to LazyGit and related lightweight Git pickers, so there is no separate Diffview layer competing for the same prefix.
- Middle click behavior is only meaningful in terminals and GUIs that forward middle-mouse events correctly; the main left-click path is the required one.
- Notification history uses `Snacks.notifier.show_history()` instead of the picker wrapper because it is more stable when the history is empty.
- External reload only applies to clean buffers; modified buffers are intentionally left alone so local edits are not overwritten.
