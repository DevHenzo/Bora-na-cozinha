const recipeData = [
  {
    id: 'bolo-de-cenoura-com-cobertura-de-chocolate',
    title: 'Bolo de cenoura com cobertura de chocolate',
    category: 'Bolos',
    time: '60 min',
    yield: '10 fatias',
    difficulty: 'Fácil',
    description: 'Bolo fofinho de cenoura com massa macia e cobertura de chocolate para um sabor clássico e irresistível.',
    image: 'https://images.pexels.com/photos/37711037/pexels-photo-37711037.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '3 cenouras médias raladas',
      '4 ovos',
      '1 xícara de óleo',
      '2 xícaras de açúcar',
      '2 xícaras de farinha de trigo',
      '1 colher de sopa de fermento em pó',
      '1 xícara de chocolate em pó para cobertura',
      '1/2 xícara de leite',
      '2 colheres de sopa de manteiga'
    ],
    instructions: [
      'Bata os ovos com o açúcar até ficar bem cremoso.',
      'Misture o óleo e a cenoura ralada.',
      'Adicione a farinha e o fermento e mexa até incorporar.',
      'Despeje em uma forma untada e asse até dourar.',
      'Para a cobertura, aqueça o chocolate em pó, leite e manteiga até formar um creme.',
      'Espalhe a cobertura sobre o bolo frio e sirva.'
    ],
    tips: [
      'A cenoura deve estar bem raspada para uma massa mais cremosa.',
      'Deixe o bolo esfriar antes de cobrir para a cobertura não derreter demais.'
    ],
    quick: false
  },
  {
    id: 'pudim-de-leite-condensado',
    title: 'Pudim de leite condensado',
    category: 'Sobremesas',
    time: '50 min',
    yield: '8 porções',
    difficulty: 'Fácil',
    description: 'Pudim cremoso e delicado com calda caramelizada, clássico e sempre bem aceito.',
    image: 'https://images.pexels.com/photos/34234275/pexels-photo-34234275.png?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '1 lata de leite condensado',
      '1 lata de leite comum',
      '3 ovos',
      '1 xícara de açúcar para a calda',
      '1/2 xícara de água',
      '1 pitada de sal'
    ],
    instructions: [
      'Caramele a forma com o açúcar e reserve.',
      'Bata no liquidificador o leite condensado, o leite e os ovos.',
      'Despeje a mistura na forma caramelizada.',
      'Asse em banho-maria até firmar.',
      'Espere esfriar e desenforme antes de servir.'
    ],
    tips: [
      'O banho-maria ajuda a manter a textura cremosa.',
      'Deixe o pudim gelar por algumas horas antes de servir para melhor textura.'
    ],
    quick: false
  },
  {
    id: 'lasanha-a-bolonhesa',
    title: 'Lasanha à bolonhesa',
    category: 'Massas',
    time: '75 min',
    yield: '6 porções',
    difficulty: 'Média',
    description: 'Camadas de massa com molho bolonhesa, queijo e molho bechamel, muito saborosa e reconfortante.',
    image: 'https://images.pexels.com/photos/31119077/pexels-photo-31119077.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '500 g de massa para lasanha',
      '500 g de carne moída',
      '1 cebola picada',
      '2 dentes de alho picados',
      '1 lata de tomate pelado',
      '2 xícaras de molho de tomate',
      '200 g de queijo mozzarella',
      '2 colheres de manteiga',
      '2 colheres de farinha',
      '2 xícaras de leite'
    ],
    instructions: [
      'Refogue a cebola e o alho, depois adicione a carne moída até dourar.',
      'Junte o tomate e cozinhe até engrossar.',
      'Prepare o molho branco com manteiga, farinha e leite.',
      'Monte camadas de massa, molho bolonhesa, molho branco e queijo.',
      'Leve ao forno até gratinar e sirva em seguida.'
    ],
    tips: [
      'Reserve um pouco de molho de tomate para cobrir a última camada.',
      'A lasanha fica ainda melhor quando descansa alguns minutos antes de servir.'
    ],
    quick: false
  },
  {
    id: 'strogonoff-de-frango',
    title: 'Strogonoff de frango',
    category: 'Carnes',
    time: '40 min',
    yield: '4 porções',
    difficulty: 'Fácil',
    description: 'Frango em molho cremoso de tomate e creme de leite, perfeito para acompanhar arroz e batata.',
    image: 'https://images.pexels.com/photos/30700761/pexels-photo-30700761.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '500 g de peito de frango em tiras',
      '1 cebola picada',
      '2 colheres de manteiga',
      '1 colher de sopa de mostarda',
      '1 xícara de molho de tomate',
      '1 caixa de creme de leite',
      '1 pitada de sal',
      'Pimenta a gosto'
    ],
    instructions: [
      'Refogue a cebola em manteiga até murchar.',
      'Adicione o frango e cozinhe até ficar dourado.',
      'Misture a mostarda e o molho de tomate.',
      'Abaixe o fogo e adicione o creme de leite.',
      'Ajuste o sal e a pimenta e sirva em seguida.'
    ],
    tips: [
      'Não deixe o creme de leite ferver demais para não talhar.',
      'Sirva com arroz branco ou batata palha.'
    ],
    quick: true
  },
  {
    id: 'brownie-de-chocolate',
    title: 'Brownie de chocolate',
    category: 'Sobremesas',
    time: '40 min',
    yield: '8 fatias',
    difficulty: 'Fácil',
    description: 'Brownie úmido, com casca crocante por fora e centro macio, ideal para qualquer momento.',
    image: 'https://images.pexels.com/photos/17488699/pexels-photo-17488699.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '200 g de chocolate amargo',
      '100 g de manteiga',
      '2 ovos',
      '1/2 xícara de açúcar mascavo',
      '1/2 xícara de açúcar refinado',
      '1/2 xícara de farinha de trigo',
      '1 colher de sopa de cacau em pó'
    ],
    instructions: [
      'Derreta o chocolate com a manteiga em banho-maria.',
      'Bata os ovos com os açúcares até clarear.',
      'Misture o chocolate derretido aos ovos.',
      'Adicione a farinha e o cacau e incorpore delicadamente.',
      'Asse em forma untada até o centro ficar macio.'
    ],
    tips: [
      'Evite assar demais para manter a textura fudgy.',
      'Sirva com uma bola de sorvete para um toque especial.'
    ],
    quick: false
  },
  {
    id: 'bolo-de-chocolate',
    title: 'Bolo de chocolate',
    category: 'Bolos',
    time: '55 min',
    yield: '12 fatias',
    difficulty: 'Média',
    description: 'Bolo de chocolate macio e aromático, perfeito para aniversários e sobremesas em família.',
    image: 'https://images.pexels.com/photos/29538417/pexels-photo-29538417.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '2 xícaras de farinha de trigo',
      '1 xícara de açúcar',
      '1/2 xícara de chocolate em pó',
      '1 ovo',
      '1 xícara de leite',
      '1/2 xícara de óleo',
      '1 colher de sopa de fermento em pó',
      '1 pitada de sal'
    ],
    instructions: [
      'Misture os ingredientes secos em uma tigela.',
      'Adicione os ingredientes líquidos e bata bem até ficar homogêneo.',
      'Coloque em uma forma untada e leve ao forno.',
      'Asse até o centro firmar e dourar levemente.',
      'Espere esfriar antes de desenformar.'
    ],
    tips: [
      'Use cacau de boa qualidade para um sabor mais intenso.',
      'Para um bolo mais úmido, use leite integral.'
    ],
    quick: false
  },
  {
    id: 'farofa',
    title: 'Farofa',
    category: 'Acompanhamentos',
    time: '25 min',
    yield: '6 porções',
    difficulty: 'Fácil',
    description: 'Farofa dourada de mandioca com bacon, cebola e ovos, um acompanhamento brasileiro crocante e saboroso.',
    image: 'https://images.pexels.com/photos/16976659/pexels-photo-16976659.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '250 g de farinha de mandioca torrada',
      '120 g de bacon em cubos',
      '1 cebola picada',
      '2 colheres de sopa de manteiga',
      '2 ovos',
      'Sal e cheiro-verde a gosto'
    ],
    instructions: [
      'Frite o bacon em uma frigideira grande até dourar.',
      'Junte a manteiga e a cebola e refogue até ficar macia.',
      'Acrescente os ovos e mexa até cozinharem.',
      'Adicione a farinha aos poucos, mexendo até ficar dourada e crocante.',
      'Tempere com sal, finalize com cheiro-verde e sirva.'
    ],
    tips: [
      'Adicione a farinha aos poucos para controlar a textura e evitar que a farofa fique seca.',
      'Para uma versão vegetariana, retire o bacon e doure a cebola na manteiga.'
    ],
    quick: true
  },
  {
    id: 'torta-de-frango',
    title: 'Torta de frango',
    category: 'Carnes',
    time: '70 min',
    yield: '8 fatias',
    difficulty: 'Média',
    description: 'Torta crocante por fora e cremosa por dentro, com recheio de frango bem temperado.',
    image: 'https://images.pexels.com/photos/39070762/pexels-photo-39070762.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '1 massa para torta',
      '500 g de frango cozido e desfiado',
      '1 cebola picada',
      '2 colheres de manteiga',
      '1 colher de sopa de farinha',
      '1 xícara de caldo',
      '1/2 xícara de creme de leite',
      'Sal e pimenta a gosto'
    ],
    instructions: [
      'Refogue a cebola e adicione o frango desfiado.',
      'Misture a farinha e o caldo para engrossar o recheio.',
      'Finalize com creme de leite e tempere.',
      'Coloque o recheio sobre uma base de massa.',
      'Cubra com a massa e asse até dourar.'
    ],
    tips: [
      'Use massa pronta para agilizar o preparo.',
      'A torta fica melhor se descansar alguns minutos antes de servir.'
    ],
    quick: false
  },
  {
    id: 'bolo-de-fuba',
    title: 'Bolo de fubá',
    category: 'Bolos',
    time: '45 min',
    yield: '10 fatias',
    difficulty: 'Fácil',
    description: 'Bolo de fubá tradicional, macio e com leve sabor de milho bem equilibrado.',
    image: 'https://images.pexels.com/photos/27135309/pexels-photo-27135309.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '1 xícara de fubá',
      '1 xícara de farinha de trigo',
      '1 xícara de açúcar',
      '1 colher de sopa de fermento',
      '2 ovos',
      '1 xícara de leite',
      '1/2 xícara de óleo',
      '1 pitada de sal'
    ],
    instructions: [
      'Misture os ingredientes secos em uma tigela.',
      'Junte os ovos, o leite e o óleo até incorporar bem.',
      'Despeje em forma untada.',
      'Asse até ficar dourado e firme.',
      'Espere esfriar antes de cortar.'
    ],
    tips: [
      'A massa fica mais úmida se você bater pouco.',
      'Sirva com café ou chá para combinar bem.'
    ],
    quick: true
  },
  {
    id: 'mousse-de-maracuja',
    title: 'Mousse de maracujá',
    category: 'Sobremesas',
    time: '15 min (+ geladeira)',
    yield: '6 porções',
    difficulty: 'Fácil',
    description: 'Mousse cremosa de maracujá com sabor tropical e toque cítrico, finalizada com polpa fresca da fruta.',
    image: 'https://images.pexels.com/photos/24247238/pexels-photo-24247238.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '1 lata de leite condensado',
      '1 caixa de creme de leite',
      '3/4 de xícara de suco concentrado de maracujá',
      'Polpa de 1 maracujá para finalizar'
    ],
    instructions: [
      'Bata o leite condensado, o creme de leite e o suco de maracujá no liquidificador até obter um creme homogêneo.',
      'Distribua a mousse em taças ou em um recipiente.',
      'Leve à geladeira por pelo menos 3 horas, até firmar.',
      'Finalize com a polpa de maracujá antes de servir.'
    ],
    tips: [
      'Acrescente o suco aos poucos e prove para ajustar o equilíbrio entre doce e cítrico.',
      'Mantenha a mousse refrigerada até o momento de servir.'
    ],
    quick: true
  },
  {
    id: 'feijoada',
    title: 'Feijoada',
    category: 'Brasileira',
    time: '3 h (+ demolho)',
    yield: '8 porções',
    difficulty: 'Média',
    description: 'Feijoada brasileira feita com feijão-preto, carnes suínas e temperos, cozida lentamente até ficar encorpada.',
    image: 'https://images.pexels.com/photos/34234280/pexels-photo-34234280.png?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '500 g de feijão-preto, deixado de molho',
      '300 g de carne-seca dessalgada em cubos',
      '300 g de costelinha suína dessalgada',
      '200 g de paio em rodelas',
      '200 g de linguiça calabresa em rodelas',
      '150 g de bacon em cubos',
      '1 cebola grande picada',
      '4 dentes de alho picados',
      '2 folhas de louro',
      'Água, sal e pimenta-do-reino a gosto'
    ],
    instructions: [
      'Deixe o feijão de molho por pelo menos 8 horas. Dessalgue as carnes com antecedência, mantendo-as refrigeradas em água e trocando a água algumas vezes.',
      'Escorra o feijão e coloque-o em uma panela grande com a carne-seca, a costelinha, o louro e água suficiente para cobrir.',
      'Cozinhe até o feijão e as carnes começarem a ficar macios; se usar panela de pressão, siga as orientações de segurança do fabricante.',
      'Em outra panela, doure o bacon, o paio e a calabresa. Junte a cebola e o alho e refogue até ficarem macios.',
      'Misture o refogado à panela do feijão e cozinhe sem pressão até o caldo encorpar e todos os ingredientes ficarem macios.',
      'Ajuste o sal e a pimenta e sirva quente.'
    ],
    tips: [
      'Dessalgue as carnes na geladeira e troque a água algumas vezes para controlar o sal.',
      'Sirva com arroz branco, couve refogada, farofa e laranja.'
    ],
    quick: false
  },
  {
    id: 'pao-de-queijo',
    title: 'Pão de queijo',
    category: 'Lanches',
    time: '45 min',
    yield: '25 unidades',
    difficulty: 'Média',
    description: 'Pão de queijo mineiro com casquinha dourada, interior macio e queijo meia-cura em cada mordida.',
    image: 'https://images.pexels.com/photos/20450299/pexels-photo-20450299.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ingredients: [
      '500 g de polvilho doce',
      '250 ml de leite',
      '100 ml de óleo',
      '1 colher de chá de sal',
      '2 ovos',
      '250 g de queijo meia-cura ralado'
    ],
    instructions: [
      'Aqueça o leite, o óleo e o sal até começarem a ferver.',
      'Coloque o polvilho em uma tigela e despeje a mistura quente, mexendo para escaldar. Deixe amornar.',
      'Acrescente os ovos, um de cada vez, misturando bem.',
      'Junte o queijo ralado e misture até formar uma massa homogênea.',
      'Modele bolinhas, disponha em uma assadeira e asse em forno preaquecido a 180 °C por cerca de 25 minutos, até crescer e dourar.'
    ],
    tips: [
      'Unte levemente as mãos com óleo para modelar as bolinhas sem grudar.',
      'Congele as bolinhas cruas na assadeira e depois armazene em um saco bem fechado.'
    ],
    quick: false
  }
];

