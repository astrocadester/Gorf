:: build.bat
@echo off
setlocal

cd /d "%~dp0"

set "BUILD_GERMAN=0"
set "BUILD_FRENCH=0"
set "BUILD_KLINGON=0"
if /i "%~1"=="-g" set "BUILD_GERMAN=1"
if /i "%~1"=="--german" set "BUILD_GERMAN=1"
if /i "%~1"=="-f" set "BUILD_FRENCH=1"
if /i "%~1"=="--french" set "BUILD_FRENCH=1"
if /i "%~1"=="-k" set "BUILD_KLINGON=1"
if /i "%~1"=="--klingon" set "BUILD_KLINGON=1"

:: -----------------------------------------------------------------------------
:: Pre-flight Checks & Dependency Resolution
:: -----------------------------------------------------------------------------

:: Resolve zmac executable path
if defined ZMAC (
    if exist "%ZMAC%" (
        set "ZMAC_BIN=%ZMAC%"
    ) else (
        where "%ZMAC%" >nul 2>&1 && set "ZMAC_BIN=%ZMAC%" || (echo ERROR: ZMAC not found & pause & exit /b 1)
    )
) else if exist "tools\zmac.exe" (
    set "ZMAC_BIN=tools\zmac.exe"
) else (
    where zmac >nul 2>&1 && set "ZMAC_BIN=zmac" || (echo ERROR: zmac not found & pause & exit /b 1)
)

:: -----------------------------------------------------------------------------
:: Build Execution
:: -----------------------------------------------------------------------------

echo Gorf ROM build
echo   source: src\Gorf_Disassembly.asm
echo   output: roms
echo.

echo [1/5] Preparing clean build environment...
if exist "src\zout" rmdir /s /q "src\zout"
mkdir "src\zout"
if not exist "roms" mkdir "roms"

echo [2/5] Assembling Gorf_Disassembly.asm
echo       zmac: %ZMAC_BIN%
"%ZMAC_BIN%" -h -o src\zout\Gorf_Disassembly.hex -x src\zout\Gorf_Disassembly.lst src\Gorf_Disassembly.asm
if %ERRORLEVEL% neq 0 (
    echo ERROR: zmac failed. Review the assembler output above.
    pause
    exit /b %ERRORLEVEL%
)

if "%BUILD_GERMAN%"=="1" (
    if not exist "src\german\GERMAN_X11.asm" (
        echo ERROR: German source file not found: src\german\GERMAN_X11.asm
        pause
        exit /b 1
    )

    echo [2.5/5] Assembling Optional German ROM: GERMAN_X11.asm
    "%ZMAC_BIN%" -h -o src\zout\GERMAN_X11.hex -x src\zout\GERMAN_X11.lst src\german\GERMAN_X11.asm
    if errorlevel 1 (
        echo ERROR: zmac failed while assembling the German ROM.
        pause
        exit /b 1
    )

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$inputFile = 'src\zout\GERMAN_X11.hex';" ^
        "$outputFile = 'roms\german.x11';" ^
        "if (-not (Test-Path $inputFile)) { Write-Error 'German HEX file missing.'; exit 1 };" ^
        "$memory = [byte[]]::new(0x1000);" ^
        "for ($i = 0; $i -lt 0x1000; $i++) { $memory[$i] = 0xFF };" ^
        "$written = 0;" ^
        "$hexLines = Get-Content $inputFile;" ^
        "foreach ($line in $hexLines) {" ^
        "    if (-not $line.StartsWith(':')) { continue };" ^
        "    $byteCount = [Convert]::ToByte($line.Substring(1, 2), 16);" ^
        "    $address = [Convert]::ToUInt16($line.Substring(3, 4), 16);" ^
        "    $recordType = [Convert]::ToByte($line.Substring(7, 2), 16);" ^
        "    if ($recordType -eq 0) {" ^
        "        for ($i = 0; $i -lt $byteCount; $i++) {" ^
        "            $targetAddr = $address + $i;" ^
        "            if (($targetAddr -ge 0xC000) -and ($targetAddr -lt 0xD000)) {" ^
        "                $memory[$targetAddr - 0xC000] = [Convert]::ToByte($line.Substring(9 + ($i * 2), 2), 16);" ^
        "                $written++;" ^
        "            }" ^
        "        }" ^
        "    }" ^
        "};" ^
        "if ($written -ne 0x1000) { Write-Error ('German ROM contains ' + $written + ' assembled bytes; expected 4096.'); exit 1 };" ^
        "[System.IO.File]::WriteAllBytes($outputFile, $memory);" ^
        "Write-Host ('  -> Wrote german.x11 (' + $memory.Length + ' bytes)');"

    if errorlevel 1 (
        echo ERROR: German ROM conversion failed.
        pause
        exit /b 1
    )
)

