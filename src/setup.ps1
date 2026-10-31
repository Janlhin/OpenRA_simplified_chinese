#Requires -Version 5.1
<#
.SYNOPSIS
    OpenRA 简体中文汉化补丁 —— 唯一入口

.DESCRIPTION
    不带参数运行 = 打开中文菜单（安装 / 还原 / 校验 / 预演）。
    带参数运行   = 原样转给 install.ps1，等价于：

        .\setup.ps1 -Target "C:\Program Files\OpenRA (playtest)"
        .\setup.ps1 -Uninstall
        .\setup.ps1 -DryRun

    怎么启动：Windows 对 .ps1 的默认动作是"用记事本打开"，所以要
    右键 → **使用 PowerShell 运行**；或者在 PowerShell 里执行本文件。

.NOTES
    本文件只做转发，**不含任何业务逻辑**；逻辑全在 install.ps1。
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
# 发布包：setup.ps1 在根，安装器在 bin\；仓库：两者都在 src\
$installer = Join-Path $here 'bin\install.ps1'
if (-not (Test-Path -LiteralPath $installer)) { $installer = Join-Path $here 'install.ps1' }
if (-not (Test-Path -LiteralPath $installer)) {
    Write-Host ''
    Write-Host '  [错误] 找不到 install.ps1，请确认压缩包完整解压（bin\ 目录不能少）。' -ForegroundColor Red
    Write-Host ''
    exit 1
}

# 用当前正在跑的解释器再起子进程，避免 PS5 / PS7 混用
$exe = (Get-Process -Id $PID).Path
if (-not $exe) { $exe = 'powershell.exe' }

$argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer)
if ($Rest -and $Rest.Count -gt 0) { $argv += $Rest } else { $argv += '-Menu' }

try { $Host.UI.RawUI.WindowTitle = 'OpenRA 简体中文汉化补丁' } catch { }

& $exe @argv
$rc = $LASTEXITCODE
if ($null -eq $rc) { $rc = 0 }

if ($rc -ne 0) {
    Write-Host ''
    Write-Host "  [!] 安装器退出码 $rc。" -ForegroundColor Yellow
    Write-Host '      若提示"禁止运行脚本"，说明这台机器的组策略封了 PowerShell；' -ForegroundColor Yellow
    Write-Host '      请改用 README 里的手动安装步骤。' -ForegroundColor Yellow
    Write-Host ''
    try { Read-Host '按回车关闭' | Out-Null } catch { }
}
exit $rc
