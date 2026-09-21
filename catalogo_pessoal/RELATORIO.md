# Relatório do Trabalho Final
## Desenvolvimento Mobile I — Catálogo Pessoal em Flutter

**Estudante:** Mateus Dayson de Oliveira  
**Matrícula:** 0031595  
**Turma:** ADS – Turma de Quarta 2025/2026  
**Aplicativo:** Catálogo Pessoal  
**Semestre:** 2º Semestre / 2026  

---

## 1. Identificação e Resumo

### Domínio e Problema
O **Catálogo Pessoal** é uma aplicação desenvolvida em Flutter destinada a usuários e leitores que necessitam registrar, organizar e acompanhar o progresso de itens do seu acervo (livros, artigos e referências de estudo). O sistema resolve a desorganização de anotações dispersas, fornecendo uma interface intuitiva para cadastro, classificação por categorias, acompanhamento de status (*Quero Conhecer*, *Em Andamento*, *Concluído*) e destaque de itens favoritos.

### Fluxo Principal
O fluxo da aplicação se inicia na tela principal (`ListaPage`), onde a coleção de itens é exibida em uma grade/lista dinâmica. Ao tocar em um cartão (`ItemCard`), o usuário é direcionado à tela de visualização detalhada (`DetalhePage`). A partir do botão de ação flutuante (FAB) na lista ou do botão "Editar" no detalhe, a tela de formulário reutilizável (`FormularioPage`) é aberta. Ao submeter com dados válidos, o formulário retorna um objeto tipado `ItemCatalogo` à tela de origem via `Navigator.pop()`, atualizando o estado local em memória e apresentando uma confirmação visual via `SnackBar`.

### Escopo do M1
No escopo do **M1**, foi implementado o fluxo completo em memória local com validações síncronas de formulário, prevenção contra múltiplos envios, layout adaptativo sem overflow para telas estreitas e amplas, acessibilidade básica e suíte de testes automatizados de unidade e widget. Recursos como autenticação de usuário, banco de dados remoto/local e sincronização em nuvem pertencem ao escopo futuro de **Mobile II**.

---

## 2. Repositório, Versão e Execução

- **Repositório:** `https://github.com/olivdmt/Mobile.git` (subpasta `catalogo_pessoal`)
- **Tag / Commit Hash:** `m1-entrega`
- **Ambiente:** Flutter 3.47.0 • Dart 3.13.0 • Material 3
- **Artefato Android Gerado:** `build/app/outputs/flutter-apk/app-release.apk` (47.5 MB)

### Como Reproduzir
1. Clonar o repositório Git e acessar a pasta do projeto:
   ```bash
   git clone https://github.com/olivdmt/Mobile.git
   cd Mobile/catalogo_pessoal
   ```
2. Obter as dependências:
   ```bash
   flutter pub get
   ```
3. Executar os testes automatizados:
   ```bash
   flutter test
   ```
4. Executar a análise estática:
   ```bash
   flutter analyze
   ```
5. Executar o aplicativo no emulador ou dispositivo conectado:
   ```bash
   flutter run
   ```
6. Gerar o APK de Release para Android:
   ```bash
   flutter build apk
   ```

*O projeto opera de forma autônoma sem requerer credenciais externas ou chaves de API nesta etapa.*

---

## 3. Matriz de Requisitos (13 Critérios da Rubrica)

| Nº | Requisito da Rubrica | Evidência no Documento | Arquivo / Classe no Projeto |
|---|---|---|---|
| **1** | Identificação, objetivo e fluxo | Seção 1 deste relatório | `RELATORIO.md` e `README.md` |
| **2** | Repositório, versão e instruções | Seção 2 deste relatório | `README.md` |
| **3** | Execução e artefato Android | Seção 5 (Saída de build) | `build/app/outputs/flutter-apk/app-release.apk` |
| **4** | Duas ou mais telas e navegação | Evidência B e Seção 5 | `lib/screens/lista_page.dart`, `detalhe_page.dart` |
| **5** | Coleção dinâmica e estado vazio | Evidência A | `lib/widgets/estado_vazio.dart`, `lib/screens/lista_page.dart` |
| **6** | Detalhe do item selecionado | Evidência B | `lib/screens/detalhe_page.dart` |
| **7** | Formulário e validação | Evidência C | `lib/screens/formulario_page.dart` |
| **8** | Criação e edição no estado local | Evidência D | `lib/screens/formulario_page.dart`, `lista_page.dart` |
| **9** | Modelo e widgets organizados | Seção 5 (Estrutura) | `lib/models/`, `lib/widgets/`, `lib/screens/`, `lib/theme/` |
| **10** | Dois espaços sem overflow | Evidência E | `lib/screens/lista_page.dart`, `lib/widgets/resumo_catalogo.dart` |
| **11** | Tema e acessibilidade | Evidência B e E, Seção 4 | `lib/theme/app_theme.dart` |
| **12** | Análise e teste de widget | Seção 5 (Testes e Análise) | `test/` (15 testes passando), `flutter analyze` limpo |
| **13** | Decisões, fontes e autoria | Seção 6 deste relatório | `RELATORIO.md` |

---

## 4. Evidências Visuais e Funcionais

### Evidência A — Estado Vazio e Coleção
- **Estado Vazio:** Quando a coleção de itens está vazia (`_itens.isEmpty`), o componente reutilizável `EstadoVazio` é exibido centralizado com ícone ilustrativo, texto descritivo e o botão `"Adicionar primeiro item"`.
- **Coleção Dinâmica:** Ao adicionar itens, a tela transiciona reativamente para a exibição da lista de cartões (`ItemCard`), exibindo título, descrição, categoria, status e indicador de favorito.

