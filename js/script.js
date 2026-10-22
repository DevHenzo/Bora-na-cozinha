const recipeCategories = [
  { name: 'Bolos', description: 'Bolos fofinhos, caseiros e deliciosos para qualquer ocasião.' },
  { name: 'Doces', description: 'Docinhos e guloseimas para adoçar o seu dia.' },
  { name: 'Sobremesas', description: 'Delícias para finalizar qualquer refeição com sabor.' },
  { name: 'Massas', description: 'Lasanhas, macarrões e massas para todos os gostos.' },
  { name: 'Carnes', description: 'Receitas com carnes suculentas, assadas e bem temperadas.' },
  { name: 'Almoço e Janta', description: 'Pratos práticos e saborosos para as refeições do dia a dia.' },
  { name: 'Bebidas', description: 'Sucos, vitaminas e bebidas refrescantes para todos os momentos.' },
  { name: 'Café da Manhã', description: 'Receitas simples e gostosas para começar bem o dia.' },
  { name: 'Lanche', description: 'Lanches rápidos, salgados e gostosuras para qualquer hora.' }
];

const utensilDisplayNames = Object.freeze({
  'forma para bolo': 'Forma',
  'forma para brownie': 'Forma',
  'forma de pudim': 'Forma',
  formas: 'Formas',
  'panela grande': 'Panela',
  'panela para refogado': 'Panela',
  'panela para banho-maria': 'Panela',
  'batedor de arame': 'Fouet',
  'refratario para torta': 'Refratário',
  'assadeira para banho-maria': 'Assadeira'
});
const utensilImageAliases = Object.freeze({
  'tacas ou recipiente': 'recipiente',
  taca: 'taca',
  'colher para sobremesa': 'colher',
  'panela com cabo': 'panela',
  'travessa de vidro': 'refratario',
  'bowl (tigela)': 'tigela',
  'espatula para bolo': 'espatula'
});
const utensilImages = Object.freeze({
  assadeira: 'assets/images/utensilios/assadeira.webp',
  'colher de pau': 'assets/images/utensilios/colher-de-pau.webp',
  colher: 'assets/images/utensilios/colher.webp',
  espatula: 'assets/images/utensilios/espatula.webp',
  faca: 'assets/images/utensilios/faca.webp',
  forma: 'assets/images/utensilios/forma.webp',
  formas: 'assets/images/utensilios/Formas.webp',
  fouet: 'assets/images/utensilios/fouet.webp',
  frigideira: 'assets/images/utensilios/frigideira.webp',
  liquidificador: 'assets/images/utensilios/liquidificador.webp',
  panela: 'assets/images/utensilios/panela.webp',
  panelas: 'assets/images/utensilios/panelas.webp',
  recipiente: 'assets/images/utensilios/recipiente.webp',
  refratario: 'assets/images/utensilios/refratario.webp',
  'tabua de corte': 'assets/images/utensilios/tabua-de-corte.webp',
  tigela: 'assets/images/utensilios/tigela.webp',
  taca: 'assets/images/utensilios/taca.webp'
});

let recipeData = [];
const RECIPE_PAGE_SIZE = 12;

function getRecipePageUrl(recipeId) {
  return new URL(`receitas/${encodeURIComponent(recipeId)}/`, document.baseURI).href;
}

function getRecipeTimeDisplay(recipe) {
  const value = typeof recipe?.time === 'string' ? recipe.time.trim() : '';
  if (!value) {
    return '';
  }

  const simpleDurationPattern = /^(?=.*\d)(?:(?:\d+)\s*(?:h|hr|hrs|hora|horas))?(?:\s*(?:\d+)\s*(?:m|min|mins|minuto|minutos))?$/i;
  if (simpleDurationPattern.test(value)) {
    return value;
  }

  const blockedPatterns = /(informado|não informado|sem divis|tempo exato de forno|mínimo decorrido|dessalgue de \d+h|refrigeração)/i;
  if (blockedPatterns.test(value)) {
    return '';
  }

  const timeFragments = [...value.matchAll(/(\d+)\s*(h|hr|hora|horas|min|mins|minuto|minutos|minute|minutes)/gi)];
  if (timeFragments.length === 0) {
    return value;
  }

  const useOnlyFirst = value.includes('+') || value.includes('ou mais') || value.toLowerCase().includes('preparo');
  if (useOnlyFirst) {
    const [, amountText, unitText] = timeFragments[0];
    const amount = Number(amountText);
    const unit = unitText.toLowerCase();
    return `${unit.startsWith('h') ? amount * 60 : amount} min`;
  }

  let totalMinutes = 0;
  timeFragments.forEach((match) => {
    const amount = Number(match[1]);
    const unit = match[2].toLowerCase();
    if (unit.startsWith('h')) {
      totalMinutes += amount * 60;
    } else {
      totalMinutes += amount;
    }
  });

  return `${totalMinutes} min`;
}

