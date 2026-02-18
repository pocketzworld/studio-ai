param([string]$PluginRoot)

if (Test-Path "Packages/com.pz.studio.generated") {
    if (-not (Test-Path ".claude") -or -not (Test-Path ".claude/version.txt")) {
        Write-Output '{"systemMessage": "\nPlease /exit and restart Claude Code to initialize the project''s .claude folder."}'
        exit 1
    }

    $pluginJson = Get-Content "$PluginRoot/.claude-plugin/plugin.json" -Raw | ConvertFrom-Json
    $pluginVersion = $pluginJson.version
    $projectVersion = (Get-Content ".claude/version.txt" -Raw).Trim()

    if ($projectVersion -ne $pluginVersion) {
        Write-Output '{"systemMessage": "\nPlease /exit and restart Claude Code to update the project''s .claude folder."}'
        exit 1
    }

    Write-Output "{`"systemMessage`": `"\nThis project is using plugin version $projectVersion.`"}"
    exit 0
}
