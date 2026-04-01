param([string]$PluginRoot)

$sceneFile = "Temp/Highrise/Serializer/active_scene.json"

# Silent no-op if scene isn't serialized
if (-not (Test-Path $sceneFile)) {
    exit 0
}

# Read the prompt from stdin JSON
$input = [Console]::In.ReadToEnd()
$inputObj = $input | ConvertFrom-Json
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

# Build JSON array of names for jq
$namesJson = ($names | ForEach-Object { "`"$_`"" }) -join ","
$namesJson = "[$namesJson]"

# Use jq to find matching objects
$jqQuery = @'
[path(.. | objects | select(.objectProperties?.name? as $n | $names | index($n) != null)) as $p |
 getpath($p) as $obj |
 {
   referenceId: $obj.referenceId,
   name: $obj.objectProperties.name,
   jqPath: ($p | map(if type == "number" then "[\(.)]\("")" else ".\(.)" end) | join(""))
 }]
'@

$results = $namesJson | jq --argjson names "$namesJson" $jqQuery $sceneFile 2>$null

if ([string]::IsNullOrEmpty($results) -or $results -eq "[]") {
    exit 0
}

Write-Output "The user referenced scene objects with @. Here are their locations in ${sceneFile}:"
Write-Output ""

$resultLines = $results | jq -r '.[] | "@\(.name): referenceId=""\(.referenceId)"", jqPath=""\(.jqPath)"""'
Write-Output $resultLines

exit 0
