Feature: Shared Ghostty and btop terminal theme

Approach:
Create one custom `btop` theme that matches the existing Ghostty and Neovim
palette: black background, bright green structure, soft white text, orange
highlights, and purple secondary accents. Track both the theme and `btop.conf`
inside the repo, point `btop.conf` at that theme, and disable theme-owned
background fill so Ghostty translucency can still show through cleanly.

Why:
`btop` was still using its default theme, so it felt visually detached from the
rest of the shell. A small custom theme is simpler than trying to bend an
existing preset into the same palette.

Edge cases:
- If `btop` falls back to 256-color mode, the theme will still work but some
  gradients will look less smooth.
- If Ghostty translucency is disabled later, the theme still reads correctly
  because the palette uses explicit high-contrast foreground colors.
- `theme_background = false` keeps the terminal background in control, so
  readability depends partly on the Ghostty opacity and blur settings.

Decision:
Keep the `btop` layout and behavior mostly intact, but switch to a repo-managed
`rootsec1_hacker` theme, track the matching `btop.conf` in the repo, and
enable `vim_keys` so navigation behavior also feels closer to the rest of the
setup.
