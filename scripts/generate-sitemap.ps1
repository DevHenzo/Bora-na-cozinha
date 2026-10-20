param(
  [string]$SiteBaseUrl = 'https://devhenzo.github.io/Bora-na-cozinha/'
)

$ErrorActionPreference = 'Stop'
$baseUrl = [uri]::new(($SiteBaseUrl.TrimEnd('/') + '/'))
$catalogPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'data\recipes.json'
$sitemapPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'sitemap.xml'
$robotsPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'robots.txt'
$recipes = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'generate-static-recipes.ps1') -SiteBaseUrl $baseUrl.AbsoluteUri

$entries = @(
  '  <url><loc>{0}</loc></url>' -f [System.Security.SecurityElement]::Escape($baseUrl.AbsoluteUri)
  foreach ($recipe in $recipes) {
    $escapedId = [uri]::EscapeDataString($recipe.id)
    $recipeUrl = [uri]::new($baseUrl, "receitas/$escapedId/")
    '  <url><loc>{0}</loc></url>' -f [System.Security.SecurityElement]::Escape($recipeUrl.AbsoluteUri)
  }
)

$content = @(
  '<?xml version="1.0" encoding="UTF-8"?>'
  '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
  $entries
  '</urlset>'
) -join "`n"
[System.IO.File]::WriteAllText($sitemapPath, $content, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::WriteAllText(
  $robotsPath,
  "User-agent: *`nAllow: /`nSitemap: $($baseUrl.AbsoluteUri)sitemap.xml`n",
  (New-Object System.Text.UTF8Encoding($false))
)
Write-Output "Sitemap atualizado com $($recipes.Count) receitas: $sitemapPath"
