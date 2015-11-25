cd ~/AppData/Local

# Grab the latest release from GitHub
$response = Invoke-WebRequest 'https://api.github.com/repos/jamesqo/Emptify/releases'
$releases = $response.Content | ConvertFrom-Json
$latest = $releases[0]
$urls = $latest.assets | Select browser_download_url

# Download x64 binaries if on 64-bit
$amd64 = [Environment]::Is64BitOperatingSystem
$pattern = ('Win32', 'x64')[$amd64]

$query = $urls | Where { $_ | Select-String "Emptify.$pattern.zip" }
$url = $query | Select -Index 0

Invoke-WebRequest $url.browser_download_url -OutFile 'Emptify.zip'

# Decompress the zip file
$src = [IO.Path]::Combine($pwd.Path, 'Emptify.zip') # Path.GetFullPath is unreliable in PS-- see stackoverflow.com/q/33907574
$dest = [IO.Path]::Combine($pwd.Path, 'Emptify')

# Remove previous installations
if ([IO.Directory]::Exists($dest))
{
    [IO.Directory]::Delete($dest, $true)
}

Add-Type -AssemblyName System.IO.Compression.FileSystem # PowerShell lacks native support for zip files
[IO.Compression.ZipFile]::ExtractToDirectory($src, $pwd.Path)
Move-Item "Emptify.$pattern" 'Emptify' # Erase architecture info
Remove-Item 'Emptify.zip' # Cleanup after ourselves

# Add ourselves to PATH if not in it
Get-Command emptify 2> $null
if (-not $?)
{
    $current = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User)
    $corrupt = $current.EndsWith(';') # Don't add a ; to PATH if it already ends in one
    $suffix = (";$dest", $dest)[$corrupt]
    $new = $current + $suffix
    [Environment]::SetEnvironmentVariable('PATH', $new, [EnvironmentVariableTarget]::User)
}
