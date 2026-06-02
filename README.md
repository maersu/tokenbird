# tokenbird

A Waybar module that monitors spending and credits across token-consuming services.

Hover over the 󰊤 icon in Waybar to see a tooltip with all account details. Click to force-refresh.

## Supported providers

| Type | Source | Auth |
|---|---|---|
| `openrouter` | [OpenRouter](https://openrouter.ai) credits balance | API key (management or regular) |
| `cursor` | [Cursor](https://cursor.com) team on-demand spend | Admin API key or session cookie |
| `openai` | [OpenAI](https://platform.openai.com) costs for current billing cycle | Admin API key |

## Setup

### 1. Install

```sh
ln -sf "$(pwd)/tokenbird" ~/.local/bin/tokenbird
```

### 2. Configure

```sh
mkdir -p ~/.config/tokenbird
cp config.example.json ~/.config/tokenbird/config.json
# edit with your keys
```

### 3. Waybar integration

Add the module to `~/.config/waybar/config-custom.jsonc`:

```jsonc
{
  "custom/tokenbird": {
    "exec": "tokenbird",
    "return-type": "json",
    "format": "{}",
    "interval": 600,
    "signal": 11,
    "on-click": "pkill -SIGRTMIN+11 waybar",
    "tooltip": true
  }
}
```

Add `"custom/tokenbird"` to `modules-right` (or left/center) in `~/.config/waybar/config.jsonc`, then restart:

```sh
omarchy-restart-waybar
```

## Configuration

Config lives at `~/.config/tokenbird/config.json`. Each entry in the `accounts` array defines one line in the tooltip. Multiple accounts of the same type are supported.

### OpenRouter

```json
{
  "name": "openrouter (Team 1)",
  "type": "openrouter",
  "api_key": "sk-or-v1-..."
}
```

- **`api_key`** — Management key (from [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys)) gives credit balance via `/api/v1/credits`. A regular key also works (falls back to `/api/v1/key`).

### Cursor

**Admin API** (requires team API key):

```json
{
  "name": "cursor",
  "type": "cursor",
  "api_key": "key_...",
  "email": "you@company.com"
}
```

- **`api_key`** — Create at cursor.com/dashboard → Settings → Advanced → Admin API Keys.
- **`email`** — Optional. Shows your individual on-demand spend.
- Cursor on-demand usage is shown as dollars spent. If the session endpoint returns a hard limit, tokenbird warns once spend reaches it.
- **`included_usage`** / **`included_limit`** — Optional static values. The Admin API doesn't expose included usage, so set these manually if you want them displayed.

**Session cookie** (any plan, no API key needed):

```json
{
  "name": "cursor",
  "type": "cursor",
  "session_token": "eyJ...",
  "url": "https://www.cursor.com/api/usage"
}
```

- **`session_token`** — Value of the `WorkosCursorSessionToken` cookie from browser DevTools on cursor.com.
- **`url`** — Override if the default endpoint doesn't return the right data. Check your browser's Network tab on the Cursor billing page to find the correct URL.

### OpenAI

```json
{
  "name": "openai",
  "type": "openai",
  "admin_key": "sk-admin-...",
  "budget": 120,
  "billing_day": 1
}
```

- **`admin_key`** — Admin API key from [platform.openai.com/settings/organization/admin-keys](https://platform.openai.com/settings/organization/admin-keys). Regular `sk-` keys don't work.
- **`budget`** — Optional. Monthly budget limit shown as `Budget: $0.24 / $120`. Not fetched from the API.
- **`billing_day`** — Optional. Day of month the billing cycle resets (default: `1`).

## Behavior

- Data is cached for **5 minutes** at `~/.cache/tokenbird/data.json`.
- Waybar polls every **10 minutes** (configurable via `interval`).
- The icon turns red when credits are low or errors occur.
- Zero external dependencies — Python 3 stdlib only.

## Development

```sh
make help           # show all commands
make run-force      # test output, bypass cache
make log            # pretty-printed JSON output
make refresh        # clear cache + update waybar
make restart-waybar # full waybar restart
make config         # open config in editor
```

## Files

| Path | Purpose |
|---|---|
| `tokenbird` | Main script (symlinked to `~/.local/bin/`) |
| `config.example.json` | Example config with all provider types |
| `~/.config/tokenbird/config.json` | Your config (you create this) |
| `~/.cache/tokenbird/data.json` | Auto-managed response cache |
