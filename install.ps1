cd ~/AppData/Local

# Grab the latest release from GitHub
$response = iwr 'https://api.github.com/repos/jamesqo/Emptify/releases'
$releases = $response.Content | ConvertFrom-Json
$latest = $releases | Select -Index 0
$urls = $latest.assets | Select browser_download_url

# Download x64 binaries if on 64-bit
$amd64 = [Environment]::Is64BitOperatingSystem
$pattern = ('Win32', 'x64')[$amd64]

$query = $urls | Where { $_ | sls "Emptify.$pattern.zip" }
$url = $query | Select -Index 0

iwr $url.browser_download_url -OutFile 'Emptify.zip'

# Decompress the zip file
$src = Join-Path $pwd 'Emptify.zip' # Path.GetFullPath is unreliable in PS-- see stackoverflow.com/q/33907574
$dest = Join-Path $pwd 'Emptify'

# Remove previous installations
if (Test-Path $dest)
{
    ri -Recurse -Force $dest
}

Add-Type -AssemblyName System.IO.Compression.FileSystem # PowerShell lacks native support for zip files
[IO.Compression.ZipFile]::ExtractToDirectory($src, $pwd)
mi "Emptify.$pattern" 'Emptify' # Erase architecture info
ri 'Emptify.zip' # Cleanup after ourselves

# Add ourselves to PATH if not in it
gcm emptify 2>&1 | Out-Null
if (-not $?)
{
    $current = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User)
    $hassemi = $current.EndsWith(';') # Don't add a ; to PATH if it already ends in one
    $newvalue = ("$current;$dest", $current$dest)[$hassemi]
    [Environment]::SetEnvironmentVariable('PATH', $newvalue, [EnvironmentVariableTarget]::User)
}
