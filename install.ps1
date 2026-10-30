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
    指定中文字体文件(.ttf / .ttc),优先级最高。省略时优先用包内 fonts\NotoSansSC-*.ttf,
    包内没有才回退到 %WINDIR%\Fonts 的 simhei.ttf -> Deng.ttf -> msyh.ttc -> simsun.ttc。

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

.PARAMETER Verify
    校验「汉化是否已卸载干净」:逐文件比对载荷哈希,列出仍残留的文件。

.PARAMETER Backup
    指定用哪一份备份还原(省略则自动挑选)。值可以是备份目录的路径或名字,例如
    -Backup "20261030-180424"。

.PARAMETER Menu
    显示中文交互菜单(安装 / 还原 / 校验 / 预演),由 setup.cmd 双击进入。
    菜单里的每一项都通过子进程重新调用本脚本,互不影响。

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
    [switch]$Verify,
    [string]$Backup,
    [switch]$Menu
)

$ErrorActionPreference = 'Stop'

# 发布包里脚本放在 bin\ 下,载荷与说明在上一层;仓库里脚本就在根目录。
# 因此不能只看 $PSScriptRoot,要向上找一级含有 files\ 的目录。
$ScriptDir    = $PSScriptRoot
$Root         = $ScriptDir
if (-not (Test-Path (Join-Path $Root 'files'))) {
    $parent = Split-Path -Parent $ScriptDir
    if ($parent -and (Test-Path (Join-Path $parent 'files'))) { $Root = $parent }
}
$PayloadDir   = Join-Path $Root 'files'
$ManifestPath = Join-Path $ScriptDir 'manifest.json'
if (-not (Test-Path $ManifestPath)) { $ManifestPath = Join-Path $Root 'manifest.json' }
$BackupName   = '_zhcn-backup'
# 载荷 mod.yaml 里写的字体名;用系统字体兜底时要逐一把它们换成实际文件名
$DefaultFontNames = @('NotoSansSC-Regular.ttf', 'NotoSansSC-Bold.ttf')

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
    if ($Backup)    { $argv += @('-Backup', (Quote $Backup)) }
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

