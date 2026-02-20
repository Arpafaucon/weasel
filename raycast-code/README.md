# Raycast VSCode Switcher

Fast VSCode window switcher with partial matching for Raycast.

## Quick Start

```bash
cargo build --release
```

Add `raycast-wrapper.sh` to Raycast, then use:
- `w` → weasel
- `ag` → agent
- `b` → bench

## Projects

Hardcoded in `src/main.rs`

## Environment Variables

- `RUST_LOG=debug` - Show detailed execution steps (info, debug, trace)
- `DRY_RUN=1` - Print commands without executing

## How It Works

1. Partial match project name
2. Check if VSCode window is open (via `pgrep -fl Code`)
3. If open: focus window (`code /path`)
4. If not: spawn via login shell (`zsh -l -c 'code /path'`)
