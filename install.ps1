#Requires -Version 5.1
<#
.SYNOPSIS
    OpenRA 简体中文汉化补丁 - 安装 / 卸载脚本

.DESCRIPTION
    把 files\ 下的译文覆盖到目标 OpenRA 安装目录(playtest-20260222),
    并从本机 Windows 字体目录复制一个中文字体,使界面不再出现方块。
    所有被覆盖的文件都会备份到 <目标>\_zhcn-backup\<时间戳>\。

.PARAMETER Target
    OpenRA 安装目录。省略时自动从注册表与常见路径探测。

.PARAMETER FontPath
    指定中文字体文件(.ttf / .ttc)。省略时按 simhei.ttf -> Deng.ttf -> msyh.ttc -> simsun.ttc 顺序
    从 %WINDIR%\Fonts 查找。

.PARAMETER Uninstall
    从最近一次备份还原(卸载汉化)。

.PARAMETER DryRun
    只显示将要执行的操作,不写任何文件。

.PARAMETER Force
    引擎版本与补丁不匹配时也继续。

.PARAMETER Yes
    不交互,所有确认一律视为"是"。

.PARAMETER SkipFont
    跳过字体部署(仅当你的引擎已配置好中文字体时使用)。

.PARAMETER NoVerify
    跳过载荷文件哈希校验。

.EXAMPLE
    .\install.ps1
    .\install.ps1 -Target "D:\Games\OpenRA" -SkipFont
    .\install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [string]$Target,
    [string]$FontPath,
    [switch]$Uninstall,
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Yes,
    [switch]$SkipFont,
    [switch]$NoVerify,
    [switch]$Verify
)

$ErrorActionPreference = 'Stop'
$Root         = $PSScriptRoot
$PayloadDir   = Join-Path $Root 'files'
$ManifestPath = Join-Path $Root 'manifest.json'
$BackupName   = '_zhcn-backup'
$DefaultFontName = 'SimHei.ttf'

# ---------------------------------------------------------------- 输出helpers
function Say([string]$Text, [string]$Color = 'Gray') { Write-Host $Text -ForegroundColor $Color }
function Title([string]$Text) {
    Write-Host ''
    Write-Host ('=' * 62) -ForegroundColor DarkCyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ('=' * 62) -ForegroundColor DarkCyan
}
function Info($m)  { Say "  [信息] $m" 'Gray' }
function Ok($m)    { Say "  [完成] $m" 'Green' }
function Warn($m)  { Say "  [注意] $m" 'Yellow' }
function Fail($m)  { Say "  [错误] $m" 'Red' }

function Quote([string]$s) { return '"' + $s + '"' }

# ---------------------------------------------------------------- 探测与检查
function Get-Manifest {
    if (Test-Path $ManifestPath) {
        try { return (Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json) }
        catch { Warn "manifest.json 解析失败,跳过版本与哈希校验" }
    }
    return $null
}

function Test-OpenRADir([string]$Path) {
    if (-not $Path) { return $false }
    if (-not (Test-Path (Join-Path $Path 'mods\ra\mod.yaml'))) { return $false }
    foreach ($exe in @('RedAlert.exe', 'OpenRA.exe', 'TiberianDawn.exe', 'Dune2000.exe')) {
        if (Test-Path (Join-Path $Path $exe)) { return $true }
    }
    return $false
}

function Find-OpenRA {
    $regRoots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($r in $regRoots) {
        $items = Get-ItemProperty -Path $r -ErrorAction SilentlyContinue
        foreach ($it in $items) {
            if ($it.DisplayName -notlike 'OpenRA*') { continue }
            $cands = @()
            if ($it.InstallLocation) { $cands += $it.InstallLocation }
            if ($it.DisplayIcon) { $cands += (Split-Path -Parent ($it.DisplayIcon -replace '"', '')) }
            foreach ($c in $cands) {
                if (Test-OpenRADir $c) { return $c }
            }
        }
    }

    $bases = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, (Join-Path $env:LOCALAPPDATA 'Programs'))
    foreach ($b in $bases) {
        if (-not $b -or -not (Test-Path $b)) { continue }
        $dirs = Get-ChildItem -Path $b -Filter 'OpenRA*' -Directory -ErrorAction SilentlyContinue
        foreach ($d in $dirs) { if (Test-OpenRADir $d.FullName) { return $d.FullName } }
    }
    return $null
}

