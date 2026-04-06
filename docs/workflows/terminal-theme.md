Inputs:
- `/Users/rootsec1/.dotfiles/ghostty/config`
- `/Users/rootsec1/.dotfiles/btop/btop.conf`
- `/Users/rootsec1/.dotfiles/btop/themes/rootsec1_hacker.theme`

Processing steps:
1. Apply the shared shell palette in Ghostty: black background, bright green
   cursor and borders, pale-green text, orange highlight accents, and purple
   secondary accents.
2. Keep Ghostty mostly opaque with low blur so the terminal stays readable.
3. Point the repo-managed `btop.conf` at the custom `rootsec1_hacker` theme.
4. Use `theme_background = false` in `btop` so Ghostty remains the surface
   behind the dashboard instead of fighting with a second background color.
5. Use the same accent family in `btop` graphs and box borders so it feels like
   the same shell as Neovim and Ghostty.
6. Enable `vim_keys` in `btop` so keyboard movement stays consistent with the
   rest of the terminal workflow.

Outputs:
- Ghostty, Neovim, and `btop` now share one black-and-green terminal look.
- `btop` graphs, borders, selection, and text match the shell palette instead
  of falling back to the default theme.

Key assumptions:
- The live `~/.config/btop` directory can be symlinked to the repo `btop/`
  directory.
- Ghostty remains the main terminal for this setup.

Edge cases / gotchas:
- `btop` is interactive, so the fastest validation path is launching it briefly
  and quitting, not a fully headless parse command.
- If the user switches terminal emulators, `theme_background = false` means the
  terminal’s own background still influences how `btop` feels.
