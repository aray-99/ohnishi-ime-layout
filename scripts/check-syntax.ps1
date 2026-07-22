<#
.SYNOPSIS
    Static syntax check for the AutoHotkey v2 scripts in this repository.

.DESCRIPTION
    Loads each script with AutoHotkey's /ErrorStdOut so load-time (parse) errors
    are written to stderr instead of a blocking dialog. Library files are loaded
    directly (they exit on their own); resident scripts are loaded with
    --selfcheck so they validate and then exit without installing a session.

    Exits 0 if all scripts pass, 1 otherwise. Injects no keys and logs nothing.

.PARAMETER AutoHotkey
    Full path to AutoHotkey64.exe. Auto-detected if omitted.

.EXAMPLE
    pwsh -File scripts/check-syntax.ps1
#>
[CmdletBinding()]
param(
    [string]$AutoHotkey
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot

if (-not $AutoHotkey) {
    $candidates = @(
        "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
        "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"
    )
    $AutoHotkey = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $AutoHotkey) {
        $cmd = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
        if ($cmd) { $AutoHotkey = $cmd.Source }
    }
}
if (-not $AutoHotkey -or -not (Test-Path $AutoHotkey)) {
    Write-Error "AutoHotkey v2 executable not found. Pass -AutoHotkey <path>."
    exit 1
}

# Each script + arguments. OhnishiLayout.ahk --selfcheck also validates the
# files it #Includes (src/context.ahk, src/ohnishi-map.ahk), which are not
# standalone; spike/ime-spike.ahk --selfcheck validates the spike + src/ime.ahk.
$targets = @(
    @{ File = "src\ime.ahk";          Args = @() },
    @{ File = "OhnishiLayout.ahk";    Args = @("--selfcheck") },
    @{ File = "spike\ime-spike.ahk";  Args = @("--selfcheck") }
)

$errFile = [System.IO.Path]::GetTempFileName()
$failed = 0
Write-Host "AutoHotkey: $AutoHotkey"
foreach ($t in $targets) {
    $path = Join-Path $repo $t.File
    if (-not (Test-Path $path)) {
        Write-Host ("[SKIP] {0} (not found)" -f $t.File)
        continue
    }
    $argList = @("/ErrorStdOut", $path) + $t.Args
    $p = Start-Process -FilePath $AutoHotkey -ArgumentList $argList -Wait -PassThru -NoNewWindow -RedirectStandardError $errFile
    $err = (Get-Content $errFile -Raw -ErrorAction SilentlyContinue)
    if ($p.ExitCode -eq 0) {
        Write-Host ("[PASS] {0} {1}" -f $t.File, ($t.Args -join " "))
    } else {
        $failed++
        Write-Host ("[FAIL] {0} {1} (exit {2})" -f $t.File, ($t.Args -join " "), $p.ExitCode)
        if ($err) { Write-Host ("       {0}" -f $err.Trim()) }
    }
}
Remove-Item $errFile -ErrorAction SilentlyContinue

if ($failed -gt 0) {
    Write-Host "`n$failed script(s) failed."
    exit 1
}
Write-Host "`nAll scripts passed."
exit 0