function Get-EngineVersion([string]$Dir) {
    $p = Join-Path $Dir 'mods\ra\mod.yaml'
    if (-not (Test-Path $p)) { return $null }
    $m = Select-String -Path $p -Pattern '^\s*Version:\s*(\S+)' -List
    if ($m) { return $m.Matches[0].Groups[1].Value }
    return $null
}

function Test-Writable([string]$Dir) {
    # 以"可写方式打开一个已存在的目标文件"来判断权限:不创建、不删除任何文件,
    # 避免杀软/审计钩子拦截临时文件操作而误判为不可写。
    $anchor = Join-Path $Dir 'mods\ra\mod.yaml'
    try {
        $fs = [IO.File]::Open($anchor, [IO.FileMode]::Open, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite)
        $fs.Dispose()
        return $true
    } catch {
        # 锚点文件不存在时退回临时文件探测
        $probe = Join-Path $Dir ('zhcn-probe-' + [Guid]::NewGuid().ToString('N') + '.tmp')
        try { [IO.File]::WriteAllText($probe, 'x') } catch { return $false }
        try { Remove-Item -LiteralPath $probe -Force -ErrorAction SilentlyContinue } catch { }
        return $true
    }
}

function Restart-Elevated {
    $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Quote $PSCommandPath), '-Target', (Quote $Target))
    if ($FontPath)  { $argv += @('-FontPath', (Quote $FontPath)) }
    if ($Uninstall) { $argv += '-Uninstall' }
    if ($Force)     { $argv += '-Force' }
    if ($Yes)       { $argv += '-Yes' }
    if ($SkipFont)  { $argv += '-SkipFont' }
    if ($NoVerify)  { $argv += '-NoVerify' }
    Warn '当前用户对该目录没有写权限,将弹出 UAC 提权窗口重新执行'
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argv
}

function Find-CjkFont([string]$Explicit) {
    if ($Explicit) {
        if (-not (Test-Path $Explicit)) { Fail "指定的字体不存在:$Explicit"; return $null }
        return (Get-Item $Explicit).FullName
    }
    $fontDir = Join-Path $env:WINDIR 'Fonts'
    foreach ($name in @('simhei.ttf', 'Deng.ttf', 'msyh.ttc', 'simsun.ttc')) {
        $p = Join-Path $fontDir $name
        if (Test-Path $p) { return $p }
    }
    return $null
}

# ---------------------------------------------------------------- 备份
function New-Backup([string]$Dir) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $path = Join-Path $Dir (Join-Path $BackupName $stamp)
    if (-not $DryRun) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    return $path
}

function Save-BackupEntry([string]$BackupPath, [string]$RelPath, [string]$State) {
    if ($DryRun) { return }
    $jsonPath = Join-Path $BackupPath 'backup.json'
    $data = $null
    if (Test-Path $jsonPath) {
        $data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $data = [pscustomobject]@{ created = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); target = $Target; entries = @() }
    }
    $list = @()
    foreach ($e in $data.entries) { $list += $e }
    $list += [pscustomobject]@{ path = $RelPath; state = $State }
    $obj = [pscustomobject]@{ created = $data.created; target = $data.target; entries = $list }
    [IO.File]::WriteAllText($jsonPath, ($obj | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding $false))
}