function renderRecipeCards(container, recipes) {
  container.innerHTML = recipes
    .map((recipe) => {
      const recipeTime = getRecipeTimeDisplay(recipe);

      return `
        <article class="recipe-card" aria-label="${recipe.title}" data-recipe-card="${recipe.id}">
          <a href="${getRecipePageUrl(recipe.id)}" class="recipe-card__link" aria-label="Abrir receita de ${recipe.title}">
            <div class="recipe-card__media">
              <img src="${recipe.image}" alt="${recipe.title}" loading="lazy" />
            </div>
            <div class="recipe-card__body">
              <div class="recipe-card__topline">
                <span class="recipe-card__category">${recipe.category}</span>
                ${recipeTime ? `<span class="recipe-card__time">${recipeTime}</span>` : ''}
              </div>
              <h3>${recipe.title}</h3>
              <p>${recipe.description}</p>
              <div class="recipe-card__meta">
                <span>${recipe.yield}</span>
                <span>${recipe.difficulty}</span>
                <span class="recipe-card__cta" aria-hidden="true">→</span>
              </div>
            </div>
          </a>
        </article>
      `;
    })
    .join('');
}

function normalizeSearchText(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

function getCategorySlug(categoryName) {
  return normalizeSearchText(categoryName)
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

function setupRecipeSearch() {
  const forms = Array.from(document.querySelectorAll('[data-recipe-search-form]'));
  const inputs = Array.from(document.querySelectorAll('[data-recipe-search-input]'));
  const clearButtons = Array.from(document.querySelectorAll('[data-recipe-search-clear]'));
  const emptyMessage = document.querySelector('[data-recipe-search-empty]');
  const recipeGrid = document.querySelector('[data-recipe-grid="featured"]');
  const loadMoreButton = document.querySelector('[data-load-more-recipes]');
  const loadMoreContainer = loadMoreButton?.closest('.recipe-load-more');
  const mobileSearchPanel = document.querySelector('[data-mobile-search-panel]');
  const mobileSearchToggle = document.querySelector('.header-search-toggle');
  const mobileSearchClose = document.querySelector('[data-mobile-search-close]');
  const queryParam = new URLSearchParams(window.location.search).get('q') || '';

  inputs.forEach((input) => {
    input.value = recipeGrid ? queryParam : '';
  });

  const closeMobileSearch = () => {
    if (!mobileSearchPanel || !mobileSearchToggle) {
      return;
    }

    mobileSearchPanel.hidden = true;
    mobileSearchToggle.setAttribute('aria-expanded', 'false');
    mobileSearchToggle.setAttribute('aria-label', 'Abrir pesquisa');
  };

  mobileSearchToggle?.addEventListener('click', () => {
    if (!mobileSearchPanel) {
      return;
    }

    mobileSearchPanel.hidden = !mobileSearchPanel.hidden;
    const isOpen = !mobileSearchPanel.hidden;
    mobileSearchToggle.setAttribute('aria-expanded', String(isOpen));
    mobileSearchToggle.setAttribute('aria-label', isOpen ? 'Fechar pesquisa' : 'Abrir pesquisa');

    if (isOpen) {
      mobileSearchPanel.querySelector('[data-recipe-search-input]')?.focus();
    }
  });
  mobileSearchClose?.addEventListener('click', () => {
    closeMobileSearch();
    mobileSearchToggle?.focus();
  });

  const syncSearchInputs = (sourceInput) => {
    inputs.forEach((input) => {
      if (input !== sourceInput) {
        input.value = sourceInput.value;
      }
    });
    clearButtons.forEach((button) => {
      button.hidden = sourceInput.value.length === 0;
    });
  };

  if (!recipeGrid || !emptyMessage) {
    inputs.forEach((input) => input.addEventListener('input', () => syncSearchInputs(input)));
    clearButtons.forEach((button) => {
      button.addEventListener('click', () => {
        const input = button.closest('form')?.querySelector('[data-recipe-search-input]');
        inputs.forEach((searchInput) => {
          searchInput.value = '';
        });
        clearButtons.forEach((clearButton) => {
          clearButton.hidden = true;
        });
        input?.focus();
      });
    });
    return;
  }

  const officialCategoryNames = new Set(recipeCategories.map(({ name }) => normalizeSearchText(name)));
  const searchableRecipes = recipeData.map((recipe) => {
    const terms = normalizeSearchText([
      recipe.title,
      ...getRecipeIngredients(recipe),
      ...recipe.keywords,
      ...recipe.tags
    ].join(' ')).split(/[^a-z0-9]+/).filter(Boolean);

    return {
      recipe,
      terms,
      termSet: new Set(terms),
      categories: new Set([
        recipe.category,
        ...recipe.tags.filter((tag) => officialCategoryNames.has(normalizeSearchText(tag)))
      ].map(normalizeSearchText))
    };
  });
  const categoryParam = new URLSearchParams(window.location.search).get('categoria');
  const initialCategory = recipeCategories.find(({ name }) => getCategorySlug(name) === categoryParam);
  let selectedCategory = initialCategory ? normalizeSearchText(initialCategory.name) : 'all';
  let visibleCount = RECIPE_PAGE_SIZE;
  let hasScrolledForSearch = false;

  const scrollToFeatured = () => {
    recipeGrid.closest('#featured')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  const updateSearchResults = (resetVisibleCount = true) => {
    const query = normalizeSearchText(inputs[0]?.value || '');
    const queryTerms = query.split(/\s+/).filter(Boolean);
    const hasExactMatch = queryTerms.length > 0 && searchableRecipes.some(({ termSet }) =>
      queryTerms.every((term) => termSet.has(term))
    );
    const filteredRecipes = searchableRecipes
      .filter(({ categories, terms, termSet }) => {
        const categoryMatches = selectedCategory === 'all' || categories.has(selectedCategory);
        const queryMatches = queryTerms.length === 0 || queryTerms.every((term) =>
          hasExactMatch ? termSet.has(term) : terms.some((recipeTerm) => recipeTerm.startsWith(term))
        );
        return categoryMatches && queryMatches;
      })
      .map(({ recipe }) => recipe);

    if (resetVisibleCount) {
      visibleCount = RECIPE_PAGE_SIZE;
    }
    renderRecipeCards(recipeGrid, filteredRecipes.slice(0, visibleCount));
    const hasMoreRecipes = filteredRecipes.length > visibleCount;
    if (loadMoreButton) loadMoreButton.hidden = !hasMoreRecipes;
    if (loadMoreContainer) loadMoreContainer.hidden = !hasMoreRecipes;

    clearButtons.forEach((button) => {
      button.hidden = query.length === 0;
    });
    emptyMessage.textContent = selectedCategory !== 'all' && filteredRecipes.length === 0 && query.length === 0
      ? 'Novas receitas serão adicionadas a esta categoria em breve.'
      : 'Nenhuma receita encontrada. Tente outra busca.';
    emptyMessage.hidden = filteredRecipes.length !== 0;
  };

  loadMoreButton?.addEventListener('click', () => {
    visibleCount += RECIPE_PAGE_SIZE;
    updateSearchResults(false);
  });
  document.querySelectorAll('a[href$="#featured"]').forEach((link) => {
    link.addEventListener('click', () => {
      if (link.getAttribute('href').includes('?categoria=')) {
        return;
      }

      selectedCategory = 'all';
      inputs.forEach((input) => {
        input.value = '';
      });
      clearButtons.forEach((button) => {
        button.hidden = true;
      });
      updateSearchResults();
    });
  });
  inputs.forEach((input) => {
    input.addEventListener('input', () => {
      syncSearchInputs(input);
      updateSearchResults();

      const hasQuery = normalizeSearchText(input.value).length > 0;
      if (!hasQuery) {
        hasScrolledForSearch = false;
      } else if (!hasScrolledForSearch) {
        hasScrolledForSearch = true;
        scrollToFeatured();
      }
    });
  });
  clearButtons.forEach((button) => {
    button.addEventListener('click', () => {
      const input = button.closest('form')?.querySelector('[data-recipe-search-input]');
      inputs.forEach((searchInput) => {
        searchInput.value = '';
      });
      clearButtons.forEach((clearButton) => {
        clearButton.hidden = true;
      });
      updateSearchResults();
      hasScrolledForSearch = false;
      input?.focus();
    });
  });
  forms.forEach((form) => {
    form.addEventListener('submit', (event) => {
      event.preventDefault();
      updateSearchResults();
    });
  });

  updateSearchResults();

  if (queryParam.trim()) {
    hasScrolledForSearch = true;
    if (mobileSearchPanel && mobileSearchToggle && window.matchMedia('(max-width: 980px)').matches) {
      mobileSearchPanel.hidden = false;
      mobileSearchToggle.setAttribute('aria-expanded', 'true');
      mobileSearchToggle.setAttribute('aria-label', 'Fechar pesquisa');
    }
    window.requestAnimationFrame(scrollToFeatured);
  }
}

function setupNavigation() {
  const header = document.querySelector('.site-header');
  const navToggle = document.querySelector('.nav-toggle');
  const nav = document.querySelector('.site-nav');

  if (header) {
    window.addEventListener('scroll', () => {
      header.classList.toggle('scrolled', window.scrollY > 20);
    });
  }

  if (navToggle && nav) {
    navToggle.addEventListener('click', () => {
      const isOpen = nav.classList.toggle('is-open');
      navToggle.classList.toggle('is-open', isOpen);
      navToggle.setAttribute('aria-expanded', String(isOpen));
    });

    nav.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => {
        nav.classList.remove('is-open');
        navToggle.classList.remove('is-open');
        navToggle.setAttribute('aria-expanded', 'false');
      });
    });
  }
}

function setupSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach((link) => {
    link.addEventListener('click', (event) => {
      const target = document.querySelector(link.getAttribute('href'));
      if (!target) {
        return;
      }

      event.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}

function initHomePage() {
  const quickRecipes = recipeData.filter((recipe) => recipe.quick === true);
  const quickGrid = document.querySelector('[data-recipe-grid="quick"]');

  if (quickGrid) {
    renderRecipeCards(quickGrid, quickRecipes.slice(0, RECIPE_PAGE_SIZE));
  }
}

function getRecipeIngredients(recipe) {
  if (Array.isArray(recipe.ingredientGroups) && recipe.ingredientGroups.length > 0) {
    return recipe.ingredientGroups.flatMap((group) => group.ingredients || []);
  }

  if (Array.isArray(recipe.stages)) {
    return recipe.stages.flatMap((stage) => stage.ingredients || []);
  }

  return recipe.ingredients || [];
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;'
  }[character]));
}

function normalizeUtensilName(name) {
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLocaleLowerCase('pt-BR')
    .trim()
    .replace(/\s+/g, ' ');
}

function getRecipeUtensils(recipe) {
  const utensils = Array.isArray(recipe.stages)
    ? recipe.stages.flatMap((stage) => Array.isArray(stage.utensils) ? stage.utensils : [])
    : Array.isArray(recipe.utensils)
      ? recipe.utensils
      : [];
  const cleanedUtensils = utensils
    .filter((utensil) => typeof utensil === 'string')
    .map((utensil) => utensil.trim().replace(/\s+/g, ' '))
    .filter(Boolean);
  const panUtensils = new Set(
    cleanedUtensils
      .map(normalizeUtensilName)
      .filter((name) => ['panela', 'panelas', 'panela grande', 'panela para refogado', 'panela para banho-maria'].includes(name))
  );
  const recipeUsesMultiplePans = panUtensils.size > 1 || panUtensils.has('panelas');
  const formUtensilNames = new Set(
    cleanedUtensils
      .map(normalizeUtensilName)
      .filter((name) => ['forma', 'formas', 'forma para bolo', 'forma para brownie', 'forma de pudim'].includes(name))
  );
  const recipeUsesMultipleForms = formUtensilNames.size > 1 || formUtensilNames.has('formas');
  const seenUtensils = new Set();

  return cleanedUtensils.reduce((uniqueUtensils, label) => {
    const normalizedName = normalizeUtensilName(label);
    const displayName = utensilDisplayNames[normalizedName] || label;
    const standardizedName = displayName === 'Panela' && recipeUsesMultiplePans
      ? 'Panelas'
      : displayName === 'Forma' && recipeUsesMultipleForms
        ? 'Formas'
        : displayName;
    const standardizedKey = normalizeUtensilName(standardizedName);

    if (!seenUtensils.has(standardizedKey)) {
      seenUtensils.add(standardizedKey);
      uniqueUtensils.push(standardizedName);
    }

    return uniqueUtensils;
  }, []);
}