function renderRecipeCards(containerSelector, filterCallback = () => true) {
  const container = document.querySelector(containerSelector);

  if (!container) {
    return;
  }

  const filtered = recipeData.filter(filterCallback);

  container.innerHTML = filtered
    .map(
      (recipe) => `
        <article class="recipe-card" aria-label="${recipe.title}">
          <a href="receita.html?id=${recipe.id}" class="recipe-card__link" aria-label="Abrir receita de ${recipe.title}">
            <div class="recipe-card__media">
              <img src="${recipe.image}" alt="${recipe.title}" loading="lazy" />
            </div>
            <div class="recipe-card__body">
              <div class="recipe-card__topline">
                <span class="recipe-card__category">${recipe.category}</span>
                <span class="recipe-card__time">${recipe.time}</span>
              </div>
              <h3>${recipe.title}</h3>
              <p>${recipe.description}</p>
              <div class="recipe-card__meta">
                <span>${recipe.difficulty}</span>
                <span class="recipe-card__cta" aria-hidden="true">→</span>
              </div>
            </div>
          </a>
        </article>
      `
    )
    .join('');
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
  renderRecipeCards('[data-recipe-grid="featured"]', () => true);
  renderRecipeCards('[data-recipe-grid="quick"]', (recipe) => recipe.quick === true);
}

