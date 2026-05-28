param([string]$PluginRoot)

if ((Test-Path "Packages/com.pz.studio.generated") -and ((Split-Path -Leaf (Get-Location)) -ne "life-unity")) {
    # If .claude is missing or unversioned, set it up and ask the user to restart.
    # Setup runs here (not in SessionEnd) because SessionEnd is skipped when the user closes the terminal, kills the process, or crashes,
    # which would otherwise trap the user in a permanent "please restart" loop. Suppress update-docs output so stdout stays clean for the JSON message.
    if (-not (Test-Path ".claude") -or -not (Test-Path ".claude/version.txt")) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File "$PluginRoot/scripts/update-docs.ps1" $PluginRoot *> $null
        Write-Output '{"systemMessage": "\nPlease /exit and restart Claude Code to initialize the project''s .claude folder."}'
        exit 1
    }

    $pluginJson = Get-Content "$PluginRoot/.claude-plugin/plugin.json" -Raw | ConvertFrom-Json
    $pluginVersion = $pluginJson.version
    $projectVersion = (Get-Content ".claude/version.txt" -Raw).Trim()

    if ($projectVersion -ne $pluginVersion) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File "$PluginRoot/scripts/update-docs.ps1" $PluginRoot *> $null
        Write-Output '{"systemMessage": "\nPlease /exit and restart Claude Code to update the project''s .claude folder."}'
        exit 1
    }

    Write-Output "{`"systemMessage`": `"\nThis project is using plugin version $projectVersion.`"}"
    exit 0
}