function updateRecipeSeo(recipe) {
  const descriptionMeta = document.querySelector('meta[name="description"]');
  if (descriptionMeta) {
    descriptionMeta.content = recipe.description;
  }

  document.title = `${recipe.title} | Bora na Cozinha!`;
  const canonicalUrl = new URL(`receitas/${encodeURIComponent(recipe.id)}/`, document.baseURI);
  let canonicalLink = document.querySelector('link[rel="canonical"]');
  if (!canonicalLink) {
    canonicalLink = document.createElement('link');
    canonicalLink.rel = 'canonical';
    document.head.append(canonicalLink);
  }
  canonicalLink.href = canonicalUrl.href;

  const socialMetadata = {
    'meta[property="og:title"]': recipe.title,
    'meta[property="og:description"]': recipe.description,
    'meta[property="og:url"]': canonicalUrl.href,
    'meta[property="og:image"]': new URL(recipe.image, document.baseURI).href,
    'meta[name="twitter:title"]': recipe.title,
    'meta[name="twitter:description"]': recipe.description,
    'meta[name="twitter:image"]': new URL(recipe.image, document.baseURI).href
  };
  Object.entries(socialMetadata).forEach(([selector, content]) => {
    const meta = document.querySelector(selector);
    if (meta) {
      meta.content = content;
    }
  });

  const stages = Array.isArray(recipe.stages) ? recipe.stages : null;
  const prepGroups = Array.isArray(recipe.preparationGroups) && recipe.preparationGroups.length ? recipe.preparationGroups : null;
  const recipeInstructions = prepGroups
    ? prepGroups.map((group) => ({
        '@type': 'HowToSection',
        name: group.name,
        itemListElement: group.instructions.map((text, index) => ({ '@type': 'HowToStep', position: index + 1, text }))
      }))
    : stages
    ? stages.map((stage) => ({
      '@type': 'HowToSection',
      name: stage.name,
      itemListElement: stage.instructions.map((text, index) => ({
        '@type': 'HowToStep',
        position: index + 1,
        text
      }))
    }))
    : recipe.instructions.map((text, index) => ({
      '@type': 'HowToStep',
      position: index + 1,
      text
    }));
  const structuredData = {
    '@context': 'https://schema.org',
    '@type': 'Recipe',
    name: recipe.title,
    description: recipe.description,
    image: new URL(recipe.image, document.baseURI).href,
    recipeCategory: recipe.category,
    recipeCuisine: recipe.cuisine || undefined,
    recipeYield: recipe.yield,
    keywords: [...recipe.keywords, ...recipe.tags].join(', '),
    recipeIngredient: getRecipeIngredients(recipe),
    recipeInstructions
  };

  if (recipe.prepTime) {
    structuredData.prepTime = recipe.prepTime;
  }
  if (recipe.cookTime) {
    structuredData.cookTime = recipe.cookTime;
  }
  if (recipe.totalTime) {
    structuredData.totalTime = recipe.totalTime;
  }

  let jsonLd = document.querySelector('script[data-recipe-json-ld]');
  if (!jsonLd) {
    jsonLd = document.createElement('script');
    jsonLd.type = 'application/ld+json';
    jsonLd.dataset.recipeJsonLd = 'true';
    document.head.append(jsonLd);
  }
  jsonLd.textContent = JSON.stringify(structuredData);
}

