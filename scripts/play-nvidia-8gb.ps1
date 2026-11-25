param(
    [Parameter(Mandatory = $true)]
    [string]$Exe,
    [int]$DropMips = 2
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$victory = Join-Path $repoRoot "target\release\victory.exe"

if (-not (Test-Path -LiteralPath $victory -PathType Leaf)) {
    $victory = Join-Path $repoRoot "victory.exe"
}

if (-not (Test-Path -LiteralPath $victory -PathType Leaf)) {
    Write-Error "victory.exe was not found. Extract the full Windows x64 build ZIP or run cargo build --release --bin victory from the repository."
    exit 1
}

Remove-Item Env:VICTORY_SKIP_PIPELINES, Env:VICTORY_BAKE_TEXTURES_MS, Env:VICTORY_CARD_FETCH_INFLIGHT, Env:VICTORY_LEVELS_ON_DEMAND, Env:VICTORY_REFRESH_ONCE, Env:VICTORY_AMBIENT -ErrorAction SilentlyContinue

$env:VICTORY_ASYNC_SUBMIT = "1"
$env:VICTORY_QUEUE2 = "1"
$env:VICTORY_INDIRECT_WINDOW = "1"
$env:VICTORY_TEXTURE_NO_WAIT = "1"
$env:VICTORY_COPY_PLAIN = "1"
$env:VICTORY_SKIP_WC_COMPARE = "1"
$env:VICTORY_WIDE_TEXTURES = "1"
$env:VICTORY_TEXTURE_DROP_MIPS = "$DropMips"

& $victory run --execute $Exe
