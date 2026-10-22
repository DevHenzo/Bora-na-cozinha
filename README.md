# Bora na Cozinha!

## Objetivo
Este projeto é o site Bora na Cozinha!, uma landing page moderna para receitas, com foco em estética premium, responsividade, acessibilidade e facilidade de expansão para um futuro backend ou API.

## Tecnologias utilizadas
- HTML5
- CSS3
- JavaScript puro
- SEO básico
- Mobile-first design

## Estrutura de pastas

```text
site-receitas/
├── index.html
├── receita.html
├── receitas/          # Páginas estáticas geradas do catálogo
├── README.md
├── robots.txt
├── sitemap.xml
├── data/
│   └── recipes.json
├── scripts/
│   ├── recipe-admin-server.ps1
│   ├── generate-static-recipes.ps1
│   └── generate-sitemap.ps1
├── css/
│   └── style.css
├── js/
│   └── script.js
└── assets/
    ├── images/
    │   └── utensilios/
    ├── icons/
    └── fonts/
```

## Principais funcionalidades
- Hero section com imagem cinematográfica e efeito visual suave
- Header dinâmico com menu mobile
- Seções de receitas em destaque e rápidas
- Cards com hover simples e elegante
- Página individual de receita com dados em formato estruturado
- Design responsivo para mobile, tablet e desktop
- Acessibilidade básica com foco visível, contrastes e compatibilidade com `prefers-reduced-motion`

## Catálogo de receitas

Os dados ficam em `data/recipes.json`, separados da lógica de interface em `js/script.js`. Os 12 IDs atuais foram preservados; links existentes no formato `receita.html?id=<id>` continuam válidos. Receitas compostas podem agrupar ingredientes, utensílios e instruções em `stages`; receitas simples usam essas listas diretamente no objeto.

Campos usados pelo catálogo:

- `id`, `title`, `category`, `keywords`, `tags`, `description` e `image`
- `ingredients`, `utensils` e `instructions`, ou `stages` com esses campos por etapa
- `time` (texto legado exibido), `prepTime` e `cookTime` (duração ISO 8601 ou `null`), `yield`, `difficulty`, `cuisine`, `tips` e `quick`

Para adicionar receitas, edite o JSON mantendo IDs exclusivos em minúsculas com hífens. O site valida campos obrigatórios, listas, estrutura das etapas e IDs antes de renderizar; falhas estruturais impedem a exibição do catálogo e são informadas no console e na página. Sinais sobre quantidades incomuns são avisos, não bloqueios.

Na home, a lista principal mostra até 12 cartões por vez; **Carregar mais** acrescenta o próximo lote. Busca e categoria são aplicadas ao catálogo completo, não apenas aos cartões visíveis. A lista “Rápidas” também limita sua renderização a 12 cartões; todas as receitas continuam disponíveis na lista principal.

## URLs e SEO

O catálogo JSON é a fonte única dos dados. `scripts/generate-static-recipes.ps1` gera páginas públicas em `receitas/<id>/index.html`, com título, descrição, conteúdo culinário, links relacionados, URL canônica, Open Graph/Twitter e JSON-LD `Recipe` diretamente no HTML inicial. Assim, a indexação e o compartilhamento não dependem da execução de JavaScript. Os arquivos estáticos embutem somente os dados da respectiva receita; a página individual não baixa o catálogo completo para exibir seu conteúdo.

Os links internos apontam para as URLs estáveis `receitas/<id>/`. Endereços antigos `receita.html?id=<id>` continuam compatíveis e redirecionam para a página estática depois que o catálogo é carregado. Essa compatibilidade antiga usa JavaScript; o sitemap lista apenas páginas estáticas.

Depois de alterar o catálogo, gere novamente as páginas, o sitemap e a referência correspondente no robots.txt:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\generate-sitemap.ps1
```

O script usa o endereço do GitHub Pages configurado para este repositório; se o site usar domínio próprio, passe a URL-base publicada:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\generate-sitemap.ps1 -SiteBaseUrl "https://www.seu-dominio.com/"
```

`prepTime`, `cookTime` e `totalTime` só são incluídos no JSON-LD quando existem como durações ISO 8601 válidas no catálogo. O campo textual `time` continua visível, sem ser convertido em uma duração estruturada presumida. Avaliações, autor e outros valores ausentes também não são inventados. Confirme o domínio e a publicação antes de enviar o sitemap ao Google Search Console; o GitHub Pages e os validadores externos não podem ser confirmados por testes locais.

## Imagens dos utensílios
O catálogo `utensilImages`, em `js/script.js`, associa nomes padronizados às imagens WebP locais existentes em `assets/images/utensilios/`. Variações equivalentes são normalizadas durante a renderização; “Panelas” reutiliza a imagem de “Panela” quando não há uma associação específica. Se uma imagem associada não carregar, a interface mantém um espaço neutro no cartão.

## Painel local de receitas

No terminal do VS Code, na pasta do projeto, inicie o painel com:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\recipe-admin-server.ps1
```

Abra `http://127.0.0.1:8765/` no navegador. O servidor aceita conexões somente pelo endereço local, não usa banco de dados e não é ligado ao site público. Preencha o formulário e clique em **Salvar receita**; a imagem WebP será copiada para `assets/images/receitas/`, o catálogo será atualizado e a página individual será gerada. Ingredientes podem ser informados em uma lista simples ou organizados em grupos nomeados; cada grupo precisa ter ao menos um ingrediente. **Dicas do Chef** são opcionais e aceitam uma dica por linha. O tempo é opcional e aceita valores como `40 min`, `1 h 30 min` ou `2 horas`; preparo e cozimento não são presumidos. Imagens acima de 150 KB exibem um aviso. O painel pede utensílios porque esse campo é exigido pela validação atual do catálogo. Se a geração falhar, o cadastro é revertido. Encerre o servidor com `Ctrl+C`.

## Próximos passos possíveis
- Expandir gradualmente o catálogo, mantendo IDs exclusivos e os campos documentados
- Integrar dados vindos de uma API ou serviço de catálogo
- Adicionar edição de receitas no painel local
- Permitir upload de imagens e organização por usuário
- Avaliar uma arquitetura com backend e banco de dados quando o projeto precisar de edição dinâmica

Isso facilita a evolução para um sistema real com banco de dados e painel administrativo.