function renderRecipePage() {
  const legacyRecipeId = new URLSearchParams(window.location.search).get('id');
  const staticRecipePath = window.location.pathname.match(/(?:^|\/)receitas\/([^/]+)\/?$/);
  const staticRecipeId = staticRecipePath ? decodeURIComponent(staticRecipePath[1]) : '';
  const recipeId = legacyRecipeId || staticRecipeId;
  const recipe = recipeId
    ? recipeData.find((item) => item.id === recipeId)
    : recipeData[0];

  const image = document.querySelector('[data-recipe-image]');
  const title = document.querySelector('[data-recipe-name]');
  const category = document.querySelector('[data-recipe-category]');
  const description = document.querySelector('[data-recipe-description]');
  const time = document.querySelector('[data-recipe-time]');
  const yieldField = document.querySelector('[data-recipe-yield]');
  const difficulty = document.querySelector('[data-recipe-difficulty]');
  const breadcrumb = document.querySelector('[data-breadcrumb-current]');

  const displayTime = getRecipeTimeDisplay(recipe);
  const ingredients = document.querySelector('[data-ingredients]');
  const utensilsPanel = document.querySelector('[data-utensils-panel]');
  const utensils = document.querySelector('[data-utensils]');
  const instructions = document.querySelector('[data-instructions]');
  const tips = document.querySelector('[data-tips]');
  const tipsPanel = tips?.closest('[data-tips-panel]') || tips?.closest('aside');
  const related = document.querySelector('[data-related-recipes]');

  if (!recipe) {
    document.title = 'Receita não encontrada | Bora na Cozinha!';
    if (title) title.textContent = 'Receita não encontrada';
    if (description) {
      description.textContent = 'Não encontramos essa receita. Volte para os destaques e escolha outra opção.';
      description.setAttribute('role', 'alert');
    }
    document.querySelector('link[rel="canonical"]')?.remove();
    return;
  }

  if (!staticRecipePath) {
    window.location.replace(getRecipePageUrl(recipe.id));
    return;
  }

  updateRecipeSeo(recipe);
  if (image) image.src = recipe.image;
  if (image) image.alt = recipe.title;
  if (title) title.textContent = recipe.title;
  if (category) category.textContent = recipe.category;
  if (description) description.textContent = recipe.description;
  if (time) {
    if (displayTime) {
      time.textContent = displayTime;
    } else {
      time.closest('li')?.remove();
    }
  }
  if (yieldField) yieldField.textContent = recipe.yield;
  if (difficulty) difficulty.textContent = recipe.difficulty;
  if (breadcrumb) breadcrumb.textContent = recipe.title;

  if (ingredients) {
    const recipeIngredients = getRecipeIngredients(recipe);
    ingredients.innerHTML = Array.isArray(recipe.ingredientGroups) && recipe.ingredientGroups.length > 0
      ? recipe.ingredientGroups.map((group) => `
          <li class="recipe-stage-heading"><h3>${escapeHtml(group.name)}</h3></li>
          ${group.ingredients.map((item) => `<li><label class="ingredient-item"><input type="checkbox" /><span>${escapeHtml(item)}</span></label></li>`).join('')}
        `).join('')
      : Array.isArray(recipe.stages)
      ? recipe.stages.map((stage) => `
          <li class="recipe-stage-heading"><h3>${stage.name}</h3></li>
          ${stage.ingredients.map((item) => `<li><label class="ingredient-item"><input type="checkbox" /><span>${item}</span></label></li>`).join('')}
        `).join('')
      : recipeIngredients
        .map((item) => `<li><label class="ingredient-item"><input type="checkbox" /><span>${item}</span></label></li>`)
        .join('');

    const progress = document.querySelector('[data-ingredient-progress]');
    const progressLabel = document.querySelector('[data-ingredient-progress-label]');
    const progressFill = document.querySelector('[data-ingredient-progress-fill]');
    const completionMark = document.querySelector('[data-ingredient-complete]');
    const updateIngredientProgress = () => {
      const checkedCount = ingredients.querySelectorAll('input[type="checkbox"]:checked').length;
      const totalIngredients = recipeIngredients.length;
      const percentage = totalIngredients === 0 ? 0 : Math.round((checkedCount / totalIngredients) * 100);

      if (progress) {
        progress.setAttribute('aria-valuenow', String(percentage));
      }
      if (progressLabel) progressLabel.textContent = `${percentage}% concluído`;
      if (progressFill) progressFill.style.width = `${percentage}%`;
      if (completionMark) completionMark.hidden = percentage !== 100;
    };

    ingredients.addEventListener('change', updateIngredientProgress);
    updateIngredientProgress();
  }

  if (utensilsPanel && utensils) {
    const recipeUtensils = getRecipeUtensils(recipe);

    if (recipeUtensils.length > 0) {
      const list = document.createElement('ul');
      list.className = 'utensils-items';

      recipeUtensils.forEach((utensil) => {
        const item = document.createElement('li');
        item.className = 'utensil-card';

        const normalizedName = normalizeUtensilName(utensil);
        const imageKey = utensilImageAliases[normalizedName] || normalizedName;
        const imageSource = utensilImages[imageKey];
        const image = document.createElement(imageSource ? 'img' : 'span');
        image.className = 'utensil-card__image';
        image.setAttribute('aria-hidden', 'true');

        if (imageSource) {
          image.src = imageSource;
          image.alt = '';
          image.loading = 'lazy';
          image.decoding = 'async';
          image.addEventListener('error', () => {
            const placeholder = document.createElement('span');
            placeholder.className = 'utensil-card__image';
            placeholder.setAttribute('aria-hidden', 'true');
            image.replaceWith(placeholder);
          }, { once: true });
        }

        const label = document.createElement('span');
        label.textContent = utensil;

        item.append(image, label);
        list.append(item);
      });

      utensils.replaceChildren(list);
      utensilsPanel.hidden = false;
    } else {
      utensils.replaceChildren();
      utensilsPanel.hidden = true;
    }
  }

  if (instructions) {
    const prepGroups = Array.isArray(recipe.preparationGroups) && recipe.preparationGroups.length ? recipe.preparationGroups : null;
    instructions.innerHTML = prepGroups
      ? prepGroups.map((group) => `
          <li class="instruction-stage"><h3>${escapeHtml(group.name)}</h3>
            <ol class="instruction-stage-steps">${group.instructions.map((step) => `<li>${escapeHtml(step)}</li>`).join('')}</ol>
          </li>`).join('')
      : Array.isArray(recipe.stages)
      ? recipe.stages.map((stage) => `
          <li class="instruction-stage">
            <h3>${stage.name}</h3>
            <ol class="instruction-stage-steps">
              ${stage.instructions.map((step) => `<li>${step}</li>`).join('')}
            </ol>
          </li>
        `).join('')
      : recipe.instructions.map((step) => `<li>${step}</li>`).join('');
  }

  if (tips) {
    tips.innerHTML = recipe.tips.map((tip) => `<li>${escapeHtml(tip)}</li>`).join('');
    if (tipsPanel) tipsPanel.hidden = recipe.tips.length === 0;
  }

  const recipeTags = Array.isArray(recipe.tags) ? recipe.tags : [];
  const relatedRecipes = recipeData
    .filter((item) => item.id !== recipe.id)
    .map((item) => {
      const itemTags = Array.isArray(item.tags) ? item.tags : [];
      return {
        recipe: item,
        sameCategory: item.category === recipe.category,
        sharedTagCount: itemTags.filter((tag) => recipeTags.includes(tag)).length
      };
    })
    .sort(
      (a, b) =>
        Number(b.sameCategory) - Number(a.sameCategory) ||
        b.sharedTagCount - a.sharedTagCount
    )
    .slice(0, 3)
    .map(({ recipe: item }) => item);

  if (related && !document.body.hasAttribute('data-static-recipe-page')) {
    related.innerHTML = relatedRecipes
      .map((item) => {
        const itemTime = getRecipeTimeDisplay(item);

        return `
          <article class="recipe-card">
            <a href="${getRecipePageUrl(item.id)}" class="recipe-card__link" aria-label="Abrir receita de ${item.title}">
              <div class="recipe-card__media">
                <img src="${item.image}" alt="${item.title}" loading="lazy" />
              </div>
              <div class="recipe-card__body">
                <div class="recipe-card__topline">
                  <span class="recipe-card__category">${item.category}</span>
                  ${itemTime ? `<span class="recipe-card__time">${itemTime}</span>` : ''}
                </div>
                <h3>${item.title}</h3>
                <p>${item.description}</p>
                <div class="recipe-card__meta">
                  <span>${item.yield}</span>
                  <span>${item.difficulty}</span>
                  <span class="recipe-card__cta" aria-hidden="true">→</span>
                </div>
              </div>
            </a>
          </article>
        `;
      })
      .join('');
  }
}