if "%BUILD_FRENCH%"=="1" (
    if not exist "src\french\FRENCH_X11.asm" (
        echo ERROR: French source file not found: src\french\FRENCH_X11.asm
        pause
        exit /b 1
    )

    echo [2.5/5] Assembling Optional French ROM: FRENCH_X11.asm
    "%ZMAC_BIN%" -h -o src\zout\FRENCH_X11.hex -x src\zout\FRENCH_X11.lst src\french\FRENCH_X11.asm
    if errorlevel 1 (
        echo ERROR: zmac failed while assembling the French ROM.
        pause
        exit /b 1
    )

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$inputFile = 'src\zout\FRENCH_X11.hex';" ^
        "$outputFile = 'roms\french.x11';" ^
        "if (-not (Test-Path $inputFile)) { Write-Error 'French HEX file missing.'; exit 1 };" ^
        "$memory = [byte[]]::new(0x1000);" ^
        "for ($i = 0; $i -lt 0x1000; $i++) { $memory[$i] = 0xFF };" ^
        "$written = 0;" ^
        "$hexLines = Get-Content $inputFile;" ^
        "foreach ($line in $hexLines) {" ^
        "    if (-not $line.StartsWith(':')) { continue };" ^
        "    $byteCount = [Convert]::ToByte($line.Substring(1, 2), 16);" ^
        "    $address = [Convert]::ToUInt16($line.Substring(3, 4), 16);" ^
        "    $recordType = [Convert]::ToByte($line.Substring(7, 2), 16);" ^
        "    if ($recordType -eq 0) {" ^
        "        for ($i = 0; $i -lt $byteCount; $i++) {" ^
        "            $targetAddr = $address + $i;" ^
        "            if (($targetAddr -ge 0xC000) -and ($targetAddr -lt 0xD000)) {" ^
        "                $memory[$targetAddr - 0xC000] = [Convert]::ToByte($line.Substring(9 + ($i * 2), 2), 16);" ^
        "                $written++;" ^
        "            }" ^
        "        }" ^
        "    }" ^
        "};" ^
        "if ($written -ne 0x1000) { Write-Error ('French ROM contains ' + $written + ' assembled bytes; expected 4096.'); exit 1 };" ^
        "[System.IO.File]::WriteAllBytes($outputFile, $memory);" ^
        "Write-Host ('  -> Wrote french.x11 (' + $memory.Length + ' bytes)');"

    if errorlevel 1 (
        echo ERROR: French ROM conversion failed.
        pause
        exit /b 1
    )
)

