# =====================================================
# OVERSEER PINATA AUTO-DEPLOY MODULE (PowerShell)
# Uploads Hugo /public folder to IPFS via Pinata API
# =====================================================

# CONFIG
$PinataAPIKey = "fbb4e4ac5ffcbbaa47f3"
$PinataSecretKey = "9c09b649d7b3e9a01c0c930de9fd91d3cac6790b06f6fae7963e4315e8601f5e"
$PublicDir = "C:\Users\Nefs\Projects\CompendiumSite\public"
$LogFile = "C:\Users\Nefs\Projects\CompendiumSite\pinata_deploy_log.txt"

Write-Host "[1/4] Building Hugo site..." -ForegroundColor DarkCyan
Set-Location "C:\Users\Nefs\Projects\CompendiumSite"
& "C:/Program Files/Hugo/hugo.exe" --gc --minify
Write-Host "[1/4] Hugo build complete." -ForegroundColor Green

# STEP 2: Collect all files from /public
Write-Host "[2/4] Collecting files from /public..." -ForegroundColor DarkCyan
$files = Get-ChildItem -Path $PublicDir -Recurse -File -Force -ErrorAction SilentlyContinue
$totalFiles = ($files | Measure-Object).Count
Write-Host "[2/4] Found $totalFiles files." -ForegroundColor Green

# STEP 3: Build multipart form and upload via API
Write-Host "[3/4] Uploading to Pinata API..." -ForegroundColor DarkCyan

$boundary = [System.Guid]::NewGuid().ToString().Replace("-", "")
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$pinataOptions = '{"wrapWithDirectory": true}'

$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
    "pinata_api_key" = $PinataAPIKey
    "pinata_secret_api_key" = $PinataSecretKey
}

# Build multipart body using byte array for proper encoding
$boundaryBytes = [System.Text.Encoding]::UTF8.GetBytes("--$boundary")
$pinataOptionsBytes = [System.Text.Encoding]::UTF8.GetBytes("Content-Disposition: form-data; name=`"pinataOptions`"`r`n`r`n$pinataOptions`r`n")
$endBoundaryBytes = [System.Text.Encoding]::UTF8.GetBytes("--$boundary--`r`n")

$bodyBytes = $boundaryBytes + $pinataOptionsBytes

# Add each file
foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($PublicDir.Length + 1).Replace("\", "/")
    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $base64 = [Convert]::ToBase64String($fileBytes)
    
    $separator = "--$boundary`r`n"
    $disposition = "Content-Disposition: form-data; name=`"file``; filename=`"$relativePath`"`r`n"
    $contentType = "Content-Type: application/octet-stream`r`n"
    $emptyLine = "`r`n"
    
    $separatorBytes = [System.Text.Encoding]::UTF8.GetBytes($separator)
    $dispBytes = [System.Text.Encoding]::UTF8.GetBytes($disposition)
    $ctBytes = [System.Text.Encoding]::UTF8.GetBytes($contentType)
    $emptyBytes = [System.Text.Encoding]::UTF8.GetBytes($emptyLine)
    $fileBase64Bytes = [System.Text.Encoding]::UTF8.GetBytes($base64)
    
    $bodyBytes += $separatorBytes + $dispBytes + $ctBytes + $emptyBytes + $fileBase64Bytes
}

$bodyBytes += $endBoundaryBytes

$url = "https://api.pinata.cloud/pinning/pinFileToIPFS"

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $bodyBytes
    $cid = $response.IpfsHash
    Write-Host "[3/4] Upload complete! CID: $cid" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Upload failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# STEP 4: Log result
Write-Host "[4/4] Logging deployment..." -ForegroundColor DarkCyan
$logEntry = "$timestamp | CID: $cid | Files: $totalFiles"
Add-Content -Path $LogFile -Value $logEntry
Write-Host "[4/4] Done." -ForegroundColor Green

# OUTPUT
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT SUCCESSFUL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CID: $cid"
Write-Host "  Gateway: https://teal-calm-roundworm-152.mypinata.cloud/ipfs/$cid"
Write-Host "  Files uploaded: $totalFiles"
Write-Host "  Logged to: $LogFile"
Write-Host "========================================" -ForegroundColor Cyan

return $cid