function updateRecipeCount() {
  document.querySelectorAll('[data-recipe-count]').forEach((node) => {
    node.textContent = String(recipeData.length);
  });
}

function validateRecipeCatalog(catalog) {
  const errors = [];
  const warnings = [];
  const ids = new Set();

  if (!Array.isArray(catalog) || catalog.length === 0) {
    return { errors: ['O catálogo deve ser uma lista não vazia.'], warnings };
  }

  catalog.forEach((recipe, index) => {
    const location = `Receita ${index + 1}`;

    if (!recipe || typeof recipe !== 'object' || Array.isArray(recipe)) {
      errors.push(`${location}: registro inválido.`);
      return;
    }

    ['id', 'title', 'category', 'description', 'image', 'yield', 'difficulty'].forEach((field) => {
      if (typeof recipe[field] !== 'string' || recipe[field].trim() === '') {
        errors.push(`${location}: campo obrigatório "${field}" ausente ou inválido.`);
      }
    });

    if (recipe.time !== null && recipe.time !== undefined && typeof recipe.time !== 'string') {
      errors.push(`${location}: campo "time" deve ser string, null ou undefined.`);
    }

    if (typeof recipe.id === 'string') {
      if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(recipe.id)) {
        errors.push(`${location}: ID deve usar letras minúsculas, números e hífens.`);
      }
      if (ids.has(recipe.id)) {
        errors.push(`${location}: ID duplicado "${recipe.id}".`);
      }
      ids.add(recipe.id);
    }

    if (!Array.isArray(recipe.keywords) || !Array.isArray(recipe.tags) || !Array.isArray(recipe.tips) ||
        [recipe.keywords, recipe.tags, recipe.tips].some((values) =>
          !Array.isArray(values) || values.some((value) => typeof value !== 'string' || value.trim() === '')
        )) {
      errors.push(`${location}: keywords, tags e tips devem ser listas.`);
    }

    const stages = Array.isArray(recipe.stages) ? recipe.stages : null;
    const ingredients = stages
      ? stages.flatMap((stage) => Array.isArray(stage.ingredients) ? stage.ingredients : [])
      : recipe.ingredients;
    const instructions = stages
      ? stages.flatMap((stage) => Array.isArray(stage.instructions) ? stage.instructions : [])
      : recipe.instructions;
    const utensils = stages
      ? stages.flatMap((stage) => Array.isArray(stage.utensils) ? stage.utensils : [])
      : recipe.utensils;

    if (!Array.isArray(ingredients) || ingredients.length === 0) {
      errors.push(`${location}: ingredientes ausentes ou inválidos.`);
    } else if (ingredients.some((item) => typeof item !== 'string' || item.trim() === '')) {
      errors.push(`${location}: há ingrediente vazio ou inválido.`);
    } else if (ingredients.some((item) => !/\d|a gosto|opcional/i.test(item))) {
      warnings.push(`${location}: confira se todos os ingredientes têm quantidade ou indicação de uso a gosto/opcional.`);
    }

    if (!Array.isArray(instructions) || instructions.length === 0 ||
        instructions.some((item) => typeof item !== 'string' || item.trim() === '')) {
      errors.push(`${location}: modo de preparo ausente ou inválido.`);
    }
    if (!Array.isArray(utensils) || utensils.length === 0 ||
        utensils.some((item) => typeof item !== 'string' || item.trim() === '')) {
      errors.push(`${location}: utensílios ausentes ou inválidos.`);
    }
    if (stages && stages.some((stage) =>
      typeof stage.name !== 'string' || stage.name.trim() === '' ||
      !Array.isArray(stage.ingredients) || stage.ingredients.length === 0 ||
      !Array.isArray(stage.instructions) || stage.instructions.length === 0 ||
      !Array.isArray(stage.utensils)
    )) {
      errors.push(`${location}: etapa sem nome, ingredientes ou instruções válidos.`);
    }
    ['prepTime', 'cookTime', 'totalTime'].forEach((field) => {
      if (recipe[field] !== null && recipe[field] !== undefined &&
          (typeof recipe[field] !== 'string' ||
            !/^P(?=\d|T)(?:\d+Y)?(?:\d+M)?(?:\d+W)?(?:\d+D)?(?:T(?:\d+H)?(?:\d+M)?(?:\d+(?:\.\d+)?S)?)?$/.test(recipe[field]))) {
        warnings.push(`${location}: "${field}" deve usar duração ISO 8601 ou null.`);
      }
    });
  });

  return { errors, warnings };
}