# ---------------------------------------------------------------- 备份挑选
function Test-PostPatchBackup([string]$Dir, $Data) {
    # 在已打过补丁的目录上再装一次，备份里存下来的就是**译文**——拿它还原等于什么都没做。
    # 判据：抽样比对备份内容与载荷，若过半完全相同，说明这份"备份"是覆盖后的产物。
    # 只要有任何一个文件"装之前就已经是译文"(state=same),这棵树当时必然已经打过补丁,
    # 这份备份里就不可能存着完整的英文原件 —— 拿它还原只会原地打转。
    $sameCount = @($Data.entries | Where-Object { $_.state -eq 'same' }).Count
    if ($sameCount -gt 0) { return $true }

    $cand = @($Data.entries | Where-Object { $_.state -eq 'replaced' })
    if ($cand.Count -eq 0) {
        # 没有任何"被覆盖前"的文件:要么全是新增(首次安装,有效),要么全是 same
        # (重复安装,一份纯译文,拿来还原等于没还原)。
        $hasAdded = @($Data.entries | Where-Object { $_.state -eq 'added' }).Count -gt 0
        return (-not $hasAdded)
    }
    $checked = 0
    $same = 0
    foreach ($e in ($cand | Select-Object -First 12)) {
        $rel = $e.path.Replace('/', '\')
        $bak = Join-Path $Dir $rel
        $src = Join-Path $PayloadDir $rel
        if (-not (Test-Path -LiteralPath $bak)) { continue }
        if (-not (Test-Path -LiteralPath $src)) { continue }
        $checked++
        try {
            $hb = (Get-FileHash -LiteralPath $bak -Algorithm SHA256).Hash
            $hs = (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash
            if ($hb -eq $hs) { $same++ }
        } catch { }
    }
    if ($checked -eq 0) { return $false }
    return ($same * 2 -ge $checked)
}

function Select-Backup([string]$Root) {
    # 从新到旧挑第一份"真正的安装前快照"：
    #   1) 跳过已还原过的（名字带 .已还原），否则会对同一份反复还原；
    #   2) 跳过重复安装产生的（内容其实是译文）。
    $dirs = @(Get-ChildItem -Path $Root -Directory | Sort-Object Name -Descending)
    $usable = @($dirs | Where-Object { $_.Name -notlike '*已还原*' })
    $skipped = @()
    foreach ($d in $usable) {
        $json = Join-Path $d.FullName 'backup.json'
        if (-not (Test-Path $json)) { continue }
        $data = Get-Content $json -Raw -Encoding UTF8 | ConvertFrom-Json
        if (Test-PostPatchBackup $d.FullName $data) { $skipped += $d.Name; continue }
        return [pscustomobject]@{ Path = $d.FullName; Skipped = $skipped }
    }
    # 全都不可用:宁可明确失败,也不要挑一份"看起来最新"的译文快照假装还原成功
    return [pscustomobject]@{ Path = $null; Skipped = $skipped }
}

function Remove-OrphanFonts($Data, [string]$Dir) {
    # 备份早于当前字体方案时，mods\common\ 下会留下补丁自己塞进去的字体文件。
    # 只删我们确定的几个名字，不动用户自己的字体。
    $known = @('NotoSansSC-Regular.ttf', 'NotoSansSC-Bold.ttf', 'simhei.ttf', 'SimHei.ttf')
    $referenced = @{}
    foreach ($e in $Data.entries) { $referenced[($e.path.Replace('/', '\')).ToLower()] = $true }
    $n = 0
    foreach ($name in $known) {
        $rel = 'mods\common\' + $name
        if ($referenced.ContainsKey($rel.ToLower())) { continue }
        $p = Join-Path $Dir $rel
        if (-not (Test-Path -LiteralPath $p)) { continue }
        try {
            Remove-Item -LiteralPath $p -Force -ErrorAction Stop
            $n++
            Info "顺带删除补丁遗留字体:mods\common\$name"
        } catch {
            try { [IO.File]::Delete($p); $n++ } catch { }
        }
    }
    return $n
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
        Say  '    setup.cmd -Target "C:\Program Files\OpenRA (playtest)"' 'DarkGray'
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
    $copied = 0; $added = 0; $same = 0
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
            # 已经是这份译文(重复安装)时,不要把译文当成"原件"存进备份 —— 那会让备份失去意义,
            # 卸载时还原出一份中文,看起来就是"卸载没效果"。
            $already = $false
            try {
                $already = ((Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash -eq
                            (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash)
            } catch { }
            if ($already) {
                Save-BackupEntry $backupPath $rel 'same'
                $same++
            } else {
                $bak = Join-Path $backupPath $rel
                New-Item -ItemType Directory -Path (Split-Path -Parent $bak) -Force | Out-Null
                Copy-Item -LiteralPath $dst -Destination $bak -Force
                Save-BackupEntry $backupPath $rel 'replaced'
                $copied++
            }
        } else {
            Save-BackupEntry $backupPath $rel 'added'
            $added++
        }
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
    if ($same -gt 0) {
        Warn "有 $same 个文件已经是本补丁的译文(重复安装)。它们没有英文原件可备份,还原时会自动跳过。"
    }

    # --- 字体（优先级:-FontPath > 包内 fonts\ > 系统字体;都没有就中止）
    $fontState = '未处理'
    if ($SkipFont) {
        Warn '按要求跳过字体部署。若界面出现方块,请自行给 mods\*\mod.yaml 的 Fonts 段配置中文字体。'
    } else {
        $bundled = @()
        if ($manifest -and $manifest.font -and $manifest.font.bundled) { $bundled = @($manifest.font.bundled) }

        $custom = $null
        if ($FontPath) {
            $custom = Find-CjkFont $FontPath
            if (-not $custom) { Fail "指定的字体不存在:$FontPath"; exit 1 }
        }

        $useBundled = (-not $custom) -and ($bundled.Count -gt 0)
        if ($useBundled) {
            foreach ($b in $bundled) {
                if (-not (Test-Path (Join-Path $Root $b.path))) { $useBundled = $false }
            }
        }

        if ($useBundled) {
            # 译文里的 mod.yaml 已经指向这些文件名,铺过去即可,无需改写引用
            foreach ($b in $bundled) {
                $name = Split-Path -Leaf ($b.deployTo -replace '/', '\')
                if ($DryRun) {
                    Say ("    [预览] 部署包内字体 {0} -> mods\common\{1}" -f $b.path, $name) 'DarkGray'
                    continue
                }
                $src = Join-Path $Root $b.path
                $dst = Join-Path $Target ('mods\common\' + $name)
                New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
                if (Test-Path $dst) {
                    $bak = Join-Path $backupPath ('mods\common\' + $name)
                    New-Item -ItemType Directory -Path (Split-Path -Parent $bak) -Force | Out-Null
                    Copy-Item -LiteralPath $dst -Destination $bak -Force
                    Save-BackupEntry $backupPath ('mods/common/' + $name) 'replaced'
                } else {
                    Save-BackupEntry $backupPath ('mods/common/' + $name) 'added'
                }
                Copy-Item -LiteralPath $src -Destination $dst -Force
            }
            $fontState = "包内 Noto Sans SC($($bundled.Count) 个文件)"
            if (-not $DryRun) { Ok "已部署包内中文字体:mods\common\($($bundled.Count) 个文件)" }
        } else {
            $fontSrc = $custom
            if (-not $fontSrc) { $fontSrc = Find-CjkFont $null }
            if (-not $fontSrc) {
                Fail '本机 %WINDIR%\Fonts 下没有可用的中文字体,包内也没有 fonts\。'
                Fail '请先装一个中文字体,或用 -FontPath 指定一个 .ttf,然后重试。'
                Warn '已中止:补丁的 mod.yaml 指向中文字体,缺字体会让游戏启动时直接报错退出。'
                exit 1
            }
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

                # 载荷里的 mod.yaml 指向包内字体名,换成这一个系统字体后要同步引用。
                # 必须用大小写敏感比较(-cne):PowerShell 的 -ne 忽略大小写,
                # 会把 simhei.ttf 与 SimHei.ttf 当同一个名字。
                $n = 0
                foreach ($modYaml in Get-ChildItem -Path (Join-Path $Target 'mods') -Filter 'mod.yaml' -Recurse -File) {
                    $text = [IO.File]::ReadAllText($modYaml.FullName, [Text.Encoding]::UTF8)
                    $newText = $text
                    foreach ($dn in $DefaultFontNames) {
                        if ($newText.Contains("common|$dn")) { $newText = $newText.Replace("common|$dn", "common|$fontName") }
                    }
                    if ($newText -cne $text) {
                        [IO.File]::WriteAllText($modYaml.FullName, $newText, (New-Object Text.UTF8Encoding $false))
                        $n++
                    }
                }
                if ($n -gt 0) { Info "已把 $n 个 mod.yaml 的字体引用同步为 $fontName" }
            }
        }
    }

    # --- 汇总
    Title '安装结果'
    if ($DryRun) {
        Warn '这是预演(DryRun),没有写任何文件。去掉 -DryRun 即为实际安装。'
    } else {
        Ok "覆盖 $copied 个文件,新增 $added 个文件,已是译文 $same 个"
        if ($fontState -ne '未处理') { Ok "字体:$fontState" }
        Info "备份与还原清单:$backupPath"
        Say ''
        Say '  现在启动游戏即可:' -ForegroundColor White
        foreach ($exe in @('RedAlert.exe', 'TiberianDawn.exe', 'Dune2000.exe', 'OpenRA.exe')) {
            if (Test-Path (Join-Path $Target $exe)) { Say ("    " + (Join-Path $Target $exe)) 'White' }
        }
        Say ''
        Say '  想还原英文:重新运行 setup.cmd,选 2' -ForegroundColor DarkGray
    }
    exit 0
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
    $latest = $null
    $data = $null
    if ($Backup) {
        $bp = $Backup
        if (-not (Test-Path -LiteralPath $bp)) { $bp = Join-Path $backupRoot $Backup }
        if (-not (Test-Path -LiteralPath $bp)) { Fail "指定的备份不存在:$Backup"; exit 1 }
        $latest = Get-Item -LiteralPath $bp
        $jsonPath = Join-Path $latest.FullName 'backup.json'
        if (-not (Test-Path $jsonPath)) { Fail "备份清单缺失:$jsonPath"; exit 1 }
        $data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Info "使用指定备份:$($latest.FullName)"
    } else {
        $pick = Select-Backup $backupRoot
        foreach ($s in $pick.Skipped) {
            Warn "跳过备份 ${s}：里面存的是本补丁的译文（在已汉化的目录上又装了一次），拿它还原不会有任何变化。"
        }
        if (-not $pick.Path) {
            Fail "没有可用的备份：$backupRoot 下的备份要么已经还原过，要么是重复安装时留下的译文快照。"
            Info '如果界面仍是中文，说明英文原件已经不在备份里了：可用 -Verify 看还有哪些文件没还原，'
            Info '或者用同版本的 OpenRA 安装包重新覆盖一遍 mods 目录。'
            exit 1
        }
        $latest = Get-Item -LiteralPath $pick.Path
        $jsonPath = Join-Path $latest.FullName 'backup.json'
        $data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Info "使用备份:$($latest.FullName)"
    }
    Info "备份时间:$($data.created)"
    if (-not (Test-Writable $Target)) {
        if ($DryRun) { Warn '目录不可写,但当前为 DryRun,继续' } else { Restart-Elevated; exit 0 }
    }

    $restored = 0; $removed = 0; $missing = 0; $stuck = 0; $skippedSame = 0
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
        } elseif ($e.state -eq 'same') {
            $skippedSame++
        } else {
            $bak = Join-Path $latest.FullName $rel
            if (Test-Path $bak) {
                if ($DryRun) { Say "    [预览] 还原 $rel" 'DarkGray' }
                else { Copy-Item -LiteralPath $bak -Destination $dst -Force; $restored++ }
            } else { Warn "备份文件缺失,跳过:$rel"; $missing++ }
        }
    }

    $orphan = 0
    if (-not $DryRun) { $orphan = Remove-OrphanFonts $data $Target }

    Title '还原结果'
    if ($DryRun) {
        Warn '这是预演(DryRun),没有写任何文件。'
    } else {
        Ok "还原 $restored 个文件,删除 $removed 个新增文件,清理字体 $orphan 个"
        if ($skippedSame -gt 0) { Info "$skippedSame 个文件在备份里标为「已是译文」,无需还原(重复安装产生)" }
        if ($missing -gt 0) { Warn "$missing 个文件在备份里找不到,未处理" }
        if ($stuck -gt 0)   { Warn "$stuck 个新增文件被占用未能删除,请手动清理" }
        # 已还原的不再参与下次挑选;名字撞车时加序号,避免出现 .已还原.已还原.已还原
        $done = $latest.FullName + '.已还原'
        $i = 2
        while (Test-Path -LiteralPath $done) { $done = $latest.FullName + '.已还原-' + $i; $i++ }
        Move-Item -LiteralPath $latest.FullName -Destination $done -Force
        Info "本次备份已标记为已还原:$done"
    }
    exit 0
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

    # 字体残留检查(原版 OpenRA 不带中文字体):包内两个字重 + 旧的单字体都查
    $fontNames = @()
    if ($manifest.font -and $manifest.font.bundled) {
        foreach ($b in @($manifest.font.bundled)) { $fontNames += (Split-Path -Leaf ($b.deployTo -replace '/', '\')) }
    }
    foreach ($n in $DefaultFontNames) { if ($fontNames -notcontains $n) { $fontNames += $n } }
    $fontNames += 'SimHei.ttf'   # 1.4.x 及更早装过的单字体

    $leftFonts = @()
    foreach ($n in $fontNames) {
        if (Test-Path (Join-Path $Target ('mods\common\' + $n))) { $leftFonts += $n }
    }
    $fontRemain = ($leftFonts.Count -gt 0)

    # 备份目录存在性提示
    $backupRoot = Join-Path $Target $BackupName
    $hasBackup  = Test-Path $backupRoot

    Title '校验结果'
    if ($remain -eq 0) {
        Ok "未检测到汉化文件残留 (已比对 $($manifest.files.Count) 个载荷,其中 $clean 个为英文/已删除状态)"
        if ($fontRemain) {
            Warn ("但发现字体 {0} 仍存在于 mods\common\,如已不需要可手动删除" -f ($leftFonts -join ', '))
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
        if ($fontRemain) { Warn ("字体 {0} 也仍残留于 mods\common\" -f ($leftFonts -join ', ')) }
        Say ''
        Say '  建议:重新运行 setup.cmd 选 2(或 install.ps1 -Uninstall)完成还原。' 'Yellow'
        exit 1
    }
}

# ---------------------------------------------------------------- 交互菜单
function Invoke-MenuAction([string[]]$ActionArgs) {
    # 三个动作函数内部都有 exit,直接调用会结束整个脚本、菜单也就退出了。
    # 因此每一项都用子进程重新跑一次本脚本,退出码只影响返回值。
    $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
    if ($Target) { $argv += @('-Target', $Target) }
    if ($ActionArgs) { $argv += $ActionArgs }
    & powershell.exe @argv
}

function Invoke-Menu {
    while ($true) {
        Clear-Host
        $manifest = Get-Manifest
        $ver = if ($manifest) { $manifest.version } else { '?' }
        Title "OpenRA 简体中文汉化补丁  v$ver"
        Say '  1) 安装汉化' 'White'
        Say '  2) 还原英文(卸载)' 'White'
        Say '  3) 检查是否已卸载干净' 'White'
        Say '  4) 只看不装(预演,不写任何文件)' 'White'
        Say '  0) 退出' 'White'
        Say ''
        $choice = $null
        try { $choice = (Read-Host '  请输入序号后回车').Trim() } catch { return }
        switch ($choice) {
            '1' { Invoke-MenuAction @() }
            '2' { Invoke-MenuAction @('-Uninstall') }
            '3' { Invoke-MenuAction @('-Verify') }
            '4' { Invoke-MenuAction @('-DryRun') }
            '0' { return }
            default { continue }
        }
        Say ''
        try { Read-Host '  按回车返回菜单' | Out-Null } catch { return }
    }
}

# ---------------------------------------------------------------- 入口
try {
    if ($Menu)          { Invoke-Menu }
    elseif ($Verify)    { Invoke-Verify }
    elseif ($Uninstall) { Invoke-Uninstall }
    else                { Invoke-Install }
} catch {
    Fail $_.Exception.Message
    Say $_.ScriptStackTrace 'DarkGray'
    exit 1
}
