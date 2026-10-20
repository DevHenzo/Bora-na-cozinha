param(
  [string]$SiteBaseUrl = 'https://devhenzo.github.io/Bora-na-cozinha/',
  [string[]]$RecipeIds
)

$ErrorActionPreference = 'Stop'

function ConvertTo-HtmlText {
  param([AllowNull()][string]$Value)

  return [System.Net.WebUtility]::HtmlEncode($Value)
}

function Get-RecipeIngredients {
  param($Recipe)

  if ($Recipe.stages) {
    return @($Recipe.stages | ForEach-Object { $_.ingredients })
  }

  return @($Recipe.ingredients)
}

function Get-RecipeIngredientsMarkup {
  param($Recipe)

  if ($Recipe.stages) {
    $sections = foreach ($stage in $Recipe.stages) {
      $items = foreach ($ingredient in $stage.ingredients) {
        '<li><label class="ingredient-item"><input type="checkbox" /><span>{0}</span></label></li>' -f (ConvertTo-HtmlText $ingredient)
      }
      '<li class="recipe-stage-heading"><h3>{0}</h3></li>{1}' -f `
        (ConvertTo-HtmlText $stage.name), ($items -join "`n")
    }
    return $sections -join "`n"
  }

  return (@($Recipe.ingredients | ForEach-Object {
    '<li><label class="ingredient-item"><input type="checkbox" /><span>{0}</span></label></li>' -f (ConvertTo-HtmlText $_)
  }) -join "`n")
}

function Get-RecipeInstructionsMarkup {
  param($Recipe)

  if ($Recipe.stages) {
    $sections = foreach ($stage in $Recipe.stages) {
      $steps = foreach ($step in $stage.instructions) {
        '              <li>{0}</li>' -f (ConvertTo-HtmlText $step)
      }
      @"
          <li class="instruction-stage">
            <h3>$(ConvertTo-HtmlText $stage.name)</h3>
            <ol class="instruction-stage-steps">
$($steps -join "`n")
            </ol>
          </li>
"@
    }
    return $sections -join "`n"
  }

  return (@($Recipe.instructions | ForEach-Object {
    '          <li>{0}</li>' -f (ConvertTo-HtmlText $_)
  }) -join "`n")
}

function Get-RecipeUtensilsMarkup {
  param($Recipe)

  $displayNames = @{
    'forma para bolo' = 'Forma'
    'forma para brownie' = 'Forma'
    'forma de pudim' = 'Forma'
    formas = 'Formas'
    'panela grande' = 'Panela'
    'panela para refogado' = 'Panela'
    'panela para banho-maria' = 'Panela'
    'batedor de arame' = 'Fouet'
    'refratario para torta' = 'Refratario'
    'assadeira para banho-maria' = 'Assadeira'
  }
  $imageAliases = @{
    'tacas ou recipiente' = 'recipiente'
    taca = 'taca'
    'colher de pau' = 'colher-de-pau'
    'colher para sobremesa' = 'colher'
    'panela com cabo' = 'panela'
    'travessa de vidro' = 'refratario'
    'bowl (tigela)' = 'tigela'
    'espatula para bolo' = 'espatula'
    'tabua de corte' = 'tabua-de-corte'
  }
  $imageNames = @(
    'assadeira', 'colher-de-pau', 'colher', 'espatula', 'faca', 'forma', 'formas',
    'fouet', 'frigideira', 'liquidificador', 'panela', 'panelas', 'recipiente',
    'refratario', 'tabua-de-corte', 'tigela', 'taca'
  )
  $rawUtensils = if ($Recipe.stages) {
    @($Recipe.stages | ForEach-Object { $_.utensils })
  } else {
    @($Recipe.utensils)
  }
  $normalize = {
    param([string]$Value)
    $normalized = $Value.Normalize([Text.NormalizationForm]::FormD) -replace '\p{Mn}', ''
    return ($normalized.ToLowerInvariant() -replace '\s+', ' ').Trim()
  }
  $cleaned = @($rawUtensils | Where-Object { $_ -is [string] -and $_.Trim() } |
    ForEach-Object { $_.Trim() -replace '\s+', ' ' })
  $normalizedNames = @($cleaned | ForEach-Object { & $normalize $_ })
  $multiplePans = @($normalizedNames | Where-Object {
    $_ -in @('panela', 'panelas', 'panela grande', 'panela para refogado', 'panela para banho-maria')
  } | Select-Object -Unique).Count -gt 1 -or $normalizedNames -contains 'panelas'
  $multipleForms = @($normalizedNames | Where-Object {
    $_ -in @('forma', 'formas', 'forma para bolo', 'forma para brownie', 'forma de pudim')
  } | Select-Object -Unique).Count -gt 1 -or $normalizedNames -contains 'formas'
  $seen = @{}
  $cards = foreach ($label in $cleaned) {
    $normalized = & $normalize $label
    $display = if ($displayNames.ContainsKey($normalized)) { $displayNames[$normalized] } else { $label }
    if ($display -eq 'Panela' -and $multiplePans) { $display = 'Panelas' }
    if ($display -eq 'Forma' -and $multipleForms) { $display = 'Formas' }
    $key = & $normalize $display
    if ($seen.ContainsKey($key)) { continue }
    $seen[$key] = $true

    $imageKey = if ($imageAliases.ContainsKey($key)) { $imageAliases[$key] } else { $key }
    $safeLabel = ConvertTo-HtmlText $display
    $imageMarkup = if ($imageKey -in $imageNames) {
      $imageFile = if ($imageKey -eq 'formas') { 'Formas.webp' } else { "$imageKey.webp" }
      '<img class="utensil-card__image" src="assets/images/utensilios/{0}" alt="" loading="lazy" decoding="async" aria-hidden="true" />' -f $imageFile
    } else {
      '<span class="utensil-card__image" aria-hidden="true"></span>'
    }
    @"
              <li class="utensil-card">
                $imageMarkup
                <span>$safeLabel</span>
              </li>
"@
  }

  if (-not $cards) { return '' }
  return @"
            <ul class="utensils-items">
$($cards -join "`n")
            </ul>
"@
}

