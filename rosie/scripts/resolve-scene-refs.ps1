param([string]$PluginRoot)

$sceneFile = "Temp/Highrise/Serializer/active_scene.json"

# Silent no-op if scene isn't serialized
if (-not (Test-Path $sceneFile)) {
    exit 0
}

# Read the prompt from stdin JSON
$rawInput = [Console]::In.ReadToEnd()
$inputObj = $rawInput | ConvertFrom-Json
$prompt = $inputObj.prompt

if ([string]::IsNullOrEmpty($prompt)) {
    exit 0
}

# Extract @mentions: quoted @"Name" and unquoted @Word
$names = @()

# Quoted form: @"Some Name"
$quotedMatches = [regex]::Matches($prompt, '@"([^"]+)"')
foreach ($m in $quotedMatches) {
    $names += $m.Groups[1].Value
}

# Unquoted form: @Word (preceded by whitespace or start, not file paths)
$unquotedMatches = [regex]::Matches($prompt, '(?:^|\s)@([A-Za-z_][A-Za-z0-9_]*)')
foreach ($m in $unquotedMatches) {
    $names += $m.Groups[1].Value
}

if ($names.Count -eq 0) {
    exit 0
}

# Write names as individual JSON strings to a temp file (one per line).
# jq --slurpfile reads them into an array, avoiding PowerShell's broken
# native command argument passing for embedded quotes/spaces.
$namesTmpFile = [System.IO.Path]::GetTempFileName()
$namesJsonLines = ($names | ForEach-Object { ConvertTo-Json $_ }) -join "`n"
Set-Content -Path $namesTmpFile -Value $namesJsonLines -NoNewline -Encoding UTF8

# Resolve script directory for jq filter files
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$queryFilter = Join-Path $scriptDir "resolve-scene-refs-query.jq"
$formatFilter = Join-Path $scriptDir "resolve-scene-refs-format.jq"

# Use jq to find matching objects
$results = jq --slurpfile names $namesTmpFile -f $queryFilter $sceneFile 2>$null
Remove-Item -Path $namesTmpFile -ErrorAction SilentlyContinue

if ([string]::IsNullOrEmpty($results) -or $results -eq "[]") {
    exit 0
}

Write-Output "The user referenced scene objects with @. Here are their locations in $sceneFile`:"
Write-Output ""

$resultLines = $results | jq -r -f $formatFilter
Write-Output $resultLines

exit 0
