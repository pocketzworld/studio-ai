---
description: Search the Highrise Studio Asset Catalog to find and acquire assets. The Asset Catalog is a database where users can upload assets (scripts, models, textures, etc.) for others to use in their projects. Assets can either be free or purchased with Highrise Gold, an in-game premium currency. This skill will not actually execute purchases; it can only search the catalog and download free or already-purchased assets.
context: fork
model: sonnet
---

# Search the Asset Catalog

Search the Highrise Studio Asset Catalog to find assets relevant to the user's request, install any that are free or already purchased, and report results.

## Prerequisites

- Unity must be open with a Highrise Studio project
- The user must be logged in to Highrise Studio in the Unity editor
- Python 3 must be available on the system

## Tools

This skill uses three components:

1. **`.catalog` trigger** — Exports auth credentials from the Unity editor to `Temp/Highrise/Serializer/catalog_result.json`
2. **`catalog.py`** — A CLI tool for searching the Asset Catalog API
3. **`.install` trigger** — Downloads and installs an asset into the Unity project, writing results to `Temp/Highrise/Serializer/install_result.json`

The trigger files and result files are in the Unity project root (the parent of `Assets/`). The `catalog.py` script is located at `ROSIE_SCRIPTS/catalog.py` where `ROSIE_SCRIPTS` is the directory containing this skill's parent `scripts/` folder — use the path relative to this SKILL.md file: `../../catalog.py`.

## Instructions

Follow these steps in order:

### 1. Authenticate with the catalog

Create an empty `.catalog` file in the Unity project root to trigger credential export:

```bash
touch <project_root>/.catalog
```

Then poll for the result file (it takes a moment for Unity to process the trigger):

```bash
# Poll every 2 seconds, up to 30 seconds
for i in $(seq 1 15); do
  if [ -f "<project_root>/Temp/Highrise/Serializer/catalog_result.json" ]; then
    cat "<project_root>/Temp/Highrise/Serializer/catalog_result.json"
    break
  fi
  sleep 2
done
```

Read the result. If `success` is `false`, tell the user they need to log in to Highrise Studio in Unity and stop.

### 2. Search the catalog

Use `catalog.py` with the auth file to search for assets matching the user's request. The catalog CLI supports these subcommands:

| Command | Description |
|---------|-------------|
| `list` | List published assets with filters |
| `get <id>` | Get full details for a single asset |
| `purchased` | List assets the user has already purchased |
| `liked` | List assets the user has liked |
| `my-assets` | List the user's own uploaded assets |

The `list` command supports these filters:
- `--search <query>` — Text search (min 3 characters)
- `--category <cat>` — Filter by category: `structure`, `landscape`, `furniture`, `light`, `vehicle`, `clothing`, `creatures`, `dev_modules`, `materials`, `templates`, `vfx`, `animations`, `gui`, `props`
- `--free` — Only show free assets
- `--has-scripts` — Only assets that include scripts
- `--bundle true/false` — Filter bundles
- `--page <n>` — Pagination (default: 0)

Example:

```bash
python3 ROSIE_SCRIPTS/catalog.py --auth-file <project_root>/Temp/Highrise/Serializer/catalog_result.json list --search "tree" --category landscape
```

**Response format:**

The `list` command returns a JSON object with pagination and an `elements` array. Each element in `list` results contains a subset of fields (id, name, category, price, etc.). Use `get <id>` to retrieve full details for a specific asset.

The `get` command returns a JSON object with an `asset` field containing:
- `_id` — Unique asset ID
- `name` — Asset name
- `description` — Full text description of the asset
- `category` — Asset category (e.g. "furniture", "landscape")
- `status` — Publication status (e.g. "published")
- `price` — Price in Highrise Gold (null or 0 = free)
- `has_scripts` — Whether the asset includes Lua scripts
- `is_bundle` — Whether this is a bundle of multiple assets
- `icon_url` — Thumbnail image URL (no auth required to fetch)
- `image_urls` — Array of preview image URLs (no auth required to fetch)
- `images.thumbnail_2d_url`, `images.image_2d_url` — Additional image URLs
- `owner.id`, `owner.username` — Who created the asset
- `user_info.liked`, `user_info.purchased`, `user_info.viewed`, `user_info.downloaded` — Current user's relationship to this asset
- `created_at` — Creation timestamp
- `main_asset_guid` — Unity GUID of the main asset

**Search strategy:**
- Start with a broad search related to the user's request
- Try multiple search terms and categories if the first search doesn't yield good results
- Check `purchased` to see what the user already owns — these can be installed for free
- Use `get <id>` to inspect promising assets before installing
- **Review preview images before deciding whether an asset is useful.** The `icon_url` and `image_urls` fields are publicly accessible URLs — fetch and view them to verify the asset visually matches what the user needs. Names and descriptions alone can be misleading.

### 3. Install assets

For each asset you want to install, write a JSON trigger file:

```bash
echo '{"assetId": "<asset_id>"}' > <project_root>/.install
```

Then poll for the result:

```bash
for i in $(seq 1 30); do
  if [ -f "<project_root>/Temp/Highrise/Serializer/install_result.json" ]; then
    cat "<project_root>/Temp/Highrise/Serializer/install_result.json"
    break
  fi
  sleep 2
done
```

Read the result. Key fields:
- `success: true` — Asset was installed; `installed_path` shows where
- `already_installed: true` — Asset was already in the project
- `success: false` with an error about "requires purchase" — Asset is paid and not owned

**Important:** Only install one asset at a time. Wait for each install to complete before starting the next. Delete the result file before each new install:

```bash
rm -f <project_root>/Temp/Highrise/Serializer/install_result.json
```

### 4. Report results

When done, provide the user with a clear summary:

**Installed assets:**
For each asset that was successfully installed, list:
- Asset name and what it contains
- Why it's relevant to the user's request
- Where it was installed (`installed_path` from the result)

**Paid assets that may be useful (not installed):**
For any assets that looked relevant but required purchase, list:
- Asset name and description
- Price in Highrise Gold
- Why it could be useful

This gives the user actionable information about what was added and what else is available if they choose to purchase.