function Get-RecipeCardMarkup {
  param($Recipe)

  $id = [uri]::EscapeDataString($Recipe.id)
  $title = ConvertTo-HtmlText $Recipe.title
  $category = ConvertTo-HtmlText $Recipe.category
  $time = ConvertTo-HtmlText $Recipe.time
  $description = ConvertTo-HtmlText $Recipe.description
  $difficulty = ConvertTo-HtmlText $Recipe.difficulty
  $image = ConvertTo-HtmlText $Recipe.image
  @"
          <article class="recipe-card">
            <a href="receitas/$id/" class="recipe-card__link" aria-label="Abrir receita de $title">
              <div class="recipe-card__media">
                <img src="$image" alt="$title" loading="lazy" />
              </div>
              <div class="recipe-card__body">
                <div class="recipe-card__topline">
                  <span class="recipe-card__category">$category</span>
                  <span class="recipe-card__time">$time</span>
                </div>
                <h3>$title</h3>
                <p>$description</p>
                <div class="recipe-card__meta">
                  <span>$difficulty</span>
                  <span class="recipe-card__cta" aria-hidden="true">&#8594;</span>
                </div>
              </div>
            </a>
          </article>
"@
}

function Get-StructuredRecipeData {
  param($Recipe, [uri]$RecipeUrl)

  $instructions = if ($Recipe.stages) {
    @($Recipe.stages | ForEach-Object {
      [ordered]@{
        '@type' = 'HowToSection'
        name = $_.name
        itemListElement = @($_.instructions | ForEach-Object -Begin { $position = 0 } -Process {
          $position++
          [ordered]@{ '@type' = 'HowToStep'; position = $position; text = $_ }
        })
      }
    })
  } else {
    @($Recipe.instructions | ForEach-Object -Begin { $position = 0 } -Process {
      $position++
      [ordered]@{ '@type' = 'HowToStep'; position = $position; text = $_ }
    })
  }
  $data = [ordered]@{
    '@context' = 'https://schema.org'
    '@type' = 'Recipe'
    name = $Recipe.title
    description = $Recipe.description
    image = ([uri]::new($RecipeUrl, $Recipe.image)).AbsoluteUri
    recipeCategory = $Recipe.category
    recipeYield = $Recipe.yield
    recipeIngredient = @(Get-RecipeIngredients $Recipe)
    recipeInstructions = $instructions
  }
  if ($Recipe.cuisine) { $data.recipeCuisine = $Recipe.cuisine }
  foreach ($field in @('prepTime', 'cookTime', 'totalTime')) {
    if ($Recipe.$field -is [string] -and $Recipe.$field -match '^P(?=\d|T)') {
      $data[$field] = $Recipe.$field
    }
  }
  if ($Recipe.author -is [string] -and $Recipe.author.Trim()) {
    $data.author = [ordered]@{ '@type' = 'Person'; name = $Recipe.author.Trim() }
  } elseif ($Recipe.author -is [System.Collections.IDictionary] -and $Recipe.author.name) {
    $data.author = $Recipe.author
  }
  if ($Recipe.keywords -and $Recipe.tags) {
    $data.keywords = (@($Recipe.keywords) + @($Recipe.tags)) -join ', '
  }
  return $data
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$catalogPath = Join-Path $projectRoot 'data\recipes.json'
$templatePath = Join-Path $projectRoot 'receita.html'
$outputRoot = Join-Path $projectRoot 'receitas'
$siteRoot = [uri]::new(($SiteBaseUrl.TrimEnd('/') + '/'))

if ($siteRoot.Scheme -notin @('http', 'https')) {
  throw 'SiteBaseUrl deve usar HTTP ou HTTPS.'
}

$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
if (-not $catalog -or $catalog -isnot [array]) {
  throw 'O catalog must be a non-empty JSON array.'
}
$ids = @{}
foreach ($recipe in $catalog) {
  if (-not $recipe.id -or $recipe.id -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
    throw "Missing or invalid catalog ID: $($recipe.title)"
  }
  if ($ids.ContainsKey($recipe.id)) {
    throw "ID duplicado no catálogo: $($recipe.id)"
  }
  $ids[$recipe.id] = $true
  if (-not $recipe.title -or -not $recipe.description -or -not $recipe.image -or
      -not (Get-RecipeIngredients $recipe) -or
      (-not $recipe.instructions -and -not $recipe.stages)) {
    throw "Required HTML/SEO fields are missing: $($recipe.id)"
  }
}
if (@($catalog.title | Sort-Object -Unique).Count -ne $catalog.Count) {
  throw 'Duplicate recipe titles found; make them unique before page generation.'
}
if (@($catalog.description | Sort-Object -Unique).Count -ne $catalog.Count) {
  throw 'Duplicate recipe descriptions found; make them unique before page generation.'
}

$recipesToGenerate = if ($RecipeIds -and $RecipeIds.Count -gt 0) {
  $selected = @($catalog | Where-Object { $RecipeIds -contains $_.id })
  $missingIds = @($RecipeIds | Where-Object { $_ -notin $selected.id })
  if ($missingIds.Count -gt 0) {
    throw "Recipe IDs not found in catalog: $($missingIds -join ', ')"
  }
  $selected
} else {
  $catalog
}

$template = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
$generated = 0
foreach ($recipe in $recipesToGenerate) {
  $escapedId = [uri]::EscapeDataString($recipe.id)
  $recipeUrl = [uri]::new($siteRoot, "receitas/$escapedId/")
  $imageUrl = ([uri]::new($siteRoot, $recipe.image)).AbsoluteUri
  $html = $template
  $html = $html.Replace('<head>', "<head>`n    <base href=`"../../`" />")
  $html = $html.Replace('<meta name="robots" content="noindex,follow" />', '<meta name="robots" content="index,follow" />')
  $html = $html.Replace('<!-- STATIC_RECIPE_CANONICAL -->', "<link rel=`"canonical`" href=`"$($recipeUrl.AbsoluteUri)`" />")
  $html = [regex]::Replace($html, '(?s)<meta\s+name="description"\s+content="[^"]*"\s*/>', '<meta name="description" content="' + (ConvertTo-HtmlText $recipe.description) + '" />', 1)
  $html = $html.Replace('<meta property="og:title" content="Bora na Cozinha!" />', '<meta property="og:title" content="' + (ConvertTo-HtmlText $recipe.title) + '" />')
  $html = $html.Replace('<meta property="og:description" content="Receita detalhada com ingredientes, passos de preparo, dicas e receitas relacionadas." />', '<meta property="og:description" content="' + (ConvertTo-HtmlText $recipe.description) + '" />')
  $html = $html.Replace('<meta property="og:url" content="receita.html" />', '<meta property="og:url" content="' + (ConvertTo-HtmlText $recipeUrl.AbsoluteUri) + '" />')
  $html = $html.Replace('<meta property="og:image" content="assets/images/logo.png" />', '<meta property="og:image" content="' + (ConvertTo-HtmlText $imageUrl) + '" />')
  $html = $html.Replace('<meta name="twitter:title" content="Bora na Cozinha!" />', '<meta name="twitter:title" content="' + (ConvertTo-HtmlText $recipe.title) + '" />')
  $html = $html.Replace('<meta name="twitter:description" content="Receita detalhada com ingredientes, passos de preparo, dicas e receitas relacionadas." />', '<meta name="twitter:description" content="' + (ConvertTo-HtmlText $recipe.description) + '" />')
  $html = $html.Replace('<meta name="twitter:image" content="assets/images/logo.png" />', '<meta name="twitter:image" content="' + (ConvertTo-HtmlText $imageUrl) + '" />')
  $html = $html.Replace('<title>Bora na Cozinha!</title>', '<title>' + (ConvertTo-HtmlText $recipe.title) + ' | Bora na Cozinha!</title>')
  $html = $html.Replace('<body class="recipe-page">', '<body class="recipe-page" data-static-recipe-page>')

  $html = [regex]::Replace($html, '(?s)<img\s+src="[^"]+"\s+alt="[^"]+"\s+data-recipe-image\s+loading="eager"\s*/>', '<img src="' + (ConvertTo-HtmlText $recipe.image) + '" alt="' + (ConvertTo-HtmlText $recipe.title) + '" data-recipe-image loading="eager" />', 1)
  $replacements = @{
    '__RECIPE_CATEGORY__' = ConvertTo-HtmlText $recipe.category
    '__RECIPE_TITLE__' = ConvertTo-HtmlText $recipe.title
    '__RECIPE_DESCRIPTION__' = ConvertTo-HtmlText $recipe.description
    '>Receita</span>' = '>' + (ConvertTo-HtmlText $recipe.title) + '</span>'
    '__RECIPE_TIME__' = ConvertTo-HtmlText $recipe.time
    '__RECIPE_YIELD__' = ConvertTo-HtmlText $recipe.yield
    '__RECIPE_DIFFICULTY__' = ConvertTo-HtmlText $recipe.difficulty
    '<!-- STATIC_RECIPE_INGREDIENTS -->' = Get-RecipeIngredientsMarkup $recipe
    '<!-- STATIC_RECIPE_UTENSILS -->' = Get-RecipeUtensilsMarkup $recipe
    '<!-- STATIC_RECIPE_INSTRUCTIONS -->' = Get-RecipeInstructionsMarkup $recipe
    '<!-- STATIC_RECIPE_TIPS -->' = (@($recipe.tips | ForEach-Object { '<li>{0}</li>' -f (ConvertTo-HtmlText $_) }) -join "`n")
  }
  foreach ($marker in $replacements.Keys) {
    $html = $html.Replace($marker, [string]$replacements[$marker])
  }
  if ((Get-RecipeUtensilsMarkup $recipe).Length -gt 0) {
    $html = $html.Replace('data-utensils-panel hidden', 'data-utensils-panel')
  }

  $related = @($catalog |
    Where-Object { $_.id -ne $recipe.id } |
    ForEach-Object {
      $sharedTags = @($_.tags | Where-Object { $recipe.tags -contains $_ }).Count
      [pscustomobject]@{
        Recipe = $_
        SameCategory = [int]($_.category -eq $recipe.category)
        SharedTags = $sharedTags
        OriginalIndex = [array]::IndexOf($catalog, $_)
      }
    } |
    Sort-Object @{ Expression = 'SameCategory'; Descending = $true }, @{ Expression = 'SharedTags'; Descending = $true }, @{ Expression = 'OriginalIndex'; Descending = $false } |
    Select-Object -First 3)
  $relatedMarkup = @($related | ForEach-Object { Get-RecipeCardMarkup $_.Recipe }) -join "`n"
  $html = $html.Replace('<!-- STATIC_RELATED_RECIPES -->', $relatedMarkup)

  $jsonLd = Get-StructuredRecipeData $recipe $recipeUrl
  $jsonLdText = ConvertTo-Json -InputObject $jsonLd -Depth 100 -Compress
  $jsonLdText = $jsonLdText.Replace('<', '\u003c').Replace('>', '\u003e').Replace('&', '\u0026')
  $staticDataText = ConvertTo-Json -InputObject $recipe -Depth 100 -Compress
  $staticDataText = $staticDataText.Replace('<', '\u003c').Replace('>', '\u003e').Replace('&', '\u0026')
  $html = $html.Replace('<!-- STATIC_RECIPE_JSONLD -->', '<script type="application/ld+json" data-recipe-json-ld>' + $jsonLdText + '</script>')
  $html = $html.Replace('<!-- STATIC_RECIPE_DATA -->', '<script type="application/json" data-static-recipe-data>' + $staticDataText + '</script>')

  $recipeDirectory = Join-Path $outputRoot $recipe.id
  New-Item -ItemType Directory -Path $recipeDirectory -Force | Out-Null
  $outputPath = Join-Path $recipeDirectory 'index.html'
  [System.IO.File]::WriteAllText($outputPath, $html, (New-Object System.Text.UTF8Encoding($false)))
  $generated++
}

Write-Output "Static recipe pages generated: $generated"