if "%BUILD_KLINGON%"=="1" (
    if not exist "src\klingon\KLINGON_X11.asm" (
        echo ERROR: Klingon source file not found: src\klingon\KLINGON_X11.asm
        pause
        exit /b 1
    )

    echo [2.5/5] Assembling Optional Klingon ROM: KLINGON_X11.asm
    "%ZMAC_BIN%" -h -o src\zout\KLINGON_X11.hex -x src\zout\KLINGON_X11.lst src\klingon\KLINGON_X11.asm
    if errorlevel 1 (
        echo ERROR: zmac failed while assembling the Klingon ROM.
        pause
        exit /b 1
    )

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$inputFile = 'src\zout\KLINGON_X11.hex';" ^
        "$outputFile = 'roms\klingon.x11';" ^
        "if (-not (Test-Path $inputFile)) { Write-Error 'Klingon HEX file missing.'; exit 1 };" ^
        "$memory = [byte[]]::new(0x1000);" ^
        "for ($i = 0; $i -lt 0x1000; $i++) { $memory[$i] = 0xFF };" ^
        "$written = 0;" ^
        "$hexLines = Get-Content $inputFile;" ^
        "foreach ($line in $hexLines) {" ^
        "    if (-not $line.StartsWith(':')) { continue };" ^
        "    $byteCount = [Convert]::ToByte($line.Substring(1, 2), 16);" ^
        "    $address = [Convert]::ToUInt16($line.Substring(3, 4), 16);" ^
        "    $recordType = [Convert]::ToByte($line.Substring(7, 2), 16);" ^
        "    if ($recordType -eq 0) {" ^
        "        for ($i = 0; $i -lt $byteCount; $i++) {" ^
        "            $targetAddr = $address + $i;" ^
        "            if (($targetAddr -ge 0xC000) -and ($targetAddr -lt 0xD000)) {" ^
        "                $memory[$targetAddr - 0xC000] = [Convert]::ToByte($line.Substring(9 + ($i * 2), 2), 16);" ^
        "                $written++;" ^
        "            }" ^
        "        }" ^
        "    }" ^
        "};" ^
        "if ($written -ne 0x1000) { Write-Error ('Klingon ROM contains ' + $written + ' assembled bytes; expected 4096.'); exit 1 };" ^
        "[System.IO.File]::WriteAllBytes($outputFile, $memory);" ^
        "Write-Host ('  -> Wrote klingon.x11 (' + $memory.Length + ' bytes)');"

    if errorlevel 1 (
        echo ERROR: Klingon ROM conversion failed.
        pause
        exit /b 1
    )
)

echo [3/5] Splitting image into Gorf ROMs...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$inputFile = 'src\zout\Gorf_Disassembly.hex';" ^
    "$outputDir = 'roms';" ^
    "if (-not (Test-Path $inputFile)) { Write-Error 'Input HEX file missing.'; exit 1 };" ^
    "$memory = [byte[]]::new(0xC000);" ^
    "for ($i = 0; $i -lt 0xC000; $i++) { $memory[$i] = 0xFF };" ^
    "$hexLines = Get-Content $inputFile;" ^
    "foreach ($line in $hexLines) {" ^
    "    if (-not $line.StartsWith(':')) { continue };" ^
    "    $byteCount = [Convert]::ToByte($line.Substring(1, 2), 16);" ^
    "    $address   = [Convert]::ToUInt16($line.Substring(3, 4), 16);" ^
    "    $recordType= [Convert]::ToByte($line.Substring(7, 2), 16);" ^
    "    if ($recordType -eq 0) {" ^
    "        for ($i = 0; $i -lt $byteCount; $i++) {" ^
    "            $dataByte = [Convert]::ToByte($line.Substring(9 + ($i * 2), 2), 16);" ^
    "            $targetAddr = $address + $i;" ^
    "            if ($targetAddr -lt 0xC000) { $memory[$targetAddr] = $dataByte };" ^
    "        }" ^
    "    }" ^
    "};" ^
    "# gorfpgm1f uses gorf_a.x1..gorf_h.x8 rather than the German 873*.x* names." ^
    "if ($env:BUILD_FRENCH -eq '1') {" ^
    "    $romMap = [ordered]@{" ^
    "        'gorf_a.x1' = 0x0000..0x0FFF; 'gorf_b.x2' = 0x1000..0x1FFF;" ^
    "        'gorf_c.x3' = 0x2000..0x2FFF; 'gorf_d.x4' = 0x3000..0x3FFF;" ^
    "        'gorf_e.x5' = 0x8000..0x8FFF; 'gorf_f.x6' = 0x9000..0x9FFF;" ^
    "        'gorf_g.x7' = 0xA000..0xAFFF; 'gorf_h.x8' = 0xB000..0xBFFF;" ^
    "    };" ^
    "} elseif (($env:BUILD_GERMAN -eq '1') -or ($env:BUILD_KLINGON -eq '1')) {" ^
    "    $romMap = [ordered]@{" ^
    "        '873a.x1' = 0x0000..0x0FFF; '873b.x2' = 0x1000..0x1FFF;" ^
    "        '873c.x3' = 0x2000..0x2FFF; '873d.x4' = 0x3000..0x3FFF;" ^
    "        '873e.x5' = 0x8000..0x8FFF; '873f.x6' = 0x9000..0x9FFF;" ^
    "        '873g.x7' = 0xA000..0xAFFF; '873h.x8' = 0xB000..0xBFFF;" ^
    "    };" ^
    "} else {" ^
    "    $romMap = [ordered]@{" ^
    "        'gorf-a.bin' = 0x0000..0x0FFF; 'gorf-b.bin' = 0x1000..0x1FFF;" ^
    "        'gorf-c.bin' = 0x2000..0x2FFF; 'gorf-d.bin' = 0x3000..0x3FFF;" ^
    "        'gorf-e.bin' = 0x8000..0x8FFF; 'gorf-f.bin' = 0x9000..0x9FFF;" ^
    "        'gorf-g.bin' = 0xA000..0xAFFF; 'gorf-h.bin' = 0xB000..0xBFFF;" ^
    "    };" ^
    "};" ^
    "foreach ($romName in $romMap.Keys) {" ^
    "    $slice = $memory[$romMap[$romName]];" ^
    "    [System.IO.File]::WriteAllBytes((Join-Path $outputDir $romName), $slice);" ^
    "    Write-Host ('  -> Wrote ' + $romName + ' (' + $slice.Length + ' bytes)');" ^
    "}"

