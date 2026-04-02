param(
    [string]$ExampleBuildDir = "example/build",
    [string]$DocsDir = "site_ngdart",
    [string]$OutputDir = "dist",
    [string]$PagesBasePath = "/",
    [string]$DocsMountPath = "/site_ngdart/"
)

$ErrorActionPreference = "Stop"

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Copy-DirectoryContents([string]$Source, [string]$Destination) {
    Ensure-Directory $Destination
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Normalize-MountPath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return "/"
    }

    $normalized = $Path.Replace('\\', '/').Trim()

    if (-not $normalized.StartsWith('/')) {
        $normalized = "/$normalized"
    }

    if (-not $normalized.EndsWith('/')) {
        $normalized = "$normalized/"
    }

    return $normalized
}

function Join-MountPath([string]$BasePath, [string]$ChildPath) {
    $normalizedBasePath = Normalize-MountPath $BasePath
    $normalizedChildPath = Normalize-MountPath $ChildPath

    if ($normalizedBasePath -eq "/") {
        return $normalizedChildPath
    }

    return "/$($normalizedBasePath.Trim('/'))/$($normalizedChildPath.Trim('/'))/"
}

function Rewrite-DocsPaths([string]$Root, [string]$MountPath) {
    $normalizedRoot = (Resolve-Path $Root).Path
    $textExtensions = @(".html", ".css", ".js", ".xml", ".txt")
    $textFiles = Get-ChildItem -Path $normalizedRoot -Recurse -File | Where-Object {
        $textExtensions -contains $_.Extension.ToLowerInvariant()
    }

    foreach ($file in $textFiles) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        $updated = $content

        $updated = $updated.Replace('href="/', "href=`"$MountPath")
        $updated = $updated.Replace("href='/", "href='$MountPath")
        $updated = $updated.Replace('src="/', "src=`"$MountPath")
        $updated = $updated.Replace("src='/", "src='$MountPath")
        $updated = $updated.Replace('action="/', "action=`"$MountPath")
        $updated = $updated.Replace("action='/", "action='$MountPath")
        $updated = $updated.Replace('content="/', "content=`"$MountPath")
        $updated = $updated.Replace("content='/", "content='$MountPath")
        $updated = $updated.Replace('url(/', "url($MountPath")
        $updated = $updated.Replace('url("/', "url(`"$MountPath")
        $updated = $updated.Replace("url('/", "url('$MountPath")

        if ($updated -ne $content) {
            Set-Content -LiteralPath $file.FullName -Value $updated -NoNewline
        }
    }
}

function Add-PrettyUrlCopies([string]$Root) {
    $normalizedRoot = (Resolve-Path $Root).Path
    $htmlFiles = Get-ChildItem -Path $normalizedRoot -Recurse -Filter "*.html" -File | Where-Object {
        $_.Name -ne "index.html"
    }

    foreach ($file in $htmlFiles) {
        $targetDirectory = Join-Path $file.DirectoryName $file.BaseName
        Ensure-Directory $targetDirectory
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $targetDirectory "index.html") -Force
    }
}

$pagesBasePath = Normalize-MountPath $PagesBasePath
$docsMountPath = Join-MountPath $pagesBasePath $DocsMountPath

if (-not (Test-Path -LiteralPath $ExampleBuildDir)) {
    throw "Example build directory not found: $ExampleBuildDir"
}

if (-not (Test-Path -LiteralPath $DocsDir)) {
    throw "Docs directory not found: $DocsDir"
}

if (Test-Path -LiteralPath $OutputDir) {
    Remove-Item -LiteralPath $OutputDir -Recurse -Force
}

Ensure-Directory $OutputDir
Copy-DirectoryContents $ExampleBuildDir $OutputDir

$docsOutput = Join-Path $OutputDir "site_ngdart"
Copy-DirectoryContents $DocsDir $docsOutput
Rewrite-DocsPaths -Root $docsOutput -MountPath $docsMountPath
Add-PrettyUrlCopies -Root $docsOutput

if (Test-Path -LiteralPath (Join-Path $OutputDir ".dart_tool")) {
    Remove-Item -LiteralPath (Join-Path $OutputDir ".dart_tool") -Recurse -Force
}

New-Item -ItemType File -Path (Join-Path $OutputDir ".nojekyll") -Force | Out-Null