# ---------------------------------------------------------------- 安装
function Invoke-Install {
    $manifest = Get-Manifest
    $ver = if ($manifest) { $manifest.version } else { '?' }
    Title "OpenRA 简体中文汉化补丁  v$ver"

    if (-not $Target) {
        Info '未指定目标目录,正在自动探测 OpenRA 安装位置...'
        $Target = Find-OpenRA
    }
    if (-not $Target) {
        Fail '没能找到 OpenRA 安装目录。请用 -Target 手动指定,例如:'
        Say  '    install.bat -Target "C:\Program Files\OpenRA (playtest)"' 'DarkGray'
        exit 1
    }
    $Target = (Resolve-Path $Target).Path.TrimEnd('\')
    if (-not (Test-OpenRADir $Target)) {
        Fail "$Target 看起来不是 OpenRA 安装目录(缺少 mods\ra\mod.yaml 或主程序)"
        exit 1
    }
    Info "目标目录:$Target"

    $engine = Get-EngineVersion $Target
    Info "引擎版本:$engine"
    if ($manifest) {
        Info "补丁适配版本:$($manifest.engineVersion)"
        if ($engine -ne $manifest.engineVersion) {
            Warn '版本与补丁不完全一致。缺失的文案键不会回退英文,而是直接显示键名。'
            if (-not $Force -and -not $Yes) {
                $a = Read-Host '  仍要继续吗? (y/N)'
                if ($a -notmatch '^[Yy]') { Warn '已取消'; exit 1 }
            }
        }
    }

    if (-not (Test-Writable $Target)) {
        if ($DryRun) { Warn '目录不可写,但当前为 DryRun,继续' }
        else { Restart-Elevated; exit 0 }
    }

    # --- 载荷清单
    if (-not (Test-Path $PayloadDir)) { Fail "缺少载荷目录:$PayloadDir"; exit 1 }
    $relList = @()
    Get-ChildItem -Path $PayloadDir -Recurse -File | ForEach-Object {
        $relList += $_.FullName.Substring($PayloadDir.Length + 1)
    }
    $relList = $relList | Sort-Object
    Info "待覆盖文件:$($relList.Count) 个"

    # --- 哈希校验
    if (-not $NoVerify -and $manifest) {
        $bad = 0
        foreach ($f in $manifest.files) {
            $p = Join-Path $PayloadDir $f.path.Replace('/', '\')
            if (-not (Test-Path $p)) { Fail "载荷缺失:$($f.path)"; $bad++; continue }
            $h = (Get-FileHash -Path $p -Algorithm SHA256).Hash.ToLower()
            if ($h -ne $f.sha256.ToLower()) { Fail "校验失败:$($f.path)"; $bad++ }
        }
        if ($bad -eq 0) { Ok '载荷完整性校验通过 (SHA-256)' } else { Warn "有 $bad 个文件校验异常,继续安装" }
    }

    # --- 备份 + 覆盖
    $backupPath = New-Backup $Target
    if (-not $DryRun) { Info "备份目录:$backupPath" }
    $copied = 0; $added = 0
    foreach ($rel in $relList) {
        $src = Join-Path $PayloadDir $rel
        $dst = Join-Path $Target   $rel
        $exists = Test-Path $dst
        if ($DryRun) {
            $act = '新增'
            if ($exists) { $act = '覆盖' }
            Say ("    [预览] {0} {1}" -f $act, $rel) 'DarkGray'
            continue
        }
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        if ($exists) {
            $bak = Join-Path $backupPath $rel
            New-Item -ItemType Directory -Path (Split-Path -Parent $bak) -Force | Out-Null
            Copy-Item -LiteralPath $dst -Destination $bak -Force
            Save-BackupEntry $backupPath $rel 'replaced'
            $copied++
        } else {
            Save-BackupEntry $backupPath $rel 'added'
            $added++
        }
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }

    # --- 字体
    $fontState = '未处理'
    if ($SkipFont) {
        Warn '按要求跳过字体部署。若界面出现方块,请自行给 mods\*\mod.yaml 的 Fonts 段配置中文字体。'
    } else {
        $fontSrc = Find-CjkFont $FontPath
        if (-not $fontSrc) {
            Warn '本机 %WINDIR%\Fonts 下没找到可用的中文字体(simhei/Deng/msyh/simsun)'
            Warn '请用 -FontPath 指定一个 .ttf,例如思源黑体。否则界面中文会显示为方块。'
        } else {
            $fontName = Split-Path -Leaf $fontSrc
            $fontDst  = Join-Path $Target ('mods\common\' + $fontName)
            if ($DryRun) {
                Say ("    [预览] 部署字体 {0} -> mods\common\{1}" -f $fontSrc, $fontName) 'DarkGray'
            } else {
                if (Test-Path $fontDst) {
                    $bak = Join-Path $backupPath ('mods\common\' + $fontName)
                    New-Item -ItemType Directory -Path (Split-Path -Parent $bak) -Force | Out-Null
                    Copy-Item -LiteralPath $fontDst -Destination $bak -Force
                    Save-BackupEntry $backupPath ('mods/common/' + $fontName) 'replaced'
                } else {
                    Save-BackupEntry $backupPath ('mods/common/' + $fontName) 'added'
                }
                Copy-Item -LiteralPath $fontSrc -Destination $fontDst -Force
                $fontState = "$fontName (来自 $fontSrc)"
                Ok "已部署中文字体:mods\common\$fontName"

                # 注意:必须用大小写敏感比较(-cne)。PowerShell 的 -ne 默认忽略大小写,
                # 会让 simhei.ttf 与 SimHei.ttf 被当成同一个名字,从而漏掉引用同步。
                if ($fontName -cne $DefaultFontName) {
                    $n = 0
                    foreach ($modYaml in Get-ChildItem -Path (Join-Path $Target 'mods') -Filter 'mod.yaml' -Recurse -File) {
                        $text = [IO.File]::ReadAllText($modYaml.FullName, [Text.Encoding]::UTF8)
                        if ($text.Contains("common|$DefaultFontName")) {
                            $new = $text.Replace("common|$DefaultFontName", "common|$fontName")
                            [IO.File]::WriteAllText($modYaml.FullName, $new, (New-Object Text.UTF8Encoding $false))
                            $n++
                        }
                    }
                    if ($n -gt 0) { Info "已把 $n 个 mod.yaml 的字体引用同步为实际字体名 $fontName" }
                }
            }
        }
    }

    # --- 汇总
    Title '安装结果'
    if ($DryRun) {
        Warn '这是预演(DryRun),没有写任何文件。去掉 -DryRun 即为实际安装。'
    } else {
        Ok "覆盖 $copied 个文件,新增 $added 个文件"
        if ($fontState -ne '未处理') { Ok "字体:$fontState" }
        Info "备份与还原清单:$backupPath"
        Say ''
        Say '  现在启动游戏即可:' -ForegroundColor White
        foreach ($exe in @('RedAlert.exe', 'TiberianDawn.exe', 'Dune2000.exe', 'OpenRA.exe')) {
            if (Test-Path (Join-Path $Target $exe)) { Say ("    " + (Join-Path $Target $exe)) 'White' }
        }
        Say ''
        Say '  想还原英文:双击 uninstall.bat,或 install.bat -Uninstall' -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------- 卸载
function Invoke-Uninstall {
    Title 'OpenRA 简体中文汉化补丁 - 还原'
    if (-not $Target) { $Target = Find-OpenRA }
    if (-not $Target) { Fail '没能找到 OpenRA 安装目录,请用 -Target 指定'; exit 1 }
    $Target = (Resolve-Path $Target).Path.TrimEnd('\')

    $backupRoot = Join-Path $Target $BackupName
    if (-not (Test-Path $backupRoot)) {
        Fail "没有找到备份目录:$backupRoot"
        Info '说明:汉化补丁必须由 install 脚本安装过,才能用本脚本还原。'
        exit 1
    }
    $latest = Get-ChildItem -Path $backupRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1
    $jsonPath = Join-Path $latest.FullName 'backup.json'
    if (-not (Test-Path $jsonPath)) { Fail "备份清单缺失:$jsonPath"; exit 1 }
    $data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

    Info "使用备份:$($latest.FullName)"
    Info "备份时间:$($data.created)"
    if (-not (Test-Writable $Target)) {
        if ($DryRun) { Warn '目录不可写,但当前为 DryRun,继续' } else { Restart-Elevated; exit 0 }
    }

    $restored = 0; $removed = 0; $missing = 0; $stuck = 0
    foreach ($e in $data.entries) {
        $rel = $e.path.Replace('/', '\')
        $dst = Join-Path $Target $rel
        if ($e.state -eq 'added') {
            if (Test-Path $dst) {
                if ($DryRun) { Say "    [预览] 删除 $rel" 'DarkGray' }
                else {
                    # 删除失败(杀软锁定 / 只读属性 / 审计钩子)不应中断还原流程
                    try { Remove-Item -LiteralPath $dst -Force -ErrorAction Stop; $removed++ }
                    catch {
                        try { [IO.File]::Delete($dst); $removed++ }
                        catch { Warn "删除失败,请手动删除:$rel"; $stuck++ }
                    }
                }
            }
        } else {
            $bak = Join-Path $latest.FullName $rel
            if (Test-Path $bak) {
                if ($DryRun) { Say "    [预览] 还原 $rel" 'DarkGray' }
                else { Copy-Item -LiteralPath $bak -Destination $dst -Force; $restored++ }
            } else { Warn "备份文件缺失,跳过:$rel"; $missing++ }
        }
    }

    Title '还原结果'
    if ($DryRun) {
        Warn '这是预演(DryRun),没有写任何文件。'
    } else {
        Ok "还原 $restored 个文件,删除 $removed 个新增文件"
        if ($missing -gt 0) { Warn "$missing 个文件在备份里找不到,未处理" }
        if ($stuck -gt 0)   { Warn "$stuck 个新增文件被占用未能删除,请手动清理" }
        $done = $latest.FullName + '.已还原'
        Move-Item -LiteralPath $latest.FullName -Destination $done -Force
        Info "本次备份已标记为已还原:$done"
    }
}

# ---------------------------------------------------------------- 卸载校验
function Invoke-Verify {
    Title 'OpenRA 简体中文汉化 - 卸载校验'

    if (-not $Target) { $Target = Find-OpenRA }
    if (-not $Target) { Fail '没能找到 OpenRA 安装目录,请用 -Target 指定'; exit 1 }
    $Target = (Resolve-Path $Target).Path.TrimEnd('\')
    if (-not (Test-OpenRADir $Target)) {
        Fail "$Target 看起来不是 OpenRA 安装目录(缺少 mods\ra\mod.yaml 或主程序)"
        exit 1
    }
    Info "目标目录:$Target"

    $manifest = Get-Manifest
    if (-not $manifest) { Fail 'manifest.json 缺失,无法逐文件校验'; exit 1 }

    # 逐文件比对:安装目录里若仍有文件哈希与汉化版一致,说明汉化未卸干净
    $remain  = 0
    $clean   = 0
    $missing = 0
    $report  = @()
    foreach ($f in $manifest.files) {
        $rel = $f.path.Replace('/', '\')
        $dst = Join-Path $Target $rel
        if (-not (Test-Path $dst)) { $clean++; continue }   # 不存在:新增文件已删 / 还原后丢失,均不计入残留
        $h = (Get-FileHash -Path $dst -Algorithm SHA256).Hash.ToLower()
        if ($h -ceq $f.sha256.ToLower()) {
            $remain++
            $report += $rel
        } else {
            $clean++
        }
    }

    # 字体残留检查(原版 OpenRA 不带中文字体)
    $fontRemain = $false
    $fontName = 'SimHei.ttf'
    if ($manifest.font -and $manifest.font.deployTo) {
        $fontName = Split-Path -Leaf ($manifest.font.deployTo -replace '/', '\')
    }
    $fontPath = Join-Path $Target ('mods\common\' + $fontName)
    if (Test-Path $fontPath) { $fontRemain = $true }

    # 备份目录存在性提示
    $backupRoot = Join-Path $Target $BackupName
    $hasBackup  = Test-Path $backupRoot

    Title '校验结果'
    if ($remain -eq 0) {
        Ok "未检测到汉化文件残留 (已比对 $($manifest.files.Count) 个载荷,其中 $clean 个为英文/已删除状态)"
        if ($fontRemain) {
            Warn "但发现字体 $fontName 仍存在于 mods\common\,如已不需要可手动删除"
        } else {
            Ok "中文字体已不在 mods\common\ (若曾部署)"
        }
        Say ''
        Say '  结论:汉化已彻底卸载,游戏当前为英文原版。' 'Green'
        if ($hasBackup) { Info "备份目录尚在:$backupRoot (可删除)" }
        exit 0
    } else {
        Fail "检测到 $remain 个汉化文件仍在安装目录中,卸载未完成!"
        foreach ($r in $report) { Say ('    ' + $r) 'Red' }
        if ($fontRemain) { Warn "字体 $fontName 也仍残留于 mods\common\" }
        Say ''
        Say '  建议:重新运行 uninstall.bat(或 install.bat -Uninstall)完成还原。' 'Yellow'
        exit 1
    }
}

# ---------------------------------------------------------------- 入口
try {
    if ($Verify)        { Invoke-Verify }
    elseif ($Uninstall) { Invoke-Uninstall }
    else                { Invoke-Install }
} catch {
    Fail $_.Exception.Message
    Say $_.ScriptStackTrace 'DarkGray'
    exit 1
}