if %ERRORLEVEL% neq 0 (
    echo ERROR: ROM slicing failed.
    pause
    exit /b %ERRORLEVEL%
)

echo [4/5] Verifying Program-2 ROM SHA1 values...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$expected = @(" ^
    "    '76e2e3ad1a66755f1a369167fdb157690fd44a52'," ^
    "    '2601faf12d0ab4972c5535ffd722b03ecd8c097c'," ^
    "    '0b363a71d7585a4828e08668ebb2999c55e02721'," ^
    "    '392214cc6ed4155bfe022d36f0f86c2594a5ab57'," ^
    "    '720fb8b48e20c1fc281d8804259016c3c5364a07'," ^
    "    '9c9d6d3bfee6556dc7a01de81d6148dd02f04fc9'," ^
    "    '9edccceea5af015275582553ed238c40c73d8f4f'," ^
    "    '5aa8d824814ee1c30eaf0044da78d3aa8220dcaa'" ^
    ");" ^
    "if ($env:BUILD_FRENCH -eq '1') {" ^
    "    $names = @('gorf_a.x1','gorf_b.x2','gorf_c.x3','gorf_d.x4','gorf_e.x5','gorf_f.x6','gorf_g.x7','gorf_h.x8');" ^
    "} elseif (($env:BUILD_GERMAN -eq '1') -or ($env:BUILD_KLINGON -eq '1')) {" ^
    "    $names = @('873a.x1','873b.x2','873c.x3','873d.x4','873e.x5','873f.x6','873g.x7','873h.x8');" ^
    "} else {" ^
    "    $names = @('gorf-a.bin','gorf-b.bin','gorf-c.bin','gorf-d.bin','gorf-e.bin','gorf-f.bin','gorf-g.bin','gorf-h.bin');" ^
    "};" ^
    "for ($i = 0; $i -lt $names.Count; $i++) {" ^
    "    $path = Join-Path 'roms' $names[$i];" ^
    "    if (-not (Test-Path -LiteralPath $path)) { Write-Error ('Missing generated ROM: ' + $path); exit 1 };" ^
    "    $actual = (Get-FileHash -Algorithm SHA1 -LiteralPath $path).Hash.ToLowerInvariant();" ^
    "    if ($actual -ne $expected[$i]) { Write-Error ($names[$i] + ' SHA1 mismatch: expected ' + $expected[$i] + ', got ' + $actual); exit 1 };" ^
    "    Write-Host ('  verified  ' + $names[$i] + '  ' + $actual);" ^
    "}"

if %ERRORLEVEL% neq 0 (
    echo ERROR: Program-2 ROM verification failed.
    pause
    exit /b %ERRORLEVEL%
)

if not exist "roms\sc01.bin" (
    echo ERROR: Required speech ROM not found: roms\sc01.bin
    pause
    exit /b 1
)

if "%BUILD_GERMAN%"=="1" (
    echo [5/5] Packaging roms\gorfpgm1g.zip...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$romFiles = Get-ChildItem -Path 'roms\873?.x?';" ^
        "if ($romFiles.Count -ne 8) { Write-Error 'Expected eight Program-2 CPU ROM files.'; exit 1 };" ^
        "$romFiles += Get-Item 'roms\german.x11';" ^
        "$romFiles += Get-Item 'roms\sc01.bin';" ^
        "Compress-Archive -Path $romFiles.FullName -DestinationPath 'roms\gorfpgm1g.zip' -Force"
) else if "%BUILD_FRENCH%"=="1" (
    echo [5/5] Packaging roms\gorfpgm1f.zip...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$romFiles = Get-ChildItem -Path 'roms\gorf_?.x?';" ^
        "if ($romFiles.Count -ne 8) { Write-Error 'Expected eight Program-2 CPU ROM files using French MAME member names.'; exit 1 };" ^
        "$frenchAlias = 'src\zout\french_gorf.x11';" ^
        "try {" ^
        "    Copy-Item 'roms\french.x11' $frenchAlias -Force;" ^
        "    $romFiles += Get-Item $frenchAlias;" ^
        "    $romFiles += Get-Item 'roms\sc01.bin';" ^
        "    Compress-Archive -Path $romFiles.FullName -DestinationPath 'roms\gorfpgm1f.zip' -Force;" ^
        "} finally {" ^
        "    Remove-Item $frenchAlias -Force -ErrorAction SilentlyContinue;" ^
        "}"

) else if "%BUILD_KLINGON%"=="1" (
    echo [5/5] Packaging roms\gorfpgm1g.zip...
    if exist "roms\gorfk.zip" del /q "roms\gorfk.zip"
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$romFiles = Get-ChildItem -Path 'roms\873?.x?';" ^
        "if ($romFiles.Count -ne 8) { Write-Error 'Expected eight Program-2 CPU ROM files.'; exit 1 };" ^
        "$klingonAlias = 'src\zout\german.x11';" ^
        "try {" ^
        "    Copy-Item 'roms\klingon.x11' $klingonAlias -Force;" ^
        "    $romFiles += Get-Item $klingonAlias;" ^
        "    $romFiles += Get-Item 'roms\sc01.bin';" ^
        "    Compress-Archive -Path $romFiles.FullName -DestinationPath 'roms\gorfpgm1g.zip' -Force;" ^
        "} finally {" ^
        "    Remove-Item $klingonAlias -Force -ErrorAction SilentlyContinue;" ^
        "}"
) else (
    echo [5/5] Packaging roms\gorf.zip...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$romFiles = Get-ChildItem -Path 'roms\gorf-?.bin';" ^
        "$romFiles += Get-Item 'roms\sc01.bin';" ^
        "Compress-Archive -Path $romFiles.FullName -DestinationPath 'roms\gorf.zip' -Force"
)

if %ERRORLEVEL% neq 0 (
    echo ERROR: Packaging failed.
    pause
    exit /b %ERRORLEVEL%
)

if "%BUILD_FRENCH%"=="1" (
    echo   ROM files:   roms\gorf_a.x1 through roms\gorf_h.x8
    echo   French ROM:  roms\french.x11
    echo   ZIP X11:     french_gorf.x11
    echo   MAME ZIP:    roms\gorfpgm1f.zip
)

if "%BUILD_KLINGON%"=="1" (
    echo   Klingon ROM: roms\klingon.x11
    echo   ZIP X11:     german.x11 ^(Klingon ROM alias for MAME^)
    echo   MAME ZIP:    roms\gorfpgm1g.zip
)

echo.
echo =======================================================================
echo  BUILD SUCCESSFUL!
echo =======================================================================
pause