### Evidência B — Navegação e Detalhe
- Ao clicar em qualquer cartão na `ListaPage`, ocorre o disparo de `Navigator.push` para a `DetalhePage`.
- A tela de detalhe recebe a instância de `ItemCatalogo` e renderiza todas as informações completas, botões de ação para alternar favorito em tempo real, editar (abrindo o formulário pré-preenchido) e excluir com diálogo de confirmação modal (`AlertDialog`).

### Evidência C — Formulário e Validação
- O formulário utiliza `GlobalKey<FormState>`, validadores declarativos (`_validarTitulo` e `_validarCategoria`) com regras de preenchimento (campo não-vazio e no mínimo 3 caracteres).
- Caso o usuário tente salvar com campos inválidos, as mensagens de erro `"Informe o título"` e `"Use pelo menos 3 caracteres"` surgem imediatamente sob os respectivos campos (`AutovalidateMode.onUserInteraction`) e o envio é bloqueado.

### Evidência D — Criação e Edição
- **Criação:** Abrir o formulário sem item inicial (`itemInicial == null`) inicializa os campos vazios. Ao salvar, um novo `id` é gerado, o item é adicionado à lista e um `SnackBar("Item salvo.")` é exibido.
- **Edição:** Ao abrir a partir de um item existente, os `TextEditingController` são inicializados no `initState` com os dados atuais. Ao salvar, a lista local localiza o item pelo `id` através de `indexWhere` e o substitui sem duplicá-lo.

### Evidência E — Dois Espaços de Tela (Responsividade sem Overflow)
- Utilização de `LayoutBuilder` na `ListaPage` e `SingleChildScrollView` nas telas de detalhe e formulário.
- **Espaço Estreito (< 900px):** Apresenta a lista/grade em coluna única com proporção ajustada, aproveitando a área vertical e acomodando o teclado virtual sem erro de RenderFlex.
- **Espaço Amplo ($\ge$ 900px):** Divide o layout horizontalmente em grade de cartões expandida e painel lateral `ResumoCatalogo` com métricas consolidadas (Total de itens, Favoritos, Em andamento, Concluídos).

### Acessibilidade
- Tema Material 3 com contraste estrito entre texto e plano de fundo (`AppTheme.lightTheme`).
- Todos os `IconButton` possuem `tooltip` semântico explícito (`"Favoritar"`, `"Remover dos favoritos"`, `"Editar item"`, `"Excluir item"`).
- Alvos de toque adequados com altura e largura mínimas $\ge 48\text{dp}$.
- Ordem lógica de foco do teclado virtual configurada via `FocusNode` e `textInputAction` (`next` e `done`).

---

## 5. Organização e Qualidade

### Estrutura do Código
```
lib/
├── data/ (dados iniciais e enums)
├── models/ (modelo de domínio imutável com copyWith e validações)
├── screens/ (telas do fluxo: lista, detalhe e formulário)
├── theme/ (definições de tema e acessibilidade visual)
└── widgets/ (componentes modulares e reutilizáveis)
```

### Decisão de Componentização
O componente `ItemCard` foi extraído para isolar a responsabilidade de apresentação e interação imediata de cada obra (favoritar, alterar status, clique para detalhe). O componente `EstadoVazio` foi desacoplado para permitir reaproveitamento em estados de busca e coleções vazias, enquanto `ResumoCatalogo` encapsula o cálculo e apresentação das estatísticas em telas amplas.

### Análise Estática, Testes e Build

```text
$ dart format .
Formatted 21 files in 0.19 seconds.

$ flutter analyze
Analyzing catalogo_pessoal...
No issues found! (ran in 3.4s)

$ flutter test
00:04 +15: All tests passed!

$ flutter build apk
√ Built build\app\outputs\flutter-apk\app-release.apk (47.5MB)
```

---

## 6. Decisões, Dificuldade, Fontes e Autoria

### Decisões Técnicas
1. **Formulário Unificado:** Utilização de uma única classe `FormularioPage` tanto para cadastro quanto para edição, controlando o modo através da nulabilidade do parâmetro `itemInicial`. Isso evita código duplicado e garante consistência das regras de validação.
2. **Imutabilidade e Identidade Estável:** A classe `ItemCatalogo` utiliza propriedades finais e método `copyWith`. Na atualização do estado, a identificação é feita por `id` imutável, garantindo que mesmo itens com títulos idênticos não sofram conflitos.
3. **Proteção contra Duplo Envio:** Implementação de guarda síncrona `_submetendo` no envio do formulário, desabilitando o botão de submissão e prevenindo submissões duplicadas.

### Dificuldade Enfrentada e Solução
Durante os testes de responsividade em diferentes larguras de viewport, o painel lateral `ResumoCatalogo` gerava overflow horizontal de texto quando renderizado em tamanhos intermediários. A solução consistiu em envolver os títulos em `Expanded` com `TextOverflow.ellipsis`, aplicar `SingleChildScrollView` e calibrar o breakpoint responsivo no `LayoutBuilder` para 900px.

### Fontes Consultadas
- Documentação Oficial do Flutter: *Form Validation, Layouts, Testing & Accessibility* ([docs.flutter.dev](https://docs.flutter.dev))
- Documentação da Linguagem Dart: *Null safety, Collections & Immutability* ([dart.dev](https://dart.dev))
- Conjunto de Ícones Material Design 3

### Declaração de Autoria
Declaro que este trabalho e relatório descrevem fielmente a versão identificada do aplicativo **Catálogo Pessoal**, que as fontes e bibliotecas externas foram devidamente registradas e que o código não contém segredos, tokens ou senhas publicadas.
