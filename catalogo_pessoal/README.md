# Catálogo Pessoal em Flutter (M1 - Trabalho Final)

Aplicativo mobile desenvolvido em **Flutter** para gerenciamento de um catálogo pessoal de itens (livros/mídias/obras). Permite cadastro, visualização detalhada, edição, marcação de favoritos, alteração de status e exclusão, além de adaptação responsiva de layout para telas compactas e amplas.

---

## 📱 Funcionalidades

- **Coleção Dinâmica e Estado Vazio:** Lista com dados dinâmicos em memória e visualização ilustrada (`EstadoVazio`) quando a lista não possui itens.
- **Navegação Completa:** Fluxo de Lista $\rightarrow$ Detalhe $\rightarrow$ Formulário (Criação e Edição).
- **Formulário Reutilizável com Validação:** Validação de campos obrigatórios (título e categoria com no mínimo 3 caracteres), controle de foco, proteção contra duplo envio e retorno tipado.
- **Edição sem Duplicação:** Atualização in-place pelo `id` mantendo a identidade dos registros.
- **Layout Adaptativo:** Renderização de lista em telas estreitas (< 900px) e grade com painel lateral de métricas (`ResumoCatalogo`) em telas amplas ($\ge$ 900px) sem nenhum overflow.
- **Tema e Acessibilidade:** Design em Material 3, alto contraste, tooltips semânticos e alvos de toque acessíveis ($\ge 48\text{dp}$).

---

## 📂 Arquitetura do Projeto

```
lib/
├── data/
│   ├── itens_iniciais.dart      # Lista inicial de itens simulados
│   └── status_item.dart         # Enum de status com rótulos e ícones
├── models/
│   └── item_catalogo.dart       # Modelo de domínio com imutabilidade e copyWith
├── screens/
│   ├── lista_page.dart          # Tela principal (coleção, grade responsiva e resumo)
│   ├── detalhe_page.dart        # Visualização detalhada do item
│   └── formulario_page.dart     # Formulário de criação e edição com validação
├── theme/
│   └── app_theme.dart           # Tema Material 3 acessível e estilização global
├── widgets/
│   ├── catalogo_grade.dart      # Grid/List responsivo adaptativo
│   ├── estado_vazio.dart        # Componente exibido quando não há itens
│   ├── item_card.dart           # Cartão do item com ações rápidas
│   └── resumo_catalogo.dart     # Painel lateral com métricas para telas amplas
└── main.dart                    # Ponto de entrada do aplicativo
test/
├── models/
│   └── item_catalogo_test.dart  # Testes unitários do modelo
├── widgets/
│   ├── estado_vazio_test.dart   # Testes de widget do estado vazio
│   └── item_card_test.dart      # Testes de widget do cartão de item
└── screens/
    ├── lista_page_test.dart     # Teste do fluxo da lista e estado vazio
    ├── detalhe_page_test.dart   # Teste da tela de detalhe
    └── formulario_page_test.dart# Teste de validação e modos do formulário
```

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter 3.x / Dart 3.x instalado e configurado no PATH.

### Passos:
1. Obter dependências:
   ```bash
   flutter pub get
   ```
2. Executar formatação de código:
   ```bash
   dart format .
   ```
3. Executar análise estática (Linter):
   ```bash
   flutter analyze
   ```
4. Executar os testes automatizados:
   ```bash
   flutter test
   ```
5. Executar o aplicativo no emulador ou dispositivo:
   ```bash
   flutter run
   ```
6. Gerar o APK de Release para Android:
   ```bash
   flutter build apk
   ```
   *O artefato gerado estará em: `build/app/outputs/flutter-apk/app-release.apk`*

## 🔐 Autenticação Firebase (Unidade 5)

O app inicia no `AuthGate`: primeiro observa a sessão persistida, depois mostra o
formulário de entrada/cadastro ou o catálogo. O fluxo inclui logout, envio e
atualização da verificação de e-mail e recuperação de senha. O SDK fica no
Service, o Repository traduz falhas, e os ViewModels publicam o estado para as
telas.

Para configurar um ambiente de desenvolvimento:

1. Instale Firebase CLI e FlutterFire CLI (`npm install -g firebase-tools`,
   `firebase login` e `dart pub global activate flutterfire_cli`). Rode
   `flutterfire configure` e selecione o projeto de desenvolvimento. O comando
   substituirá o arquivo provisório `lib/firebase_options.dart`.
2. No Firebase Console desse projeto, habilite **Authentication → Email/Password**.
3. Para executar o Auth Emulator e o Firestore Emulator com o mesmo ID do
   projeto configurado no FlutterFire, rode
   `firebase emulators:start --project ID_DO_PROJETO --only auth,firestore`.
4. Em outro terminal, inicie o Android Emulator com:
   `flutter run --dart-define=USE_FIREBASE_EMULATORS=true`

O host dos emuladores usa `10.0.2.2` no Android Emulator e `127.0.0.1` em
desktop/web. Para um dispositivo físico, informe o IP da máquina com
`--dart-define=FIREBASE_EMULATOR_HOST=IP_DA_MAQUINA`. O app não contém
credenciais de serviço nem define um projeto Firebase real; não configure este
fluxo apontando para produção.

### Firestore de tarefas (Unidade 6)

O botão **Minhas tarefas** abre a lista privada da sessão. O Firestore recebe
apenas consultas limitadas e filtradas pelo UID, e `firestore.rules` valida dono,
campos, tipos e imutabilidade de `ownerId`/`createdAt`. O índice composto fica em
`firestore.indexes.json`; `firebase.json` aponta os emuladores para as regras
versionadas no repositório.

Para testar as regras localmente, instale as dependências JavaScript com
`npm install` e rode `npm run test:rules`. O script inicia um Firestore Emulator
isolado com o projeto fictício `demo-catalogo-pessoal`; os casos cobrem uma
operação permitida pelo dono e negações para outra pessoa, sessão anônima e dados
inválidos. Para testar o app, use o ID real do projeto de desenvolvimento gerado
por FlutterFire nos comandos de emulador, mantendo-o igual para Auth e Firestore.

---

## 📋 Matriz dos 13 Critérios da Rubrica

| Nº | Critério | Arquivo / Local |
|---|---|---|
| 1 | Identificação, objetivo e fluxo | `README.md` e Relatório |
| 2 | Repositório, versão e instruções | `README.md` |
| 3 | Execução e artefato Android | `build/app/outputs/flutter-apk/app-release.apk` |
| 4 | Duas ou mais telas e navegação | `lib/screens/` (`lista_page.dart`, `detalhe_page.dart`, `formulario_page.dart`) |
| 5 | Coleção dinâmica e estado vazio | `lib/widgets/estado_vazio.dart`, `lib/screens/lista_page.dart` |
| 6 | Detalhe do item selecionado | `lib/screens/detalhe_page.dart` |
| 7 | Formulário e validação | `lib/screens/formulario_page.dart` |
| 8 | Criação e edição no estado local | `lib/screens/formulario_page.dart`, `lib/screens/lista_page.dart` |
| 9 | Modelo e widgets organizados | `lib/models/`, `lib/widgets/`, `lib/screens/`, `lib/theme/` |
| 10 | Dois espaços sem overflow | `lib/screens/lista_page.dart`, `lib/widgets/resumo_catalogo.dart` |
| 11 | Tema e acessibilidade | `lib/theme/app_theme.dart` |
| 12 | Análise e teste de widget | `test/` (`lista_page_test.dart`, `formulario_page_test.dart`, etc.) |
| 13 | Decisões, fontes e autoria | `README.md` e Relatório |
