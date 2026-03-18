param([string]$PluginRoot)

try {

# Check if creator-docs needs updating by comparing local HEAD to remote via GitHub API
$shouldUpdate = $false

if (-not (Test-Path "$PluginRoot/creator-docs")) {
    $shouldUpdate = $true
} else {
    $localSha = & git -C "$PluginRoot/creator-docs" rev-parse HEAD 2>$null
    if (-not $localSha) { $localSha = "" }

    $remoteSha = ""
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/pocketzworld/creator-docs/commits/main" -TimeoutSec 5 -ErrorAction Stop
        $remoteSha = $response.sha
    } catch {}

    if ($remoteSha -and ($localSha -ne $remoteSha)) {
        $shouldUpdate = $true
    }
}

# Clone or pull only if there are actual changes
if ($shouldUpdate) {
    if (-not (Test-Path "$PluginRoot/creator-docs")) {
        & git clone --depth 1 --filter=blob:none --sparse "https://github.com/pocketzworld/creator-docs.git" "$PluginRoot/creator-docs"
        & git -C "$PluginRoot/creator-docs" sparse-checkout set --no-cone '/*' '!*.png'
    } else {
        & git -C "$PluginRoot/creator-docs" sparse-checkout set --no-cone '/*' '!*.png' 2>$null
        & git -C "$PluginRoot/creator-docs" pull
    }
}

# Only copy to .claude if we're in a Highrise Studio project
if ((Test-Path "Packages/com.pz.studio.generated") -and ((Split-Path -Leaf (Get-Location)) -ne "life-unity")) {
    New-Item -ItemType Directory -Force -Path ".claude" | Out-Null

    # Version migration: delete old CLAUDE.md if version < 0.3.0
    if ((Test-Path ".claude/version.txt") -and ((Get-Content ".claude/version.txt" -Raw).Trim() -lt "0.3.0")) {
        Remove-Item ".claude/CLAUDE.md" -Force -ErrorAction SilentlyContinue
    }

    # Create CLAUDE.md if it doesn't exist
    if (-not (Test-Path ".claude/CLAUDE.md")) {
        "" | Set-Content ".claude/CLAUDE.md"
    }

    # Ensure the instructions line exists in CLAUDE.md even if the file already existed
    if (-not (Select-String -Path ".claude/CLAUDE.md" -Pattern "Read the important instructions in @ABOUT_HIGHRISE_STUDIO.md before you start." -SimpleMatch -Quiet)) {
        $content = @(Get-Content ".claude/CLAUDE.md")
        $instructionLine = "**Read the important instructions in @ABOUT_HIGHRISE_STUDIO.md before you start.**"
        $newContent = @($content[0], $instructionLine) + $content[1..($content.Length - 1)]
        $newContent | Set-Content ".claude/CLAUDE.md"
    }

    # Copy claude-docs to .claude (Get-ChildItem is more reliable than Copy-Item with wildcards)
    Get-ChildItem "$PluginRoot/scripts/claude-docs" -Force | ForEach-Object {
        Copy-Item $_.FullName (Join-Path ".claude" $_.Name) -Recurse -Force
    }

    # Write plugin version
    $pluginJson = Get-Content "$PluginRoot/.claude-plugin/plugin.json" -Raw | ConvertFrom-Json
    $pluginJson.version | Set-Content ".claude/version.txt" -NoNewline

    # Copy creator-docs only if changed
    $currentHash = & git -C "$PluginRoot/creator-docs" rev-parse HEAD 2>$null
    if (-not $currentHash) { $currentHash = "" }
    $deployedHash = & git -C ".claude/creator-docs" rev-parse HEAD 2>$null
    if (-not $deployedHash) { $deployedHash = "" }

    if ($currentHash -ne $deployedHash) {
        Remove-Item ".claude/creator-docs" -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item "$PluginRoot/creator-docs" ".claude/creator-docs" -Recurse -Force
    }

    # Copy skills, deleting only rosie-* skills first
    Get-ChildItem ".claude/skills" -Directory -Filter "rosie-*" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
    New-Item -ItemType Directory -Force -Path ".claude/skills" | Out-Null
    Get-ChildItem "$PluginRoot/scripts/skills" -Force | ForEach-Object {
        Copy-Item $_.FullName (Join-Path ".claude/skills" $_.Name) -Recurse -Force
    }

    # Update .gitignore to exclude .claude/* except CLAUDE.md
    if (Test-Path ".gitignore") {
        if (-not (Select-String -Path ".gitignore" -Pattern '^\.claude/\*$' -Quiet)) {
            Add-Content ".gitignore" @("", "# Claude Code plugin files (auto-generated)", ".claude/*", "!.claude/CLAUDE.md")
        }
    }
}

} catch {
    Write-Output "{`"systemMessage`": `"\n[Rosie] update-docs hook failed: $($_.Exception.Message)`"}"
    exit 1
}
