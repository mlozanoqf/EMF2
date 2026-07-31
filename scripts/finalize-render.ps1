$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $projectRoot "docs"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path $outputDirectory)) {
  throw "The rendered docs directory was not found."
}

[System.IO.File]::WriteAllText(
  (Join-Path $outputDirectory ".nojekyll"),
  "",
  $utf8NoBom
)

$sidebarHomePattern = @'
<li class="sidebar-item">\s*<div class="sidebar-item-container">\s*<a href="\./index\.html" class="sidebar-item-text sidebar-link(?: active)?"><span class="chapter-title">index\.html</span></a>\s*</div>\s*</li>\s*
'@

$homeBreadcrumbPattern = @'
<nav class="quarto-page-breadcrumbs" aria-label="breadcrumb"><ol class="breadcrumb"><li class="breadcrumb-item"><a href="\./index\.html"><span class="chapter-title">index\.html</span></a></li></ol></nav>\s*
'@

$previousHomePattern = @'
<div class="nav-page nav-page-previous">\s*<a href="\./index\.html" class="pagination-link" aria-label="index\.html">\s*<i class="bi bi-arrow-left-short"></i>\s*<span class="nav-page-text"><span class="chapter-title">index\.html</span></span>\s*</a>\s*</div>
'@

$regexOptions = [System.Text.RegularExpressions.RegexOptions]::Singleline
$previousHomeReplacement = "<div class=`"nav-page nav-page-previous`">`n  </div>"

Get-ChildItem -Path $outputDirectory -Filter "*.html" -File | ForEach-Object {
  $html = [System.IO.File]::ReadAllText($_.FullName, $utf8NoBom)
  $cleanedHtml = [regex]::Replace($html, $sidebarHomePattern, "", $regexOptions)
  $cleanedHtml = [regex]::Replace($cleanedHtml, $homeBreadcrumbPattern, "", $regexOptions)
  $cleanedHtml = [regex]::Replace(
    $cleanedHtml,
    $previousHomePattern,
    $previousHomeReplacement,
    $regexOptions
  )

  if ($cleanedHtml -ne $html) {
    [System.IO.File]::WriteAllText($_.FullName, $cleanedHtml, $utf8NoBom)
  }
}
