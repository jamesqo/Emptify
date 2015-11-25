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
if ([IO.Directory]::Exists('Emptify'))
{
    [IO.Directory]::Delete('Emptify', $true)
}

# Decompress the zip file
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory('Emptify.zip', 'Emptify')
Remove-Item 'Emptify.zip' # Cleanup after ourselves

# Add ourselves to PATH if not in it
Get-Command emptify 2> $null
if (-not $?)
{
    $current = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User)
    $addend = [IO.Path]::Combine($pwd.Path, 'Emptify')
    if (-not $current.EndsWith(';'))
    {
        $addend = ';' + $addend
    }
    $combined = $current + $addend
    [Environment]::SetEnvironmentVariable('PATH', $combined, [EnvironmentVariableTarget]::User)
}
