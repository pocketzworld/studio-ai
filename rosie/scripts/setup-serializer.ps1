param([string]$PluginRoot)

$serializerSource = "$PluginRoot/scripts/Serializer"
$serializerDest = "Assets/Editor/Serializer"

if ((Test-Path $serializerSource) -and (Test-Path "Assets") -and (Test-Path "Packages/com.pz.studio.generated") -and ((Split-Path -Leaf (Get-Location)) -ne "life-unity")) {
    # Remove symlink/junction if present
    $item = Get-Item $serializerDest -ErrorAction SilentlyContinue
    if ($item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        $item.Delete()
    }

    New-Item -ItemType Directory -Force -Path $serializerDest | Out-Null

    # Clear all files except .meta
    Get-ChildItem $serializerDest -File | Where-Object { $_.Extension -ne ".meta" } | Remove-Item -Force

    # Copy .cs files from source to destination
    Get-ChildItem $serializerSource -Filter "*.cs" | Copy-Item -Destination $serializerDest -Force

    # Add to .gitignore if not already present
    $gitignoreEntry = "Assets/Editor/Serializer/"
    if (Test-Path ".gitignore") {
        if (-not (Select-String -Path ".gitignore" -Pattern ([regex]::Escape($gitignoreEntry)) -SimpleMatch -Quiet)) {
            Add-Content ".gitignore" $gitignoreEntry
        }
    }
}

exit 0
