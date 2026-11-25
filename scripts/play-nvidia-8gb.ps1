param(
    [Parameter(Mandatory = $true)]
    [string]$Exe,
    [int]$DropMips,
    [switch]$LowVram,
    [ValidateSet('series-x', 'series-s')]
    [string]$Console = 'series-x'
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

if ($LowVram) {
    $env:VICTORY_RELAY = "0"
    $env:VICTORY_LATE_WAIT = "0"
    $env:VICTORY_LEVELS_ON_DEMAND = "1"
}

$optimizations = if ($LowVram) { "0" } else { "1" }
$env:VICTORY_ASYNC_SUBMIT = $optimizations
$env:VICTORY_QUEUE2 = $optimizations
$env:VICTORY_INDIRECT_WINDOW = $optimizations
$env:VICTORY_TEXTURE_NO_WAIT = $optimizations
$env:VICTORY_COPY_PLAIN = $optimizations
$env:VICTORY_SKIP_WC_COMPARE = $optimizations
$env:VICTORY_WIDE_TEXTURES = $optimizations

if (-not $PSBoundParameters.ContainsKey('DropMips')) {
    $DropMips = if ($LowVram) { 0 } else { 2 }
}
$env:VICTORY_TEXTURE_DROP_MIPS = "$DropMips"

& $victory run --execute --console $Console $Exe
exit $LASTEXITCODE
