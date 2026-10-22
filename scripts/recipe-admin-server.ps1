$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$catalogPath = Join-Path $projectRoot 'data\recipes.json'
$imageDirectory = Join-Path $projectRoot 'assets\images\receitas'
$recipesDirectory = Join-Path $projectRoot 'receitas'
$generatorPath = Join-Path $PSScriptRoot 'generate-static-recipes.ps1'
$port = 8765
$origin = "http://127.0.0.1:$port"
$maxRequestBytes = 20MB

$page = @'
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="robots" content="noindex,nofollow" />
  <title>Painel local de receitas | Bora na Cozinha!</title>
  <style>
    :root { color-scheme: light; --ink:#201d1a; --muted:#665b53; --paper:#fcf9e5; --surface:#fffdfb; --line:#e7ddd2; --accent:#9a532d; --accent-soft:#f5e8dc; --good:#23613b; --bad:#9b2c25; font-family:Inter,"Segoe UI",sans-serif; }
    * { box-sizing:border-box; }
    body { margin:0; background:radial-gradient(ellipse at 90% 0%,#f0e1ce 0,transparent 35%),var(--paper); color:var(--ink); line-height:1.55; }
    main { width:min(900px,calc(100% - 32px)); margin:42px auto 70px; }
    .topline { display:flex; align-items:center; gap:10px; color:var(--accent); font-size:.78rem; font-weight:800; letter-spacing:.12em; text-transform:uppercase; }
    .topline::before { content:""; width:26px; height:2px; background:currentColor; }
    h1 { margin:10px 0 8px; font-family:Georgia,serif; font-size:clamp(2rem,6vw,3.4rem); font-weight:500; letter-spacing:-.04em; line-height:1.12; }
    .intro { max-width:650px; margin:0 0 26px; color:var(--muted); }
    form { padding:clamp(18px,4vw,36px); border:1px solid rgba(87,61,42,.12); border-radius:24px; background:rgba(255,253,251,.94); box-shadow:0 22px 55px rgba(51,38,25,.1); }
    fieldset { min-width:0; margin:0; padding:0; border:0; }
    fieldset + fieldset { margin-top:30px; padding-top:25px; border-top:1px solid var(--line); }
    legend { margin-bottom:16px; font-family:Georgia,serif; font-size:1.35rem; font-weight:600; }
    .grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:17px; }
    .field { min-width:0; }
    .full { grid-column:1/-1; }
    label { display:block; margin-bottom:6px; font-size:.88rem; font-weight:700; }
    .optional { color:var(--muted); font-size:.78rem; font-weight:500; }
    input,select,textarea { width:100%; min-height:46px; padding:10px 12px; border:1px solid #d8cdc2; border-radius:10px; background:#fff; color:var(--ink); font:inherit; outline:none; transition:border-color .18s,box-shadow .18s; }
    textarea { min-height:130px; resize:vertical; }
    input:focus,select:focus,textarea:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(154,83,45,.13); }
    input[readonly] { background:#f6f1eb; color:var(--muted); }
    .hint { display:block; margin-top:5px; color:var(--muted); font-size:.78rem; }
    .filebox { padding:15px; border:1px dashed #c9b39e; border-radius:12px; background:#fcf8f2; }
    .filebox input { min-height:auto; padding:8px 0 0; border:0; background:transparent; }
    .ingredient-groups { display:grid; gap:14px; }
    .ingredient-group { padding:16px; border:1px solid var(--line); border-radius:12px; background:#fcf8f2; }
    .ingredient-group-heading { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:12px; }
    .ingredient-group-heading h3 { margin:0; font-family:Georgia,serif; font-size:1.1rem; }
    .ingredient-group .field + .field { margin-top:12px; }
    .secondary-button { min-height:42px; padding:0 16px; background:var(--accent-soft); color:var(--accent); box-shadow:none; }
    .secondary-button:hover { background:#ecd6c3; }
    .remove-group-button { min-height:36px; padding:0 13px; font-size:.82rem; }
    .manage { margin:26px 0; padding:clamp(18px,4vw,30px); border:1px solid rgba(87,61,42,.12); border-radius:24px; background:rgba(255,253,251,.94); box-shadow:0 22px 55px rgba(51,38,25,.08); }
    .manage h2 { margin:0 0 14px; font-family:Georgia,serif; font-size:1.5rem; }
    .recipe-list { display:grid; gap:10px; }
    .recipe-row { display:flex; align-items:center; justify-content:space-between; gap:16px; padding:12px 14px; border:1px solid var(--line); border-radius:12px; }
    .recipe-row strong { overflow-wrap:anywhere; }
    .recipe-row-actions { display:flex; flex:none; gap:8px; }
    .recipe-row button { min-height:38px; padding:0 15px; font-size:.85rem; }
    .recipe-row .delete-button { background:#fbeae7; color:var(--bad); box-shadow:none; }
    .recipe-row .delete-button:hover { background:#f4d4cf; }
    .list-status { margin:0; color:var(--muted); }
    .status { display:none; margin:18px 0 0; padding:13px 15px; border-radius:10px; white-space:pre-wrap; overflow-wrap:anywhere; }
    .status[data-kind=success] { display:block; background:#e8f3e9; color:var(--good); }
    .status[data-kind=error] { display:block; background:#fbeae7; color:var(--bad); }
    .status[data-kind=info] { display:block; background:#f0ede8; color:var(--muted); }
    .actions { display:flex; align-items:center; justify-content:space-between; gap:18px; margin-top:26px; }
    .privacy { max-width:360px; margin:0; color:var(--muted); font-size:.79rem; }
    button { min-height:50px; padding:0 23px; border:0; border-radius:999px; background:var(--accent); color:white; font:inherit; font-weight:800; box-shadow:0 9px 20px rgba(154,83,45,.2); }
    button:hover { background:#824321; }
    button:disabled { cursor:wait; opacity:.65; }
    @media(max-width:620px) { main { margin-top:26px; } .grid { grid-template-columns:1fr; gap:14px; } .full { grid-column:auto; } .actions { align-items:stretch; flex-direction:column; } button { width:100%; } .recipe-row { align-items:stretch; flex-direction:column; } .recipe-row-actions button { flex:1; } }
  </style>
</head>
<body>
  <main>
    <div class="topline">Bora na Cozinha!</div>
    <h1>Painel administrativo local</h1>
    <p class="intro">Cadastro local: a imagem e os dados ficam neste projeto. O painel não está disponível no site publicado.</p>
    <section class="manage" aria-labelledby="manage-heading">
      <h2 id="manage-heading">Gerenciar receitas</h2>
      <div id="recipe-list" class="recipe-list" aria-live="polite"><p class="list-status">Carregando receitas…</p></div>
    </section>
    <h2 id="form-heading">Nova receita</h2>
    <form id="recipe-form">
      <fieldset>
        <legend>Sobre a receita</legend>
        <div class="grid">
          <div class="field full"><label for="title">Nome da receita *</label><input id="title" name="title" required maxlength="120" autocomplete="off" /><span class="hint">ID/slug preservado: <strong id="slug-preview">—</strong></span><input id="id" name="id" type="hidden" /></div>
          <div class="field"><label for="category">Categoria *</label><input id="category" name="category" list="categories" required maxlength="60" placeholder="Ex.: Sobremesas" /><datalist id="categories"></datalist></div>
          <div class="field"><label for="difficulty">Dificuldade *</label><select id="difficulty" name="difficulty" required><option value="">Selecione</option><option>Fácil</option><option>Média</option><option>Difícil</option></select></div>
          <div class="field full"><label for="description">Descrição *</label><textarea id="description" name="description" required maxlength="300" rows="3" placeholder="Conte em poucas palavras o que torna esta receita especial."></textarea></div>
          <div class="field"><label for="yield">Porções *</label><input id="yield" name="yield" required maxlength="40" placeholder="Ex.: 8 porções" /></div>
        </div>
      </fieldset>
      <fieldset>
        <legend>Ingredientes e preparo</legend>
        <div class="grid">
          <div class="field full"><label for="ingredients">Ingredientes sem grupos <span class="optional">(opcional, um por linha)</span></label><textarea id="ingredients" name="ingredients" placeholder="2 xícaras de farinha&#10;1 colher de fermento"></textarea></div>
          <div class="field full">
            <span class="hint">Use os grupos no lugar da lista simples para separar ingredientes. O nome do grupo aparece como subtítulo, sem checkbox.</span>
            <div id="ingredient-groups" class="ingredient-groups"></div>
            <button id="add-ingredient-group" class="secondary-button" type="button">+ Adicionar grupo de ingredientes</button>
          </div>
          <div class="field full"><label for="utensils">Utensílios * <span class="optional">(um por linha)</span></label><textarea id="utensils" name="utensils" required placeholder="Tigela&#10;Forma"></textarea><span class="hint">Necessário para manter a estrutura atual do catálogo.</span></div>
          <div class="field full"><label for="instructions">Modo de preparo sem grupos <span class="optional">(opcional, um passo por linha)</span></label><textarea id="instructions" name="instructions" placeholder="Misture os ingredientes secos.&#10;Acrescente os líquidos e mexa bem."></textarea></div>
          <div class="field full"><span class="hint">Use os grupos para separar o preparo por partes, como Massa, Recheio e Cobertura.</span><div id="preparation-groups" class="ingredient-groups"></div><button id="add-preparation-group" class="secondary-button" type="button">+ Adicionar grupo de preparo</button></div>
          <div class="field full"><label for="tips">Dicas do Chef <span class="optional">(opcional, uma por linha)</span></label><textarea id="tips" name="tips" placeholder="Não deixe o creme ferver.&#10;Sirva ainda morno."></textarea></div>
        </div>
      </fieldset>
      <fieldset>
        <legend>Tempo e imagem</legend>
        <div class="grid">
          <div class="field"><label for="time">Tempo <span class="optional">(opcional)</span></label><input id="time" name="time" type="text" maxlength="60" placeholder="Ex.: 40 min, 1 h 30 min ou 2 horas" /></div>
          <div class="field"><label for="image">Imagem WebP <span class="optional" id="image-required">*</span></label><div class="filebox"><input id="image" name="image" type="file" accept=".webp,image/webp" required /><span id="image-hint" class="hint">Escolha um arquivo WebP do computador.</span></div></div>
        </div>
      </fieldset>
      <div id="status" class="status" role="status" aria-live="polite"></div>
      <div class="actions"><p class="privacy">A página está vinculada ao servidor local. Mantenha esta janela aberta enquanto salva.</p><div><button id="cancel-edit" class="secondary-button" type="button" hidden>Cancelar edição</button> <button id="save-button" type="submit">Salvar receita</button></div></div>
    </form>
  </main>
  <script>
    const form = document.querySelector('#recipe-form');
    const statusBox = document.querySelector('#status');
    const saveButton = document.querySelector('#save-button');
    const imageInput = document.querySelector('#image');
    const imageHint = document.querySelector('#image-hint');
    const slugField = document.querySelector('#id');
    const slugPreview = document.querySelector('#slug-preview');
    const ingredientGroups = document.querySelector('#ingredient-groups');
    const preparationGroups = document.querySelector('#preparation-groups');
    const recipeList = document.querySelector('#recipe-list');
    const formHeading = document.querySelector('#form-heading');
    const imageRequired = document.querySelector('#image-required');
    let editingRecipeId = null;
    let nextIngredientGroupId = 0;
    let nextPreparationGroupId = 0;

    function slugify(value) {
      return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()
        .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
    }
    document.querySelector('#title').addEventListener('input', (event) => {
      if (!editingRecipeId) slugField.value = slugify(event.target.value);
      slugPreview.textContent = slugField.value || '—';
    });

    async function loadRecipes() {
      recipeList.replaceChildren();
      const response = await fetch('/api/recipes');
      const recipes = await response.json();
      if (!response.ok) throw new Error(recipes.error || 'Não foi possível carregar as receitas.');
      if (!recipes.length) {
        const empty = document.createElement('p');
        empty.className = 'list-status';
        empty.textContent = 'Nenhuma receita cadastrada.';
        recipeList.append(empty);
        return;
      }
      recipes.forEach((recipe) => {
        const row = document.createElement('div');
        row.className = 'recipe-row';
        const title = document.createElement('strong');
        title.textContent = recipe.title;
        const actions = document.createElement('div');
        actions.className = 'recipe-row-actions';
        const editButton = document.createElement('button');
        editButton.type = 'button';
        editButton.textContent = 'Editar';
        editButton.dataset.action = 'edit';
        editButton.dataset.id = recipe.id;
        const deleteButton = document.createElement('button');
        deleteButton.type = 'button';
        deleteButton.className = 'delete-button';
        deleteButton.textContent = 'Excluir';
        deleteButton.dataset.action = 'delete';
        deleteButton.dataset.id = recipe.id;
        actions.append(editButton, deleteButton);
        row.append(title, actions);
        recipeList.append(row);
      });
    }
    loadRecipes().catch((error) => {
      recipeList.textContent = error.message;
      recipeList.className = 'recipe-list status';
      recipeList.dataset.kind = 'error';
    });

    fetch('/api/categories').then((response) => {
      if (!response.ok) throw new Error('Não foi possível carregar as categorias.');
      return response.json();
    }).then((categories) => {
      document.querySelector('#categories').innerHTML = categories
        .map((category) => `<option value="${category.replace(/[&<>"']/g, (character) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[character]))}"></option>`).join('');
    }).catch((error) => showStatus(error.message, 'error'));

    imageInput.addEventListener('change', () => {
      const file = imageInput.files[0];
      if (!file) { imageHint.textContent = 'Escolha um arquivo WebP do computador.'; return; }
      imageHint.textContent = `${file.name} — ${(file.size / 1024).toFixed(1)} KB${file.size > 150 * 1024 ? ' (acima de 150 KB; será salvo mesmo assim)' : ''}`;
    });

    function showStatus(message, kind) {
      statusBox.textContent = message;
      statusBox.dataset.kind = kind;
    }
    function lines(value) {
      return value.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
    }
    function addIngredientGroup() {
      const groupId = nextIngredientGroupId++;
      const group = document.createElement('div');
      group.className = 'ingredient-group';
      group.innerHTML = `
        <div class="ingredient-group-heading">
          <h3>Grupo de ingredientes</h3>
          <button class="secondary-button remove-group-button" type="button">Remover grupo</button>
        </div>
        <div class="field">
          <label for="ingredient-group-name-${groupId}">Nome do grupo *</label>
          <input id="ingredient-group-name-${groupId}" class="ingredient-group-name" required maxlength="80" placeholder="Ex.: Massa" />
        </div>
        <div class="field">
          <label for="ingredient-group-items-${groupId}">Ingredientes * <span class="optional">(um por linha)</span></label>
          <textarea id="ingredient-group-items-${groupId}" class="ingredient-group-items" required placeholder="2 xícaras de farinha&#10;1 colher de fermento"></textarea>
        </div>`;
      group.querySelector('.remove-group-button').addEventListener('click', () => group.remove());
      ingredientGroups.append(group);
    }
    function addPreparationGroup() {
      const groupId = nextPreparationGroupId++;
      const group = document.createElement('div');
      group.className = 'preparation-group ingredient-group';
      group.innerHTML = `
        <div class="ingredient-group-heading">
          <h3>Grupo de preparo</h3>
          <button class="secondary-button remove-group-button" type="button">Remover grupo</button>
        </div>
        <div class="field">
          <label for="preparation-group-name-${groupId}">Nome do grupo *</label>
          <input id="preparation-group-name-${groupId}" class="preparation-group-name" required maxlength="80" placeholder="Ex.: Recheio" />
        </div>
        <div class="field">
          <label for="preparation-group-steps-${groupId}">Etapas * <span class="optional">(uma por linha)</span></label>
          <textarea id="preparation-group-steps-${groupId}" class="preparation-group-steps" required placeholder="Misture os ingredientes.&#10;Leve ao forno."></textarea>
        </div>`;
      group.querySelector('.remove-group-button').addEventListener('click', () => group.remove());
      preparationGroups.append(group);
    }
    function resetEditor() {
      form.reset();
      ingredientGroups.replaceChildren();
      preparationGroups.replaceChildren();
      editingRecipeId = null;
      slugField.value = '';
      slugPreview.textContent = '—';
      formHeading.textContent = 'Nova receita';
      saveButton.textContent = 'Salvar receita';
      document.querySelector('#cancel-edit').hidden = true;
      imageInput.required = true;
      imageRequired.textContent = '*';
      imageHint.textContent = 'Escolha um arquivo WebP do computador.';
    }
    function setLines(field, values) {
      form.elements[field].value = (values || []).join('\n');
    }
    function editRecipe(recipe) {
      resetEditor();
      editingRecipeId = recipe.id;
      slugField.value = recipe.id;
      slugPreview.textContent = recipe.id;
      form.elements.title.value = recipe.title || '';
      form.elements.category.value = recipe.category || '';
      form.elements.description.value = recipe.description || '';
      form.elements.yield.value = recipe.yield || '';
      form.elements.difficulty.value = recipe.difficulty || '';
      form.elements.time.value = recipe.time || '';
      form.elements.tips.value = (recipe.tips || []).join('\n');
      const groups = recipe.ingredientGroups && recipe.ingredientGroups.length
        ? recipe.ingredientGroups
        : (recipe.stages || []).map((stage) => ({ name: stage.name || 'Ingredientes', ingredients: stage.ingredients || [] }));
      if (groups.length) {
        form.elements.ingredients.value = '';
        groups.forEach((source) => {
          addIngredientGroup();
          const group = ingredientGroups.lastElementChild;
          group.querySelector('.ingredient-group-name').value = source.name || '';
          group.querySelector('.ingredient-group-items').value = (source.ingredients || []).join('\n');
        });
      } else {
        setLines('ingredients', recipe.ingredients || []);
      }
      const utensils = recipe.utensils || (recipe.stages || []).flatMap((stage) => stage.utensils || []);
      const instructions = recipe.instructions || (recipe.stages || []).flatMap((stage) => stage.instructions || []);
      setLines('utensils', [...new Set(utensils)]);
      const prepGroups = Array.isArray(recipe.preparationGroups) && recipe.preparationGroups.length
        ? recipe.preparationGroups
        : (recipe.stages || []).map((stage) => ({ name: stage.name, instructions: stage.instructions || [] }));
      if (prepGroups.length) {
        form.elements.instructions.value = '';
        prepGroups.forEach((source) => {
          addPreparationGroup();
          const group = preparationGroups.lastElementChild;
          group.querySelector('.preparation-group-name').value = source.name || '';
          group.querySelector('.preparation-group-steps').value = (source.instructions || []).join('\n');
        });
      } else {
        setLines('instructions', instructions);
      }
      imageInput.required = false;
      imageRequired.textContent = '(opcional; mantenha a imagem atual ou escolha outra)';
      imageHint.textContent = `Imagem atual: ${recipe.image}. Escolha uma nova WebP somente se desejar substituí-la.`;
      formHeading.textContent = `Editar: ${recipe.title}`;
      saveButton.textContent = 'Salvar alterações';
      document.querySelector('#cancel-edit').hidden = false;
      form.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
    recipeList.addEventListener('click', async (event) => {
      const button = event.target.closest('button[data-action]');
      if (!button) return;
      button.disabled = true;
      try {
        const recipeUrl = `/api/recipes/${encodeURIComponent(button.dataset.id)}`;
        if (button.dataset.action === 'edit') {
          const response = await fetch(recipeUrl);
          const recipe = await response.json();
          if (!response.ok) throw new Error(recipe.error || 'Não foi possível carregar a receita.');
          editRecipe(recipe);
          return;
        }
        const response = await fetch(recipeUrl);
        const recipe = await response.json();
        if (!response.ok) throw new Error(recipe.error || 'Não foi possível carregar a receita.');
        if (!window.confirm(`Confirma a exclusão da receita "${recipe.title}"? Esta ação não pode ser desfeita.`)) return;
        const deleteResponse = await fetch(recipeUrl, {
          method: 'DELETE',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ confirmTitle: recipe.title })
        });
        const result = await deleteResponse.json();
        if (!deleteResponse.ok) throw new Error(result.error || 'Não foi possível excluir a receita.');
        showStatus(result.message, 'success');
        if (editingRecipeId === recipe.id) resetEditor();
        await loadRecipes();
      } catch (error) {
        showStatus(error.message || 'Erro inesperado ao gerenciar a receita.', 'error');
      } finally {
        button.disabled = false;
      }
    });
    document.querySelector('#cancel-edit').addEventListener('click', resetEditor);
    document.querySelector('#add-ingredient-group').addEventListener('click', addIngredientGroup);
    document.querySelector('#add-preparation-group').addEventListener('click', addPreparationGroup);
    function readFile(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(String(reader.result).split(',')[1]);
        reader.onerror = () => reject(new Error('Não foi possível ler a imagem selecionada.'));
        reader.readAsDataURL(file);
      });
    }
    form.addEventListener('submit', async (event) => {
      event.preventDefault();
      if (!form.reportValidity()) return;
      const file = imageInput.files[0];
      if (!file && !editingRecipeId) { showStatus('Selecione uma imagem WebP.', 'error'); return; }
      const groupPayload = [...ingredientGroups.querySelectorAll('.ingredient-group')].map((group) => ({
        name: group.querySelector('.ingredient-group-name').value.trim(),
        ingredients: lines(group.querySelector('.ingredient-group-items').value)
      }));
      if (lines(form.elements.ingredients.value).length === 0 &&
          groupPayload.every((group) => group.ingredients.length === 0)) {
        showStatus('Preencha os ingredientes sem grupos ou adicione um grupo com ingredientes.', 'error');
        return;
      }
      if (lines(form.elements.ingredients.value).length > 0 && groupPayload.length > 0) {
        showStatus('Use a lista simples ou os grupos de ingredientes, não os dois formatos juntos.', 'error');
        return;
      }
      const preparationPayload = [...preparationGroups.querySelectorAll('.preparation-group')].map((group) => ({
        name: group.querySelector('.preparation-group-name').value.trim(),
        instructions: lines(group.querySelector('.preparation-group-steps').value)
      }));
      if (lines(form.elements.instructions.value).length === 0 && preparationPayload.length === 0) {
        showStatus('Preencha o modo de preparo sem grupos ou adicione um grupo.', 'error');
        return;
      }
      if (lines(form.elements.instructions.value).length > 0 && preparationPayload.length > 0) {
        showStatus('Use o preparo simples ou os grupos de preparo, não os dois formatos juntos.', 'error');
        return;
      }
      saveButton.disabled = true;
      showStatus('Validando e salvando…', 'info');
      try {
        const payload = {
          id: slugField.value,
          mode: editingRecipeId ? 'edit' : 'create',
          title: form.elements.title.value.trim(),
          category: form.elements.category.value.trim(),
          description: form.elements.description.value.trim(),
          yield: form.elements.yield.value.trim(),
          difficulty: form.elements.difficulty.value,
          time: form.elements.time.value.trim(),
          ingredients: lines(form.elements.ingredients.value),
          ingredientGroups: groupPayload,
          utensils: lines(form.elements.utensils.value),
          instructions: lines(form.elements.instructions.value),
          preparationGroups: preparationPayload,
          tips: lines(form.elements.tips.value),
          imageName: file ? file.name : '',
          imageBase64: file ? await readFile(file) : ''
        };
        const response = await fetch('/api/recipes', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        const result = await response.json();
        if (!response.ok) throw new Error(result.error || `Falha ao salvar (HTTP ${response.status}).`);
        showStatus(`${result.message}${result.warning ? `\n${result.warning}` : ''}`, 'success');
        resetEditor();
        await loadRecipes();
      } catch (error) {
        showStatus(error.message || 'Erro inesperado durante o cadastro.', 'error');
      } finally {
        saveButton.disabled = false;
      }
    });
  </script>
</body>
</html>
'@

function Send-Response {
  param(
    [System.Net.HttpListenerResponse]$Response,
    [int]$StatusCode,
    [string]$ContentType,
    [string]$Content
  )

  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Content)
  $Response.StatusCode = $StatusCode
  $Response.ContentType = $ContentType
  $Response.ContentEncoding = [System.Text.Encoding]::UTF8
  $Response.ContentLength64 = $bytes.Length
  $Response.Headers['Cache-Control'] = 'no-store'
  $Response.Headers['X-Content-Type-Options'] = 'nosniff'
  $Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $Response.Close()
}

function Send-Json {
  param([System.Net.HttpListenerResponse]$Response, [int]$StatusCode, $Value)
  $json = ConvertTo-Json -InputObject $Value -Depth 20 -Compress
  Send-Response $Response $StatusCode 'application/json; charset=utf-8' $json
}

function ConvertTo-Slug {
  param([string]$Value)

  $normalized = $Value.Normalize([System.Text.NormalizationForm]::FormD)
  $withoutMarks = [regex]::Replace($normalized, '\p{Mn}', '')
  return (($withoutMarks.ToLowerInvariant() -replace '[^a-z0-9]+', '-') -replace '(^-+|-+$)', '')
}

function Get-TextLines {
  param($Value, [string]$FieldName)

  if ($Value -isnot [array]) {
    throw "O campo $FieldName deve conter uma lista."
  }
  $lines = @($Value | ForEach-Object {
    if ($_ -isnot [string]) { throw "O campo $FieldName contém um item inválido." }
    $_.Trim()
  } | Where-Object { $_ })
  if ($lines.Count -eq 0) { throw "Preencha ao menos um item em $FieldName." }
  return ,$lines
}

function Get-OptionalTextLines {
  param($Value, [string]$FieldName)

  if ($null -eq $Value) { return ,@() }
  if ($Value -isnot [array]) {
    throw "O campo $FieldName deve conter uma lista."
  }
  $lines = @($Value | ForEach-Object {
    if ($_ -isnot [string]) { throw "O campo $FieldName contém um item inválido." }
    $_.Trim()
  } | Where-Object { $_ })
  return ,$lines
}

function ConvertTo-RecipeTimeData {
  param($Value)

  if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
    return [pscustomobject]@{ Text = ''; TotalMinutes = $null; TotalTime = $null }
  }
  if ($Value -isnot [string]) {
    throw 'O campo tempo deve ser um texto.'
  }
  $text = $Value.Trim()
  $pattern = '^(?:(?<hours>\d+)\s*(?:h|hr|hrs|hora|horas))?(?:\s*(?<minutes>\d+)\s*(?:m|min|mins|minuto|minutos))?$'
  if ($text.Length -gt 60 -or $text -notmatch $pattern -or
      (-not $Matches.hours -and -not $Matches.minutes)) {
    throw 'Informe o tempo como, por exemplo, 40 min, 1 h 30 min ou 2 horas.'
  }
  $hours = if ($Matches.hours) { [long]$Matches.hours } else { 0 }
  $minutes = if ($Matches.minutes) { [long]$Matches.minutes } else { 0 }
  if ($hours -gt ([long]::MaxValue - $minutes) / 60) {
    throw 'O tempo informado é grande demais.'
  }
  $totalMinutes = ($hours * 60) + $minutes
  if ($totalMinutes -lt 1) {
    throw 'O tempo precisa ser maior que zero.'
  }
  return [pscustomobject]@{
    Text = $text
    TotalMinutes = $totalMinutes
    TotalTime = "PT${totalMinutes}M"
  }
}

function Write-AtomicText {
  param([string]$Path, [string]$Text)

  $suffix = [guid]::NewGuid().ToString('N')
  $temporaryPath = "$Path.$suffix.tmp"
  $backupPath = "$Path.$suffix.bak"
  try {
    [System.IO.File]::WriteAllText($temporaryPath, $Text, (New-Object System.Text.UTF8Encoding($false)))
    [System.IO.File]::Replace($temporaryPath, $Path, $backupPath)
    if (Test-Path -LiteralPath $backupPath) {
      Remove-Item -LiteralPath $backupPath -Force
    }
  } finally {
    if (Test-Path -LiteralPath $temporaryPath) {
      Remove-Item -LiteralPath $temporaryPath -Force
    }
  }
}

function Save-Recipe {
  param($Payload)

  $requiredText = @('title', 'category', 'description', 'yield', 'difficulty')
  foreach ($field in $requiredText) {
    if ($Payload.$field -isnot [string] -or [string]::IsNullOrWhiteSpace($Payload.$field)) {
      throw "Preencha o campo obrigatório: $field."
    }
  }
  if ($Payload.title.Trim().Length -gt 120 -or $Payload.description.Trim().Length -gt 300) {
    throw 'O nome aceita até 120 caracteres e a descrição até 300.'
  }
  if ($Payload.difficulty -notin @('Fácil', 'Média', 'Difícil')) {
    throw 'Selecione uma dificuldade válida.'
  }

  $catalogText = [System.IO.File]::ReadAllText($catalogPath, [System.Text.Encoding]::UTF8)
  $catalog = ConvertFrom-Json -InputObject $catalogText
  if ($catalog -isnot [array] -or $catalog.Count -eq 0) { throw 'O catálogo atual não é uma lista válida.' }
  $isEditing = $Payload.mode -eq 'edit'
  $existingRecipes = @()
  if ($isEditing) {
    if ($Payload.id -isnot [string] -or $Payload.id -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
      throw 'O ID da receita em edição é inválido.'
    }
    $id = $Payload.id
    $existingRecipes = @($catalog | Where-Object { $_.id -ceq $id })
    if ($existingRecipes.Count -ne 1) { throw "A receita '$id' não foi encontrada de forma única." }
  } else {
    $id = ConvertTo-Slug $Payload.title.Trim()
    if (-not $id) { throw 'O nome não gerou um ID válido.' }
    if ($Payload.id -ne $id) { throw 'O ID informado não corresponde ao nome da receita.' }
    if (@($catalog | Where-Object { $_.id -eq $id }).Count -gt 0) { throw "Já existe uma receita com o ID ou slug '$id'." }
    if (Test-Path -LiteralPath (Join-Path $recipesDirectory $id)) { throw "A pasta da página '$id' já existe e não será sobrescrita." }
  }
  if (@($catalog | Where-Object { $_.id -ne $id -and $_.title -ceq $Payload.title.Trim() }).Count -gt 0) { throw 'Já existe uma receita com esse nome.' }
  if (@($catalog | Where-Object { $_.id -ne $id -and $_.description -ceq $Payload.description.Trim() }).Count -gt 0) { throw 'Já existe uma receita com essa descrição; use uma descrição própria.' }

  $standaloneIngredients = Get-OptionalTextLines $Payload.ingredients 'ingredientes'
  if ($Payload.ingredientGroups -isnot [array]) {
    throw 'O campo grupos de ingredientes deve conter uma lista.'
  }
  if ($Payload.ingredientGroups.Count -gt 0 -and $standaloneIngredients.Count -gt 0) {
    throw 'Use os ingredientes simples ou os grupos de ingredientes, não os dois formatos juntos.'
  }
  $ingredientGroups = @()
  foreach ($group in $Payload.ingredientGroups) {
    if ($null -eq $group -or $group.name -isnot [string] -or [string]::IsNullOrWhiteSpace($group.name)) {
      throw 'Cada grupo de ingredientes precisa ter um nome.'
    }
    if ($group.name.Trim().Length -gt 80) {
      throw 'O nome de cada grupo aceita até 80 caracteres.'
    }
    $groupIngredients = Get-OptionalTextLines $group.ingredients 'ingredientes do grupo'
    if ($groupIngredients.Count -eq 0) {
      throw "Adicione ao menos um ingrediente ao grupo '$($group.name.Trim())'."
    }
    $ingredientGroups += [ordered]@{
      name = $group.name.Trim()
      ingredients = $groupIngredients
    }
  }
  $ingredients = @()
  $ingredients += $standaloneIngredients
  foreach ($group in $ingredientGroups) {
    $ingredients += $group.ingredients
  }
  if ($ingredients.Count -eq 0) {
    throw 'Preencha os ingredientes sem grupos ou adicione um grupo com ingredientes.'
  }
  $utensils = Get-TextLines $Payload.utensils 'utensílios'
  $standaloneInstructions = Get-OptionalTextLines $Payload.instructions 'modo de preparo'
  if ($Payload.preparationGroups -isnot [array]) {
    throw 'O campo grupos de preparo deve conter uma lista.'
  }
  if ($Payload.preparationGroups.Count -gt 0 -and $standaloneInstructions.Count -gt 0) {
    throw 'Use o preparo simples ou os grupos de preparo, não os dois formatos juntos.'
  }
  $preparationGroups = @()
  foreach ($group in $Payload.preparationGroups) {
    if ($null -eq $group -or $group.name -isnot [string] -or [string]::IsNullOrWhiteSpace($group.name)) {
      throw 'Cada grupo de preparo precisa ter um nome.'
    }
    if ($group.name.Trim().Length -gt 80) { throw 'O nome do grupo de preparo aceita até 80 caracteres.' }
    $steps = Get-OptionalTextLines $group.instructions 'etapas do grupo de preparo'
    if ($steps.Count -eq 0) { throw "Adicione ao menos uma etapa ao grupo '$($group.name.Trim())'." }
    $preparationGroups += [ordered]@{ name = $group.name.Trim(); instructions = $steps }
  }
  $instructions = @($standaloneInstructions)
  foreach ($group in $preparationGroups) { $instructions += $group.instructions }
  if ($instructions.Count -eq 0) { throw 'Informe ao menos uma etapa do modo de preparo.' }
  $tips = Get-OptionalTextLines $Payload.tips 'dicas do chef'
  $preserveExistingTime = $isEditing -and $Payload.time -ceq [string]$existingRecipes[0].time
  $timeData = if ($preserveExistingTime) {
    [pscustomobject]@{
      Text = [string]$existingRecipes[0].time
      TotalMinutes = $null
      TotalTime = $existingRecipes[0].totalTime
    }
  } else {
    ConvertTo-RecipeTimeData $Payload.time
  }

  $hasNewImage = -not [string]::IsNullOrWhiteSpace([string]$Payload.imageBase64)
  $imageBytes = $null
  $imagePath = $null
  if ($hasNewImage) {
    try {
      $imageBytes = [Convert]::FromBase64String([string]$Payload.imageBase64)
    } catch {
      throw 'Não foi possível decodificar a imagem selecionada.'
    }
    if ($imageBytes.Length -lt 12 -or
        [System.Text.Encoding]::ASCII.GetString($imageBytes, 0, 4) -ne 'RIFF' -or
        [System.Text.Encoding]::ASCII.GetString($imageBytes, 8, 4) -ne 'WEBP') {
      throw 'O arquivo selecionado não contém uma imagem WebP válida.'
    }
    $imageFileName = "$id.webp"
    $imagePath = Join-Path $imageDirectory $imageFileName
    $suffix = 2
    while (Test-Path -LiteralPath $imagePath) {
      $imageFileName = "$id-$suffix.webp"
      $imagePath = Join-Path $imageDirectory $imageFileName
      $suffix++
    }
  } elseif (-not $isEditing) {
    throw 'Selecione uma imagem WebP.'
  }

  $title = $Payload.title.Trim()
  $category = $Payload.category.Trim()
  if ($isEditing) {
    $recipe = [ordered]@{}
    foreach ($property in $existingRecipes[0].PSObject.Properties) {
      $recipe[$property.Name] = $property.Value
    }
    $recipe['title'] = $title
    $recipe['category'] = $category
    $recipe['time'] = $timeData.Text
    $recipe['yield'] = $Payload.yield.Trim()
    $recipe['difficulty'] = $Payload.difficulty
    $recipe['description'] = $Payload.description.Trim()
    $recipe['keywords'] = @($title, $category) | Select-Object -Unique
    $recipe['tags'] = @($category)
    if ($hasNewImage) { $recipe['image'] = "assets/images/receitas/$imageFileName" }
    $recipe['ingredients'] = $ingredients
    $recipe['ingredientGroups'] = $ingredientGroups
    $null = $recipe.Remove('stages')
    $recipe['utensils'] = $utensils
    $recipe['instructions'] = $instructions
    $recipe['preparationGroups'] = $preparationGroups
    $recipe['tips'] = $tips
    if (-not $preserveExistingTime) {
      $recipe['quick'] = ($null -ne $timeData.TotalMinutes -and $timeData.TotalMinutes -le 30)
      $recipe['totalTime'] = $timeData.TotalTime
    }
  } else {
    $recipe = [ordered]@{
      id = $id
      title = $title
      category = $category
      time = $timeData.Text
      yield = $Payload.yield.Trim()
      difficulty = $Payload.difficulty
      description = $Payload.description.Trim()
      keywords = @($title, $category) | Select-Object -Unique
      tags = @($category)
      prepTime = $null
      cookTime = $null
      cuisine = $null
      image = "assets/images/receitas/$imageFileName"
      ingredients = $ingredients
      ingredientGroups = $ingredientGroups
      utensils = $utensils
      instructions = $instructions
      preparationGroups = $preparationGroups
      tips = $tips
      quick = ($null -ne $timeData.TotalMinutes -and $timeData.TotalMinutes -le 30)
      totalTime = $timeData.TotalTime
    }
  }

  $updatedCatalog = if ($isEditing) {
    @($catalog | ForEach-Object { if ($_.id -ceq $id) { $recipe } else { $_ } })
  } else {
    @($catalog) + @($recipe)
  }
  $updatedCatalogText = ConvertTo-Json -InputObject $updatedCatalog -Depth 100
  $null = ConvertFrom-Json -InputObject $updatedCatalogText

  $catalogWritten = $false
  $imageWritten = $false
  $generatorStarted = $false
  $imageDirectoryCreated = $false
  $recipeDirectory = Join-Path $recipesDirectory $id
  $originalCatalogText = $catalogText
  try {
    if ($hasNewImage -and -not (Test-Path -LiteralPath $imageDirectory)) {
      New-Item -ItemType Directory -Path $imageDirectory -Force | Out-Null
      $imageDirectoryCreated = $true
    }
    if ($hasNewImage) {
      $imageStream = [System.IO.File]::Open($imagePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
      $imageWritten = $true
      try { $imageStream.Write($imageBytes, 0, $imageBytes.Length) } finally { $imageStream.Dispose() }
    }

    $catalogWritten = $true
    Write-AtomicText $catalogPath $updatedCatalogText

    $generatorStarted = $true
    $generatorOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $generatorPath -RecipeIds $id 2>&1)
    $generatorExitCode = $LASTEXITCODE
    if ($generatorExitCode -ne 0) {
      $details = ($generatorOutput | ForEach-Object { [string]$_ }) -join "`n"
      throw "O gerador de páginas falhou (código $generatorExitCode). $details"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $recipeDirectory 'index.html'))) {
      throw 'O gerador terminou, mas não criou a página da receita.'
    }
  } catch {
    $failure = $_.Exception.Message
    $rollbackErrors = @()
    if ($catalogWritten) {
      try { Write-AtomicText $catalogPath $originalCatalogText } catch { $rollbackErrors += "Falha ao restaurar o catálogo: $($_.Exception.Message)" }
    }
    if ($imageWritten -and (Test-Path -LiteralPath $imagePath)) {
      try { Remove-Item -LiteralPath $imagePath -Force } catch { $rollbackErrors += "Falha ao remover a imagem: $($_.Exception.Message)" }
    }
    if ($generatorStarted -and $isEditing) {
      try {
        $restoreOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $generatorPath -RecipeIds $id 2>&1)
        if ($LASTEXITCODE -ne 0) {
          $rollbackErrors += "Falha ao restaurar a página estática: $(($restoreOutput | ForEach-Object { [string]$_ }) -join "`n")"
        }
      } catch { $rollbackErrors += "Falha ao restaurar a página estática: $($_.Exception.Message)" }
    } elseif ($generatorStarted -and (Test-Path -LiteralPath $recipeDirectory)) {
      try {
        $generatedPage = Join-Path $recipeDirectory 'index.html'
        if (Test-Path -LiteralPath $generatedPage) { Remove-Item -LiteralPath $generatedPage -Force }
        if (@(Get-ChildItem -LiteralPath $recipeDirectory -Force).Count -eq 0) { Remove-Item -LiteralPath $recipeDirectory -Force }
      } catch { $rollbackErrors += "Falha ao remover a página parcial: $($_.Exception.Message)" }
    }
    if ($imageDirectoryCreated -and (Test-Path -LiteralPath $imageDirectory)) {
      try {
        if (@(Get-ChildItem -LiteralPath $imageDirectory -Force).Count -eq 0) { Remove-Item -LiteralPath $imageDirectory -Force }
      } catch { $rollbackErrors += "Falha ao remover a pasta vazia de imagens: $($_.Exception.Message)" }
    }
    if ($rollbackErrors.Count) { throw "$failure`n$($rollbackErrors -join "`n")" }
    throw $failure
  }

  $warning = if ($hasNewImage -and $imageBytes.Length -gt (150 * 1024)) { 'Atenção: a imagem tem mais de 150 KB.' } else { $null }
  return @{
    message = if ($isEditing) { "Receita '$title' atualizada. ID/slug preservado: $id." } else { "Receita '$title' cadastrada. Imagem: $($recipe.image). Página gerada em receitas/$id/." }
    warning = $warning
  }
}

function Get-RecipeById {
  param([string]$Id)

  $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
  $matches = @($catalog | Where-Object { $_.id -ceq $Id })
  if ($matches.Count -ne 1) { throw "A receita '$Id' não foi encontrada de forma única." }
  return $matches[0]
}

function Remove-Recipe {
  param([string]$Id, [string]$ConfirmedTitle)

  if ($Id -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { throw 'O ID da receita é inválido.' }
  $catalogText = [System.IO.File]::ReadAllText($catalogPath, [System.Text.Encoding]::UTF8)
  $catalog = ConvertFrom-Json -InputObject $catalogText
  if ($catalog -isnot [array]) { throw 'O catálogo atual não é uma lista JSON válida.' }
  $selected = @($catalog | Where-Object { $_.id -ceq $Id })
  if ($selected.Count -ne 1) { throw "A receita '$Id' não foi encontrada de forma única." }
  if ($ConfirmedTitle -cne [string]$selected[0].title) {
    throw 'A confirmação não corresponde ao nome atual da receita. Atualize a lista e confirme novamente.'
  }

  $backupDirectory = Join-Path (Split-Path -Parent $catalogPath) 'backups'
  if (-not (Test-Path -LiteralPath $backupDirectory)) {
    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
  }
  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
  $backupPath = Join-Path $backupDirectory "recipes-$timestamp.json"
  $suffix = 2
  while (Test-Path -LiteralPath $backupPath) {
    $backupPath = Join-Path $backupDirectory "recipes-$timestamp-$suffix.json"
    $suffix++
  }
  [System.IO.File]::Copy($catalogPath, $backupPath, $false)

  $remaining = @($catalog | Where-Object { $_.id -cne $Id })
  $updatedCatalogText = ConvertTo-Json -InputObject $remaining -Depth 100
  $null = ConvertFrom-Json -InputObject $updatedCatalogText
  $recipeDirectory = Join-Path $recipesDirectory $Id
  $catalogWritten = $false
  # Preserve the exact static page files until deletion and regeneration succeed.
  $pageBackupDirectory = Join-Path $backupDirectory "page-$Id-$timestamp"
  $pageBackedUp = $false
  if (Test-Path -LiteralPath $recipeDirectory -PathType Container) {
    Copy-Item -LiteralPath $recipeDirectory -Destination $pageBackupDirectory -Recurse -Force -ErrorAction Stop
    $pageBackedUp = $true
  }
  try {
    $catalogWritten = $true
    Write-AtomicText $catalogPath $updatedCatalogText
    if (Test-Path -LiteralPath $recipeDirectory) {
      Remove-Item -LiteralPath $recipeDirectory -Recurse -Force
    }

    $sitemapScript = Join-Path $PSScriptRoot 'generate-sitemap.ps1'
    $generationOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sitemapScript 2>&1)
    $generationExitCode = $LASTEXITCODE
    if ($generationExitCode -ne 0) {
      $details = ($generationOutput | ForEach-Object { [string]$_ }) -join "`n"
      throw "A atualização das páginas e do sitemap falhou (código $generationExitCode). $details"
    }
  } catch {
    $failure = $_.Exception.Message
    $rollbackErrors = @()
    if ($catalogWritten) {
      try { Write-AtomicText $catalogPath $catalogText } catch { $rollbackErrors += "Falha ao restaurar o catálogo: $($_.Exception.Message)" }
    }
    if ($catalogWritten) {
      try {
        $restoreOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'generate-sitemap.ps1') 2>&1)
        if ($LASTEXITCODE -ne 0) {
          $rollbackErrors += "Falha ao restaurar páginas/sitemap: $(($restoreOutput | ForEach-Object { [string]$_ }) -join "`n")"
        }
      } catch { $rollbackErrors += "Falha ao restaurar páginas/sitemap: $($_.Exception.Message)" }
    }
    # Restore the original directory byte-for-byte, even if regeneration failed.
    if ($pageBackedUp) {
      try {
        if (Test-Path -LiteralPath $recipeDirectory) {
          Remove-Item -LiteralPath $recipeDirectory -Recurse -Force -ErrorAction Stop
        }
        Copy-Item -LiteralPath $pageBackupDirectory -Destination $recipeDirectory -Recurse -Force -ErrorAction Stop
      } catch { $rollbackErrors += "Falha ao restaurar a pasta original da receita: $($_.Exception.Message). Backup: $pageBackupDirectory" }
    }
    if ($rollbackErrors.Count) { throw "$failure`n$($rollbackErrors -join "`n")" }
    throw $failure
  }

  $imageWarning = $null
  $imageRelativePath = [string]$selected[0].image
  if ($imageRelativePath -match '^assets/images/receitas/([^/]+)$') {
    $imageReferenced = @($remaining | Where-Object { [string]$_.image -ceq $imageRelativePath }).Count -gt 0
    $imagePath = Join-Path $projectRoot ($imageRelativePath -replace '/', '\')
    $imageRoot = [System.IO.Path]::GetFullPath($imageDirectory).TrimEnd('\') + '\'
    $resolvedImagePath = [System.IO.Path]::GetFullPath($imagePath)
    if (-not $imageReferenced -and $resolvedImagePath.StartsWith($imageRoot, [System.StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedImagePath -PathType Leaf)) {
      try { Remove-Item -LiteralPath $resolvedImagePath -Force }
      catch { $imageWarning = "A receita foi excluída, mas não foi possível remover a imagem local: $($_.Exception.Message)" }
    }
  }
  # Keep the page backup alongside the JSON backup for manual recovery.
  $message = "Receita '$($selected[0].title)' excluída. Backup do catálogo: $backupPath."
  if ($pageBackedUp) { $message += " Backup da página: $pageBackupDirectory." }
  if ($imageWarning) { $message += "`n$imageWarning" }
  return @{ message = $message; backup = $backupPath }
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("$origin/")
try {
  $listener.Start()
} catch {
  Write-Error "Não foi possível iniciar o servidor local em $origin. $_"
  exit 1
}

Write-Host "Painel local disponível em $origin/" -ForegroundColor Green
Write-Host 'Pressione Ctrl+C para encerrar o servidor.' -ForegroundColor DarkGray
try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    try {
      if ($request.RemoteEndPoint.Address.ToString() -ne '127.0.0.1' -or $request.Url.Host -ne '127.0.0.1') {
        Send-Json $response 403 @{ error = 'Este painel aceita apenas conexões locais em 127.0.0.1.' }
        continue
      }
      if ($request.HttpMethod -eq 'GET' -and $request.Url.AbsolutePath -eq '/') {
        Send-Response $response 200 'text/html; charset=utf-8' $page
        continue
      }
      if ($request.HttpMethod -eq 'GET' -and $request.Url.AbsolutePath -eq '/api/categories') {
        $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
        $categories = @($catalog.category | Where-Object { $_ } | Sort-Object -Unique)
        Send-Json $response 200 $categories
        continue
      }
      if ($request.HttpMethod -eq 'GET' -and $request.Url.AbsolutePath -eq '/api/recipes') {
        $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json
        $summaries = @($catalog | ForEach-Object { @{ id = $_.id; title = $_.title } })
        Send-Json $response 200 $summaries
        continue
      }
      if ($request.HttpMethod -eq 'GET' -and $request.Url.AbsolutePath -match '^/api/recipes/([a-z0-9]+(?:-[a-z0-9]+)*)$') {
        $recipe = Get-RecipeById $Matches[1]
        Send-Json $response 200 $recipe
        continue
      }
      if ($request.HttpMethod -eq 'POST' -and $request.Url.AbsolutePath -eq '/api/recipes') {
        if ($request.Headers['Origin'] -ne $origin) {
          Send-Json $response 403 @{ error = 'Origem da solicitação não permitida.' }
          continue
        }
        if ($request.ContentLength64 -lt 1 -or $request.ContentLength64 -gt $maxRequestBytes) {
          Send-Json $response 413 @{ error = 'A solicitação está vazia ou excede o limite local de 20 MB.' }
          continue
        }
        $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
        try { $body = $reader.ReadToEnd() } finally { $reader.Dispose() }
        $payload = ConvertFrom-Json -InputObject $body
        $result = Save-Recipe $payload
        Send-Json $response 200 $result
        continue
      }
      if ($request.HttpMethod -eq 'DELETE' -and $request.Url.AbsolutePath -match '^/api/recipes/([a-z0-9]+(?:-[a-z0-9]+)*)$') {
        if ($request.Headers['Origin'] -ne $origin) {
          Send-Json $response 403 @{ error = 'Origem da solicitação não permitida.' }
          continue
        }
        if ($request.ContentLength64 -lt 1 -or $request.ContentLength64 -gt 4096) {
          Send-Json $response 413 @{ error = 'A confirmação da exclusão está vazia ou é inválida.' }
          continue
        }
        $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
        try { $body = $reader.ReadToEnd() } finally { $reader.Dispose() }
        $payload = ConvertFrom-Json -InputObject $body
        $result = Remove-Recipe $Matches[1] ([string]$payload.confirmTitle)
        Send-Json $response 200 $result
        continue
      }
      Send-Json $response 404 @{ error = 'Rota local não encontrada.' }
    } catch {
      if (-not $response.OutputStream.CanWrite) { continue }
      Send-Json $response 400 @{ error = $_.Exception.Message }
    }
  }
} finally {
  if ($listener.IsListening) { $listener.Stop() }
  $listener.Close()
}