function renderRecipePage() {
  const recipeId = new URLSearchParams(window.location.search).get('id') || recipeData[0].id;
  const recipe = recipeData.find((item) => item.id === recipeId) || recipeData[0];

  const image = document.querySelector('[data-recipe-image]');
  const title = document.querySelector('[data-recipe-name]');
  const category = document.querySelector('[data-recipe-category]');
  const description = document.querySelector('[data-recipe-description]');
  const time = document.querySelector('[data-recipe-time]');
  const yieldField = document.querySelector('[data-recipe-yield]');
  const difficulty = document.querySelector('[data-recipe-difficulty]');
  const breadcrumb = document.querySelector('[data-breadcrumb-current]');
  const ingredients = document.querySelector('[data-ingredients]');
  const instructions = document.querySelector('[data-instructions]');
  const tips = document.querySelector('[data-tips]');
  const related = document.querySelector('[data-related-recipes]');

  if (!recipe) {
    return;
  }

  document.title = `${recipe.title} | Bora na Cozinha!`;
  if (image) image.src = recipe.image;
  if (image) image.alt = recipe.title;
  if (title) title.textContent = recipe.title;
  if (category) category.textContent = recipe.category;
  if (description) description.textContent = recipe.description;
  if (time) time.textContent = recipe.time;
  if (yieldField) yieldField.textContent = recipe.yield;
  if (difficulty) difficulty.textContent = recipe.difficulty;
  if (breadcrumb) breadcrumb.textContent = recipe.title;

  if (ingredients) {
    ingredients.innerHTML = recipe.ingredients
      .map((item) => `<li><label class="ingredient-item"><input type="checkbox" /><span>${item}</span></label></li>`)
      .join('');

    const progress = document.querySelector('[data-ingredient-progress]');
    const progressLabel = document.querySelector('[data-ingredient-progress-label]');
    const progressFill = document.querySelector('[data-ingredient-progress-fill]');
    const completionMark = document.querySelector('[data-ingredient-complete]');
    const updateIngredientProgress = () => {
      const checkedCount = ingredients.querySelectorAll('input[type="checkbox"]:checked').length;
      const totalIngredients = recipe.ingredients.length;
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

  if (instructions) {
    instructions.innerHTML = recipe.instructions.map((step) => `<li>${step}</li>`).join('');
  }

  if (tips) {
    tips.innerHTML = recipe.tips.map((tip) => `<li>${tip}</li>`).join('');
  }

  const relatedRecipes = recipeData.filter((item) => item.id !== recipe.id).slice(0, 3);

  if (related) {
    related.innerHTML = relatedRecipes
      .map(
        (item) => `
          <article class="recipe-card">
            <a href="receita.html?id=${item.id}" class="recipe-card__link" aria-label="Abrir receita de ${item.title}">
              <div class="recipe-card__media">
                <img src="${item.image}" alt="${item.title}" loading="lazy" />
              </div>
              <div class="recipe-card__body">
                <div class="recipe-card__topline">
                  <span class="recipe-card__category">${item.category}</span>
                  <span class="recipe-card__time">${item.time}</span>
                </div>
                <h3>${item.title}</h3>
                <p>${item.description}</p>
                <div class="recipe-card__meta">
                  <span>${item.difficulty}</span>
                  <span class="recipe-card__cta" aria-hidden="true">→</span>
                </div>
              </div>
            </a>
          </article>
        `
      )
      .join('');
  }
}

function updateRecipeCount() {
  const countNode = document.querySelector('[data-recipe-count]');

  if (countNode) {
    countNode.textContent = String(recipeData.length);
  }
}

function initPage() {
  setupNavigation();
  setupSmoothScroll();
  updateRecipeCount();

  if (document.querySelector('[data-recipe-grid="featured"]')) {
    initHomePage();
  }

  if (document.querySelector('[data-recipe-image]')) {
    renderRecipePage();
  }
}

document.addEventListener('DOMContentLoaded', initPage);