function showRecipeCatalogError() {
  const message = 'Não foi possível carregar as receitas. Verifique sua conexão e tente novamente.';
  const recipeGrid = document.querySelector('[data-recipe-grid="featured"]');
  const recipeTitle = document.querySelector('[data-recipe-name]');
  const errorMessage = document.createElement('p');
  errorMessage.className = 'recipe-search__empty';
  errorMessage.setAttribute('role', 'alert');
  errorMessage.textContent = message;

  if (recipeGrid) {
    recipeGrid.replaceChildren(errorMessage);
  } else if (recipeTitle) {
    if (document.body.hasAttribute('data-static-recipe-page')) {
      document.querySelector('.recipe-summary')?.prepend(errorMessage);
      return;
    }

    recipeTitle.textContent = 'Receita indisponível';
    const description = document.querySelector('[data-recipe-description]');
    if (description) {
      description.textContent = message;
      description.setAttribute('role', 'alert');
    }
  }
}

async function initPage() {
  setupNavigation();
  setupSmoothScroll();

  try {
    const staticRecipeData = document.querySelector('[data-static-recipe-data]');
    let catalog;
    if (staticRecipeData) {
      catalog = [JSON.parse(staticRecipeData.textContent)];
    } else {
      const response = await fetch('data/recipes.json');
      if (!response.ok) {
        throw new Error(`Falha ao carregar o catálogo de receitas (${response.status}).`);
      }
      catalog = await response.json();
    }

    const validation = validateRecipeCatalog(catalog);
    if (validation.errors.length > 0) {
      throw new Error(`Catálogo inválido: ${validation.errors.join(' ')}`);
    }
    validation.warnings.forEach((warning) => console.warn(`[Validação de receitas] ${warning}`));
    recipeData = catalog;
  } catch (error) {
    console.error('Não foi possível inicializar o catálogo de receitas.', error);
    showRecipeCatalogError();
    return;
  }

  updateRecipeCount();

  if (document.querySelector('[data-recipe-grid="featured"]')) {
    initHomePage();
  }

  if (document.querySelector('[data-recipe-image]')) {
    renderRecipePage();
  }

  setupRecipeSearch();
}

document.addEventListener('DOMContentLoaded', initPage, { once: true });
