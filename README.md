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
├── README.md
├── css/
│   └── style.css
├── js/
│   └── script.js
└── assets/
    ├── images/
    ├── icons/
    └── fonts/
```

## Como abrir o projeto
1. Faça o download ou clone este projeto.
2. Abra a pasta do projeto no navegador.
3. Você pode abrir o arquivo `index.html` diretamente ou iniciar um servidor local, por exemplo:

```bash
python -m http.server 8000
```

Em seguida, acesse:

```text
http://localhost:8000
```

## Principais funcionalidades
- Hero section com imagem cinematográfica e efeito visual suave
- Header dinâmico com menu mobile
- Seções de receitas em destaque e rápidas
- Cards com hover simples e elegante
- Página individual de receita com dados em formato estruturado
- Design responsivo para mobile, tablet e desktop
- Acessibilidade básica com foco visível, contrastes e compatibilidade com `prefers-reduced-motion`

## Como adicionar imagens
O projeto usa imagens temporárias de URLs externas para simular o visual final. Para substituir por imagens reais:

1. Salve as imagens na pasta `assets/images/`
2. Ajuste os caminhos nos arquivos `index.html` e `receita.html`
3. Prefira proporções:
   - Hero: 16:9, resolução alta
   - Cards: 4:3 ou 1:1
   - Receita: imagem principal em proporção forte, com bela luz e composição

Exemplos de nomes:
- `hero-receita.jpg`
- `card-massa.jpg`
- `card-frango.jpg`
- `receita-principal.jpg`

## Próximos passos possíveis
- Integrar dados vindos de uma API JSON
- Adicionar filtro por categoria e busca
- Criar painel administrativo para cadastro e edição de receitas
- Permitir upload de imagens e organização por usuário
- Expandir para uma arquitetura com backend e banco de dados

## Observações de arquitetura
Os dados das receitas estão em `js/script.js` como uma estrutura estática para facilitar a futura troca por dados dinâmicos de API. A página individual de receita já foi preparada para suportar facilmente a lógica por `id` na URL, por exemplo:

```text
receita.html?id=massa-cremosa-parmesao
```

Isso facilita a evolução para um sistema real com banco de dados e painel administrativo.
