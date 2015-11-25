cd ~/AppData/Local

# Grab the latest release from GitHub
$response = Invoke-WebRequest 'https://api.github.com/repos/jamesqo/Emptify/releases'
$releases = $response.Content | ConvertFrom-Json
$latest = $releases[0]
$urls = $latest.assets | Select browser_download_url

# Download x64 binaries if on 64-bit
$amd64 = [Environment]::Is64BitOperatingSystem
$pattern = ('Win32', 'x64')[$amd64]

$query = $urls | Where { $_ | Select-String $pattern }
$url = $query | Select -Index 0

Invoke-WebRequest $url.browser_download_url -OutFile 'Emptify.zip'

# Remove previous installations
$src = [IO.Path]::Combine($pwd.Path, 'Emptify.zip') # Path.GetFullPath is unreliable in PS-- see stackoverflow.com/q/33907574
$dest = [IO.Path]::Combine($pwd.Path, 'Emptify')
if ([IO.Directory]::Exists($dest))
{
    [IO.Directory]::Delete($dest, $true)
}

# Decompress the zip file
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory($src, $dest)
Remove-Item 'Emptify.zip' # Cleanup after ourselves

# Add ourselves to PATH if not in it
Get-Command emptify 2> $null
if (-not $?)
{
    $current = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User)
    $corrupt = $current.EndsWith(';')
    $suffix = (';' + $dest, $dest)[$corrupt]
    $new = $current + $suffix
    [Environment]::SetEnvironmentVariable('PATH', $new, [EnvironmentVariableTarget]::User)
}
